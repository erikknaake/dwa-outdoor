defmodule OutdoorDwa.PracticalTaskSubmissionContext do
  @moduledoc """
  The PracticalTaskSubmissionContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission
  alias OutdoorDwa.PracticalTaskContext.PracticalTask
  alias OutdoorDwa.PracticalTaskContext
  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team
  alias OutdoorDwa.PracticalTask_TeamContext
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.TeamContext

  @topic "practical_tasks_submissions"
  def subscribe(practical_task__team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{practical_task__team_id}")
  end

  def broadcast({:ok, practical_task_submission}, event) do
    specific_broadcast(practical_task_submission, event)
    general_broadcast(practical_task_submission, event)
    {:ok, practical_task_submission}
  end

  def broadcast([submission | remaining_submissions], event) do
    specific_broadcast(submission, event)
    general_broadcast(submission, event)
    broadcast(remaining_submissions, event)
  end

  def broadcast([], _event) do
    :finished
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def specific_broadcast(practical_task_submission, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{practical_task_submission.practical_task__team_id}",
      {event, practical_task_submission}
    )
  end

  def general_broadcast(practical_task_submission, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:*",
      {event, practical_task_submission}
    )
  end

  @doc """
  Returns the list of practical_task_submission.

  ## Examples

      iex> list_practical_task_submission()
      [%PracticalTaskSubmission{}, ...]

  """
  def list_practical_task_submission do
    Repo.all(PracticalTaskSubmission)
  end

  def list_pending_reviews do
    query =
      from pts in PracticalTaskSubmission,
        left_join: ptt in PracticalTask_Team,
        on: pts.practical_task__team_id == ptt.id,
        join: pt in PracticalTask,
        on: pt.id == ptt.practical_task_id,
        join: t in Team,
        on: t.id == ptt.team_id,
        select: %{
          team_name: t.team_name,
          title: pt.title,
          status: pts.approval_state,
          submission_id: pts.id,
          submitted_at: pts.inserted_at,
          type: "practical_task"
        },
        where: pts.approval_state == "Pending" or pts.approval_state == "Being Reviewed",
        order_by: [asc: pts.inserted_at]

    Repo.all(query)
  end

  def get_reviewable_submission(id) do
    Repo.one(
      from pts in PracticalTaskSubmission,
        where: pts.id == ^id,
        preload: [practical_task__team: [:practical_task]]
    )
  end

  def get_submissions_for_practical_task_team(practical_task_team_id) do
    query =
      from pts in PracticalTaskSubmission,
        where: pts.practical_task__team_id == ^practical_task_team_id

    Repo.all(query)
  end

  def get_submission_details(id) do
    query =
      from pts in PracticalTaskSubmission,
        left_join: ptt in PracticalTask_Team,
        on: pts.practical_task__team_id == ptt.id,
        join: pt in PracticalTask,
        on: pt.id == ptt.practical_task_id,
        join: t in Team,
        on: t.id == ptt.team_id,
        select: %{
          team_name: t.team_name,
          title: pt.title,
          status: pts.approval_state,
          submission_id: pts.id,
          submitted_at: pts.inserted_at,
          type: "practical_task"
        },
        where: pts.id == ^id

    Repo.one(query)
  end

  def get_max_attempt_number(practical_task_team_id) do
    query =
      from pts in PracticalTaskSubmission,
        select: max(pts.attempt_number),
        where: pts.practical_task__team_id == ^practical_task_team_id

    case Repo.one(query) do
      nil -> 0
      result -> result
    end
  end

  @doc """
  Gets a single practical_task_submission.

  Raises `Ecto.NoResultsError` if the Practical task submission does not exist.

  ## Examples

      iex> get_practical_task_submission!(123)
      %PracticalTaskSubmission{}

      iex> get_practical_task_submission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_practical_task_submission!(id), do: Repo.get!(PracticalTaskSubmission, id)
  def get_practical_task_submission(id), do: Repo.get(PracticalTaskSubmission, id)

  @doc """
  Creates a practical_task_submission.

  ## Examples

      iex> create_practical_task_submission(%{field: value})
      {:ok, %PracticalTaskSubmission{}}

      iex> create_practical_task_submission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_practical_task_submission(practical_task__team_id, attrs \\ %{}) do
    %PracticalTaskSubmission{practical_task__team_id: practical_task__team_id}
    |> PracticalTaskSubmission.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:practical_task_submission_created)
  end

  @doc """
  Updates a practical_task_submission.

  ## Examples

      iex> update_practical_task_submission(practical_task_submission, %{field: new_value})
      {:ok, %PracticalTaskSubmission{}}

      iex> update_practical_task_submission(practical_task_submission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practical_task_submission(
        %PracticalTaskSubmission{} = practical_task_submission,
        attrs
      ) do
    practical_task_submission
    |> PracticalTaskSubmission.changeset(attrs)
    |> Repo.update()
    |> broadcast(:practical_task_submission_changed)
  end

  @doc """
  Deletes a practical_task_submission.

  ## Examples

      iex> delete_practical_task_submission(practical_task_submission)
      {:ok, %PracticalTaskSubmission{}}

      iex> delete_practical_task_submission(practical_task_submission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_practical_task_submission(%PracticalTaskSubmission{} = practical_task_submission) do
    Repo.delete(practical_task_submission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking practical_task_submission changes.

  ## Examples

      iex> change_practical_task_submission(practical_task_submission)
      %Ecto.Changeset{data: %PracticalTaskSubmission{}}

  """
  def change_practical_task_submission(
        %PracticalTaskSubmission{} = practical_task_submission,
        attrs \\ %{}
      ) do
    PracticalTaskSubmission.changeset(practical_task_submission, attrs)
  end

  @submission_judged_event :submission_judged
  def approve_submission(submission_id, reason) do
    Repo.transaction(fn ->
      submission = get_practical_task_submission(submission_id)

      if(
        submission.approval_state == "Pending" or submission.approval_state == "Being Reviewed"
      ) do
        {:ok, updated_submission} =
          submission
          |> Ecto.Changeset.change(%{approval_state: "Approved", reason: reason})
          |> Repo.update()

        {:ok, practical_task_team} =
          PracticalTask_TeamContext.get_practical_task__team(submission.practical_task__team_id)
          |> Ecto.Changeset.change(%{status: "Done"})
          |> Repo.update()

        task = PracticalTaskContext.get_practical_task!(practical_task_team.practical_task_id)
        team = TeamContext.get_team!(practical_task_team.team_id)

        TeamContext.update_team(team, %{
          travel_credits: team.travel_credits + task.travel_credit_reward
        })

        submission_judged_broadcast(updated_submission, practical_task_team)
      end
    end)
  end

  def reject_submission(submission_id, reason) do
    Repo.transaction(fn ->
      submission = get_practical_task_submission(submission_id)

      if(
        submission.approval_state == "Pending" or submission.approval_state == "Being Reviewed"
      ) do
        {:ok, updated_submission} =
          submission
          |> Ecto.Changeset.change(%{approval_state: "Rejected", reason: reason})
          |> Repo.update()

        {:ok, practical_task_team} =
          PracticalTask_TeamContext.get_practical_task__team(submission.practical_task__team_id)
          |> Ecto.Changeset.change(%{status: "Doing"})
          |> Repo.update()

        submission_judged_broadcast(updated_submission, practical_task_team)
      end
    end)
  end

  def skip_submission(submission_id) do
    submission = get_practical_task_submission(submission_id)

    if(submission.approval_state == "Pending" or submission.approval_state == "Being Reviewed") do
      {:ok, updated_submission} =
        submission
        |> Ecto.Changeset.change(%{approval_state: "Pending"})
        |> Repo.update()

      submission_skipped_broadcast(updated_submission)
    end
  end

  def submission_skipped_broadcast(submission) do
    general_broadcast(submission, @submission_judged_event)
    specific_broadcast(submission, :submission_review_skipped)
  end

  def submission_judged_broadcast(submission, practical_task_team) do
    # Broadcast for practical_task_details
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{practical_task_team.id}",
      {@submission_judged_event, {submission, practical_task_team}}
    )

    # Broadcast for practical_task_overview
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "practical_tasks:#{practical_task_team.team_id}",
      {:practical_task_team_updated, practical_task_team}
    )

    # General update for review overview screen
    general_broadcast(submission, @submission_judged_event)
  end
end
