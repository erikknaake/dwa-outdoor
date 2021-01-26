defmodule OutdoorDwa.PracticalTaskContext do
  @moduledoc """
  The PracticalTaskContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.PracticalTaskContext.PracticalTask
  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team
  alias OutdoorDwa.TeamContext

  @topic "practical_task"
  def subscribe() do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @topic)
  end

  def subscribe_as_staff() do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:*")
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @topic,
      {event, message}
    )
  end

  defp broadcast(error, _), do: error

  @publication_event :practical_task_published
  defp broadcast_publications() do
    broadcast({:ok, "published_tasks"}, @publication_event)
  end

  defp broadcast_for_staff({:ok, practical_task}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:*",
      {event, practical_task}
    )
  end

  @doc """
  Returns the list of practical_task.

  ## Examples

      iex> list_practical_task()
      [%PracticalTask{}, ...]

  """
  def list_practical_task do
    Repo.all(PracticalTask)
  end

  def list_practical_task_of_edition(edition_id) do
    Repo.all(from t in PracticalTask, where: t.edition_id == ^edition_id)
  end

  @doc """
  Gets a single practical_task.

  Raises `Ecto.NoResultsError` if the Practical task does not exist.

  ## Examples

      iex> get_practical_task!(123)
      %PracticalTask{}

      iex> get_practical_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_practical_task!(id), do: Repo.get!(PracticalTask, id)

  @doc """
  Creates a practical_task.

  ## Examples

      iex> create_practical_task(%{field: value})
      {:ok, %PracticalTask{}}

      iex> create_practical_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_practical_task(attrs \\ %{}) do
    result =
      %PracticalTask{}
      |> PracticalTask.changeset(attrs)
      |> Repo.insert()

    broadcast_for_staff(result, :practical_task_created)
    maybe_broadcast_published(result)
  end

  @doc """
  Updates a practical_task.

  ## Examples

      iex> update_practical_task(practical_task, %{field: new_value})
      {:ok, %PracticalTask{}}

      iex> update_practical_task(practical_task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practical_task(%PracticalTask{} = practical_task, attrs) do
    practical_task
    |> PracticalTask.changeset(attrs)
    |> Repo.update()
    |> maybe_broadcast_published()
  end

  defp maybe_broadcast_published({:error, reason} = message), do: message

  defp maybe_broadcast_published({:ok, practical_task} = message) do
    if(practical_task.is_published) do
      broadcast(message, @publication_event)
    else
      :ok
    end
  end

  @doc """
  Deletes a practical_task.

  ## Examples

      iex> delete_practical_task(practical_task)
      {:ok, %PracticalTask{}}

      iex> delete_practical_task(practical_task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_practical_task(%PracticalTask{} = practical_task) do
    Repo.delete(practical_task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking practical_task changes.

  ## Examples

      iex> change_practical_task(practical_task)
      %Ecto.Changeset{data: %PracticalTask{}}

  """
  def change_practical_task(%PracticalTask{} = practical_task, attrs \\ %{}) do
    PracticalTask.changeset(practical_task, attrs)
  end

  def get_or_create_changeset(id \\ nil) do
    entity =
      case id do
        nil -> %PracticalTask{}
        _ -> get_practical_task!(id)
      end

    change_practical_task(entity)
  end

  def upsert_practical_task(attrs \\ %{}) do
    entity_id = Map.get(attrs, "id", nil)
    is_create = entity_id == nil

    case is_create do
      true -> create_practical_task(attrs)
      false -> update_practical_task(get_practical_task!(entity_id), attrs)
    end
  end

  def list_team_practical_tasks(team_id) do
    team = TeamContext.get_team!(team_id)

    query =
      from pt in PracticalTask,
        left_join: ptt in PracticalTask_Team,
        on: pt.id == ptt.practical_task_id and ptt.team_id == ^team_id,
        select: %{
          title: pt.title,
          description: pt.description,
          travel_credit_reward: pt.travel_credit_reward,
          is_published: pt.is_published,
          difficulty: pt.difficulty,
          status: ptt.status,
          edition_id: pt.edition_id,
          type: "practical_task",
          team_id: ^Integer.to_string(team_id),
          task_id: pt.id,
          updated_at: pt.updated_at
        },
        where: pt.edition_id == ^team.edition_id and pt.is_published == true

    Repo.all(query)
  end

  defp update_publications_in_db(%{"true" => published_ids, "false" => unpublished_ids}) do
    Repo.transaction(fn ->
      from(pt in PracticalTask,
        where: pt.id in ^published_ids,
        update: [set: [is_published: true]]
      )
      |> Repo.update_all([])

      from(pt in PracticalTask,
        where: pt.id in ^unpublished_ids,
        update: [set: [is_published: false]]
      )
      |> Repo.update_all([])
    end)

    broadcast_publications()
  end

  def update_publications(publications) do
    publications
    |> Map.keys()
    |> Enum.reduce(
      %{"true" => [], "false" => []},
      fn x, acc ->
        case publications[x] do
          true -> %{acc | "true" => [String.to_integer(x) | acc["true"]]}
          false -> %{acc | "false" => [String.to_integer(x) | acc["false"]]}
        end
      end
    )
    |> update_publications_in_db()
  end
end
