defmodule OutdoorDwa.EditionContext do
  @moduledoc """
  The EditionContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.{EditionUserRoleContext, TrackContext}

  @topic "editions"
  @overview_topic "editions_overview"

  def subscribe() do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @topic)
  end

  def overview_subscribe() do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @overview_topic)
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @topic,
      {event, message}
    )
  end

  defp broadcast({:error, _} = error, _), do: error

  defp overview_broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @overview_topic,
      {event, message}
    )
  end

  defp overview_broadcast({:error, _} = error, _), do: error

  @doc """
  Returns the list of edition.

  ## Examples

      iex> list_edition()
      [%Edition{}, ...]

  """
  def list_edition do
    Edition
    |> order_by(desc: :start_datetime)
    |> Repo.all()
  end

  @doc """
  Gets a single edition.

  Raises `Ecto.NoResultsError` if the Edition does not exist.

  ## Examples

      iex> get_edition!(123)
      %Edition{}

      iex> get_edition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_edition(id), do: Repo.get(Edition, id)

  def is_edition_active?(id, current_datetime \\ DateTime.utc_now()) do
    get_edition(id)
    |> is_edition_in_progress?(current_datetime)
  end

  def get_active_edition(current_datetime \\ DateTime.utc_now()) do
    Repo.one(
      from e in Edition,
        where: e.start_datetime <= ^current_datetime and e.end_datetime >= ^current_datetime
    )
  end

  def get_active_or_upcoming_edition(current_datetime \\ DateTime.utc_now()) do
    case get_active_edition(current_datetime) do
      nil -> get_soonest_upcoming_edition()
      result -> result
    end
  end

  def is_edition_in_progress?(edition, current_datetime \\ DateTime.utc_now()) do
    edition.start_datetime <= current_datetime and edition.end_datetime >= current_datetime
  end

  def get_soonest_upcoming_edition(current_datetime \\ DateTime.utc_now()) do
    query =
      from e in Edition,
        where: e.start_datetime > ^current_datetime,
        order_by: e.start_datetime,
        limit: 1

    Repo.one(query)
  end

  @doc """
  Creates a edition.

  ## Examples

      iex> create_edition(%{field: value})
      {:ok, %Edition{}}

      iex> create_edition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_edition(attrs \\ %{}, user_id) do
    Repo.transaction(fn ->
      edition =
        %Edition{}
        |> Edition.changeset(attrs)
        |> Repo.insert()

      %Edition{id: edition_id} = elem(edition, 1)
      EditionUserRoleContext.create_edition_user_role(edition_id, user_id, "Organisator")
      TrackContext.create_edition_tracks(edition_id, ["Track 1", "Track 2", "Track 3"])

      overview_broadcast(edition, :new_edition)

      {:ok, result_edition} = edition
      result_edition
    end)
  end

  @doc """
  Updates a edition.

  ## Examples

      iex> update_edition(edition, %{field: new_value})
      {:ok, %Edition{}}

      iex> update_edition(edition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_edition(%Edition{} = edition, attrs) do
    edition =
      edition
      |> Edition.changeset(attrs)
      |> Repo.update()

    overview_broadcast(edition, :updated_edition)

    edition
  end

  @doc """
  Deletes a edition.

  ## Examples

      iex> delete_edition(edition)
      {:ok, %Edition{}}

      iex> delete_edition(edition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_edition(%Edition{} = edition) do
    Repo.delete(edition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edition changes.

  ## Examples

      iex> change_edition(edition)
      %Ecto.Changeset{data: %Edition{}}

  """
  def change_edition(%Edition{} = edition, attrs \\ %{}) do
    Edition.changeset(edition, attrs)
  end

  def get_nearest_previous_edition(current_datetime \\ DateTime.utc_now()) do
    result_set =
      Repo.one(
        from e in Edition,
          where: e.end_datetime < ^current_datetime,
          order_by: e.end_datetime,
          limit: 1
      )
  end

  def get_active_or_before_edition(current_date \\ DateTime.utc_now()) do
    case get_active_edition(current_date) do
      nil -> get_nearest_previous_edition(current_date)
      result -> result
    end
  end

  def are_scores_published?(current_date \\ DateTime.utc_now()) do
    edition = get_active_or_before_edition(current_date)
    edition.scores_published
  end

  def publish_scores(current_date \\ DateTime.utc_now()) do
    edition =
      get_active_or_before_edition(current_date)
      |> update_edition(%{scores_published: true})
      |> broadcast(:scores_published)
  end

  def is_progression_allowed_for_edition?(edition_id, current_date \\ DateTime.utc_now()) do
    edition = get_edition(edition_id)

    case Timex.before?(edition.end_datetime, current_date) || edition.scores_published do
      true -> false
      false -> true
    end
  end

  def update_and_sort_editions_list(editions, new_or_updated_edition) do
    Enum.reduce(editions, [], fn e, acc ->
      if e.id == new_or_updated_edition.id do
        [new_or_updated_edition | acc]
      else
        [e | acc]
      end
    end)
    |> sort_editions_list()
  end

  def sort_editions_list(editions) do
    Enum.sort(editions, &(&1.start_datetime >= &2.start_datetime))
  end

  @impl true
  def find_overlapping_editions(start_datetime, end_datetime, except_id \\ nil) do
    overlapping_editions_query =
      from e in Edition,
        where:
          (e.start_datetime <= ^start_datetime and e.end_datetime >= ^start_datetime) or
            (e.start_datetime <= ^end_datetime and e.end_datetime >= ^end_datetime)

    case except_id do
      nil -> overlapping_editions_query |> Repo.all()
      _ -> overlapping_editions_query |> where([e], e.id != ^except_id) |> Repo.all()
    end
  end
end
