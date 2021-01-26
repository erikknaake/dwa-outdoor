defmodule OutdoorDwa.TravelQuestionContext do
  @moduledoc """
  The TravelQuestionContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.TravelQuestionContext.TravelQuestion
  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.TrackContext

  @topic "travel_question"
  def subscribe() do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @topic)
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @topic,
      {event, message}
    )
  end

  @doc """
  Returns the list of travel_question.

  ## Examples

      iex> list_travel_question()
      [%TravelQuestion{}, ...]

  """
  def list_travel_question do
    Repo.all(TravelQuestion)
  end

  def list_travel_question_of_edition(edition_id) do
    query =
      from travel_question in TravelQuestion,
        join: track in Track,
        on: track.id == travel_question.track_id,
        where: track.edition_id == ^edition_id

    Repo.all(query)
  end

  @doc """
  Gets a single travel_question.

  Raises `Ecto.NoResultsError` if the Travel question does not exist.

  ## Examples

      iex> get_travel_question!(123)
      %TravelQuestion{}

      iex> get_travel_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_travel_question(id), do: Repo.get(TravelQuestion, id)

  def set_area(changeset, area) do
    change_travel_question(Map.merge(changeset.data, changeset.changes), %{area: area})
  end

  @doc """
  Creates a travel_question.

  ## Examples

      iex> create_travel_question(%{field: value})
      {:ok, %TravelQuestion{}}

      iex> create_travel_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_travel_question(attrs \\ %{}) do
    result =
      %TravelQuestion{}
      |> TravelQuestion.changeset(attrs)
      |> Repo.insert()

    broadcast(result, :travel_question_created)
    result
  end

  @doc """
  Updates a travel_question.

  ## Examples

      iex> update_travel_question(travel_question, %{field: new_value})
      {:ok, %TravelQuestion{}}

      iex> update_travel_question(travel_question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_travel_question(%TravelQuestion{} = travel_question, attrs) do
    travel_question
    |> TravelQuestion.changeset(attrs)
    |> Repo.update()
  end

  @spec is_answer_correct(float, float, integer) :: boolean
  def is_answer_correct(lat, lng, task_id) do
    travel_question = get_travel_question(task_id)
    point = {lat, lng}
    is_point_in_area(travel_question.area, point)
  end

  @type point :: %{:lat => float, :lng => float}
  @spec is_point_in_area([point], {float, float}) :: boolean
  def is_point_in_area(area, point) do
    geo_json = %Geo.Polygon{
      coordinates: [
        Enum.map(
          area,
          fn area_point ->
            {area_point["lat"], area_point["lng"]}
          end
        )
      ]
    }

    Topo.contains?(geo_json, point)
  end

  @doc """
  Deletes a travel_question.

  ## Examples

      iex> delete_travel_question(travel_question)
      {:ok, %TravelQuestion{}}

      iex> delete_travel_question(travel_question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_travel_question(%TravelQuestion{} = travel_question) do
    Repo.delete(travel_question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking travel_question changes.

  ## Examples

      iex> change_travel_question(travel_question)
      %Ecto.Changeset{data: %TravelQuestion{}}

  """
  def change_travel_question(%TravelQuestion{} = travel_question, attrs \\ %{}) do
    TravelQuestion.changeset(travel_question, attrs)
  end

  def get_next_travel_question(%TravelQuestion{} = travel_question) do
    Repo.get_by(
      TravelQuestion,
      track_id: travel_question.track_id,
      track_seq_no: travel_question.track_seq_no + 1
    )
  end

  def get_previous_travel_question(%TravelQuestion{} = travel_question) do
    Repo.get_by(
      TravelQuestion,
      track_id: travel_question.track_id,
      track_seq_no: travel_question.track_seq_no - 1
    )
  end

  def get_or_create_changeset(id \\ nil) do
    active_edition = EditionContext.get_active_or_upcoming_edition()
    tracks = TrackContext.list_track_for_edition(active_edition.id)

    entity =
      case id do
        nil -> %TravelQuestion{track_id: Enum.at(tracks, 0).id}
        _ -> get_travel_question(id)
      end

    change_travel_question(entity)
  end

  def upsert_travel_question(attrs \\ %{}) do
    entity_id = Map.get(attrs, "id", nil)
    is_create = entity_id == nil

    case is_create do
      true -> create_travel_question(attrs)
      false -> update_travel_questions(get_travel_question(entity_id), attrs)
    end
  end

  def update_travel_questions(travel_question, attrs) do
    Repo.transaction(fn ->
      update_travel_question(travel_question, attrs)

      if travel_question.track_id != String.to_integer(attrs["track_id"]) do
        decrement_travel_questions_seq_no(travel_question.track_id, travel_question.track_seq_no)
      end
    end)
  end

  def get_last_track_question(track_id) do
    Repo.one(
      from t in TravelQuestion,
        where: t.track_id == ^track_id,
        order_by: [
          desc: t.track_seq_no
        ],
        limit: 1
    )
  end

  def decrement_travel_questions_seq_no(track_id, track_seq_no) do
    from(
      t in TravelQuestion,
      where: t.track_id == ^track_id and t.track_seq_no > ^track_seq_no,
      update: [
        inc: [
          track_seq_no: -1
        ]
      ]
    )
    |> Repo.update_all([])
  end
end
