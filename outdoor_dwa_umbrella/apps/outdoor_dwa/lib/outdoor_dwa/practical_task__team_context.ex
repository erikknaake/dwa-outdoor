defmodule OutdoorDwa.PracticalTask_TeamContext do
  @topic "practical_tasks"
  def subscribe do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, @topic)
  end

  def subscribe(practical_task_team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{practical_task_team_id}")
  end

  def broadcast({:ok, practical_task_team}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{practical_task_team.team_id}",
      {event, practical_task_team}
    )

    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      @topic,
      {event, practical_task_team}
    )

    {:ok, practical_task_team}
  end

  def broadcast({:error, _reason} = error, _event), do: error

  @moduledoc """
  The PracticalTask_TeamContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team

  @doc """
  Returns the list of practical_task_team.

  ## Examples

      iex> list_practical_task_team()
      [%PracticalTask_Team{}, ...]

  """
  def list_practical_task_team do
    Repo.all(PracticalTask_Team)
  end

  def get_by_team_and_task_id(team_id, task_id) do
    Repo.one(
      from ptt in PracticalTask_Team,
        where: ptt.team_id == ^team_id and ptt.practical_task_id == ^task_id
    )
  end

  @doc """
  Gets a single practical_task__team.

  Raises `Ecto.NoResultsError` if the Practical task  team does not exist.

  ## Examples

      iex> get_practical_task__team!(123)
      %PracticalTask_Team{}

      iex> get_practical_task__team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_practical_task__team!(id), do: Repo.get!(PracticalTask_Team, id)
  def get_practical_task__team(id), do: Repo.get(PracticalTask_Team, id)

  @doc """
  Creates a practical_task__team.

  ## Examples

      iex> create_practical_task__team(%{field: value})
      {:ok, %PracticalTask_Team{}}

      iex> create_practical_task__team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_practical_task__team(attrs \\ %{}) do
    %PracticalTask_Team{}
    |> PracticalTask_Team.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:practical_task_team_created)
  end

  def find_or_create(team_id, task_id) do
    case get_by_team_and_task_id(team_id, task_id) do
      nil ->
        create_practical_task__team(%{
          practical_task_id: task_id,
          team_id: team_id,
          status: "To Do"
        })

      practical_task_team ->
        {:ok, practical_task_team}
    end
  end

  @doc """
  Updates a practical_task__team.

  ## Examples

      iex> update_practical_task__team(practical_task__team, %{field: new_value})
      {:ok, %PracticalTask_Team{}}

      iex> update_practical_task__team(practical_task__team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practical_task__team(%PracticalTask_Team{} = practical_task__team, attrs) do
    practical_task__team
    |> PracticalTask_Team.changeset(attrs)
    |> Repo.update()
    |> broadcast(:practical_task_team_updated)
  end

  @doc """
  Deletes a practical_task__team.

  ## Examples

      iex> delete_practical_task__team(practical_task__team)
      {:ok, %PracticalTask_Team{}}

      iex> delete_practical_task__team(practical_task__team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_practical_task__team(%PracticalTask_Team{} = practical_task__team) do
    Repo.delete(practical_task__team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking practical_task__team changes.

  ## Examples

      iex> change_practical_task__team(practical_task__team)
      %Ecto.Changeset{data: %PracticalTask_Team{}}

  """
  def change_practical_task__team(%PracticalTask_Team{} = practical_task__team, attrs \\ %{}) do
    PracticalTask_Team.changeset(practical_task__team, attrs)
  end

  def upsert(team_id, practical_task_id, status) do
    case get_by_team_and_task_id(
           team_id,
           practical_task_id
         ) do
      nil ->
        create_practical_task__team(%{
          status: status,
          team_id: team_id,
          practical_task_id: practical_task_id
        })

      practical_task_team ->
        update_practical_task__team(practical_task_team, %{status: status})
    end
  end
end
