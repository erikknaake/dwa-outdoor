defmodule OutdoorDwa.TravelQuestioningContext do
  @moduledoc """
  The TravelQuestioningContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion
  alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.EditionContext.Edition

  @topic "travel_questioning"
  def subscribe(travel_questioning_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{travel_questioning_id}")
  end

  def broadcast({:ok, travel_questioning}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{travel_questioning.id}",
      {event, travel_questioning}
    )

    {:ok, travel_questioning}
  end

  @doc """
  Returns the list of travel_questioning.

  ## Examples

      iex> list_travel_questioning()
      [%TravelQuestioning{}, ...]

  """
  def list_travel_questioning do
    Repo.all(TravelQuestioning)
  end

  @doc """
  Gets a single travel_questioning.

  Raises `Ecto.NoResultsError` if the Travel questioning does not exist.

  ## Examples

      iex> get_travel_questioning!(123)
      %TravelQuestioning{}

      iex> get_travel_questioning!(456)
      ** (Ecto.NoResultsError)

  """
  def get_travel_questioning!(id), do: Repo.get!(TravelQuestioning, id)

  @doc """
  Creates a travel_questioning.

  ## Examples

      iex> create_travel_questioning(%{field: value})
      {:ok, %TravelQuestioning{}}

      iex> create_travel_questioning(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_travel_questioning(
        %TravelQuestion{} = travel_question,
        %Team{} = team,
        status \\ "Not Bought Yet"
      ) do
    %TravelQuestioning{
      travel_question: travel_question,
      team: team,
      status: status
    }
    |> Repo.insert()
  end

  @doc """
  Updates a travel_questioning.

  ## Examples

      iex> update_travel_questioning(travel_questioning, %{field: new_value})
      {:ok, %TravelQuestioning{}}

      iex> update_travel_questioning(travel_questioning, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_travel_questioning(%TravelQuestioning{} = travel_questioning, attrs) do
    {:ok, travel_questioning} =
      travel_questioning
      |> TravelQuestioning.changeset_for_update(attrs)
      |> Repo.update()
      |> broadcast(:travel_questioning_updated)

    TeamContext.broadcast_statistics_questioning_change(
      :travel_questioning_updated,
      travel_questioning.team_id
    )

    {:ok, travel_questioning}
  end

  def get_travel_questioning_by_question(travel_question_id, team_id) do
    Repo.get_by(TravelQuestioning, travel_question_id: travel_question_id, team_id: team_id)
  end

  @doc """
  Deletes a travel_questioning.

  ## Examples

      iex> delete_travel_questioning(travel_questioning)
      {:ok, %TravelQuestioning{}}

      iex> delete_travel_questioning(travel_questioning)
      {:error, %Ecto.Changeset{}}

  """
  def delete_travel_questioning(%TravelQuestioning{} = travel_questioning) do
    Repo.delete(travel_questioning)
  end

  @doc """
  Counts the number of finished travel questioning items of a team in a track.
  """
  def count_done_travel_questioning_in_track_by_team(team_id) do
    edition_id_subquery = from t in Team, where: t.id == ^team_id, select: t.edition_id

    todo_questions_by_team_subquery =
      from tq in TravelQuestioning,
        where:
          tq.team_id == ^team_id and
            (tq.status == "To Do" or tq.status == "Cooldown" or tq.status == "Not Bought Yet"),
        select: %{id: tq.id, travel_question_id: tq.travel_question_id}

    done_questions_by_team_subquery =
      from tq in TravelQuestioning,
        where: tq.team_id == ^team_id and (tq.status == "Done" or tq.status == "Skipped"),
        select: %{id: tq.id, travel_question_id: tq.travel_question_id}

    answer_timestamps_of_to_do_questions_subquery =
      from tqa in TravelQuestionAnswer,
        group_by: tqa.travel_questioning_id,
        select: %{travel_questioning_id: tqa.travel_questioning_id, timestamp: max(tqa.timestamp)}

    track_cooldown_query =
      from tq in TravelQuestioning,
        join: tqu in TravelQuestion,
        on: tq.travel_question_id == tqu.id,
        where: tq.team_id == ^team_id,
        group_by: tqu.track_id,
        select: %{
          track_id: tqu.track_id,
          cooldown: fragment("SUM(CASE WHEN ? = ? THEN 1 ELSE 0 END)", tq.status, "Cooldown")
        }

    from(tr in Track,
      left_join: tq in TravelQuestion,
      on: tq.track_id == tr.id,
      left_join: toq in subquery(todo_questions_by_team_subquery),
      on: toq.travel_question_id == tq.id,
      left_join: dq in subquery(done_questions_by_team_subquery),
      on: dq.travel_question_id == tq.id,
      left_join: at in subquery(answer_timestamps_of_to_do_questions_subquery),
      on: at.travel_questioning_id == toq.id,
      left_join: co in subquery(track_cooldown_query),
      on: co.track_id == tr.id,
      where: tr.edition_id in subquery(edition_id_subquery),
      group_by: [tr.id, co.cooldown],
      select: %{
        track_name: tr.track_name,
        last_attempt_datetime: max(at.timestamp),
        number_of_questions_done: count(dq.id),
        number_of_questions: count(tq.id),
        track_cooldown: co.cooldown
      }
    )
    |> Repo.all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking travel_questioning changes.

  ## Examples

      iex> change_travel_questioning(travel_questioning)
      %Ecto.Changeset{data: %TravelQuestioning{}}

  """
  def change_travel_questioning(%TravelQuestioning{} = travel_questioning, attrs \\ %{}) do
    TravelQuestioning.changeset(travel_questioning, attrs)
  end

  def find_by_team_and_task_id(team_id, task_id) do
    Repo.one(
      from tq in TravelQuestioning,
        where: tq.team_id == ^team_id and tq.travel_question_id == ^task_id
    )
  end

  def skip_travel_questioning(travel_questioning) do
    Repo.transaction(fn ->
      {:ok, updated_travel_questioning} =
        update_travel_questioning(travel_questioning, %{status: "Skipped"})

      TeamContext.use_team_broom_sweeper(updated_travel_questioning.team_id)

      updated_travel_questioning
    end)
  end

  def create_all_travel_questionings(edition_id) do
    TravelQuestioning
    |> Repo.insert_all(get_all_travel_questionings_to_create(edition_id))
  end

  defp get_all_travel_questionings_to_create(edition_id) do
    from(tq in TravelQuestion,
      join: tr in Track,
      on: tq.track_id == tr.id,
      join: e in Edition,
      on: tr.edition_id == e.id,
      join: te in Team,
      on: e.id == te.edition_id,
      where: e.id == ^edition_id and tq.track_seq_no == 1,
      select: %{
        team_id: te.id,
        travel_question_id: tq.id,
        status: "Not Bought Yet"
      }
    )
    |> Repo.all()
  end
end
