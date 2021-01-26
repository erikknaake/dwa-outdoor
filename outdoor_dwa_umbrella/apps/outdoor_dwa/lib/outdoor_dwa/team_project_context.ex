defmodule OutdoorDwa.TeamProjectContext do
  @moduledoc """
  The TeamProject context.
  """
  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo
  alias OutdoorDwa.ProjectContext.Project
  alias OutdoorDwa.TeamProjectContext.TeamProject
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.TeamContext.Team

  @allowed_review_rewards [1, 2, 4, 6]
  @project_cost 2
  def project_cost(), do: @project_cost

  @topic "team_project"
  def subscribe(team_project_team_id \\ "*") do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{team_project_team_id}")
  end

  def broadcast([submission | remaining_submissions], event) do
    specific_broadcast({:ok, submission}, event)
    broadcast(remaining_submissions, event)
  end

  def broadcast([], event) do
    global_broadcast({:ok, %{}}, event)
    :finished
  end

  def broadcast_creation({:ok, team_project}) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_project.team_id}",
      {:team_project_created, team_project}
    )

    {:ok, team_project}
  end

  def broadcast({:ok, team_project}, event) do
    specific_broadcast({:ok, team_project}, event)
    global_broadcast({:ok, team_project}, event)
    {:ok, team_project}
  end

  def specific_broadcast({:ok, team_project}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_project.team_id}",
      {event, team_project}
    )
  end

  def global_broadcast({:ok, team_project}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:*",
      {event, team_project}
    )
  end

  def broadcast({:error, _reason} = error, _event), do: error

  def create_team_project(attrs \\ %{}) do
    %TeamProject{}
    |> TeamProject.changeset(attrs)
    |> Repo.insert()
  end

  def get_team_project!(team_project_id), do: Repo.get!(TeamProject, team_project_id)

  def get_team_project_detailed!(team_project_id) do
    query =
      from tp in TeamProject,
        left_join: p in Project,
        on: p.id == tp.project_id,
        select: %{
          title: p.title,
          description: p.description,
          project_id: p.id,
          status: tp.status,
          team_id: tp.team_id,
          team_project_id: tp.id,
          file_uuid: tp.file_uuid,
          reward: tp.rewarded_points
        },
        where: tp.id == ^team_project_id

    Repo.one(query)
  end

  def get_team_project_review_details(id) do
    query =
      from tp in TeamProject,
        left_join: p in Project,
        on: tp.project_id == p.id,
        join: t in Team,
        on: t.id == tp.team_id,
        select: %{
          team_name: t.team_name,
          title: p.title,
          status: tp.status,
          submission_id: tp.id,
          submitted_at: tp.inserted_at,
          type: "project"
        },
        where: tp.id == ^id

    Repo.one(query)
  end

  def update_team_project(%TeamProject{} = team_project, attrs) do
    team_project
    |> TeamProject.changeset(attrs)
    |> Repo.update()
    |> broadcast(:team_project_updated)
  end

  def update_team_project(id, attrs) do
    team_project = get_team_project!(id)
    update_team_project(team_project, attrs)
  end

  def purchase_team_project(project_id, team_id) do
    Repo.transaction(fn ->
      team = TeamContext.get_team!(team_id)
      if team.travel_points < project_cost(), do: Repo.rollback(:insufficient_points)
      team = TeamContext.update_team(team, %{travel_points: team.travel_points - project_cost()})

      new_project =
        create_team_project(%{project_id: project_id, team_id: team_id, status: "Bought"})
        |> broadcast_creation()
    end)
  end

  def list_pending_reviews do
    query =
      from tp in TeamProject,
        left_join: p in Project,
        on: tp.project_id == p.id,
        join: t in Team,
        on: t.id == tp.team_id,
        select: %{
          team_name: t.team_name,
          title: p.title,
          status: tp.status,
          submission_id: tp.id,
          submitted_at: tp.inserted_at,
          type: "project"
        },
        where: tp.status == "Pending" or tp.status == "Being Reviewed",
        order_by: [asc: tp.inserted_at]

    Repo.all(query)
  end

  def skip_submission(submission_id) do
    submission = get_team_project!(submission_id)

    if(submission.status == "Pending" or submission.status == "Being Reviewed") do
      {:ok, updated_submission} =
        submission
        |> Ecto.Changeset.change(%{status: "Pending"})
        |> Repo.update()

      broadcast({:ok, updated_submission}, :project_submission_skipped)
    end
  end

  def assign_points_for_project(submission_id, rewarded_points) do
    Repo.transaction(fn ->
      if !Enum.member?(@allowed_review_rewards, rewarded_points),
        do: Repo.rollback(:forbidden_point_reward)

      submission = get_team_project!(submission_id)

      if(submission.status == "Pending" or submission.status == "Being Reviewed") do
        {:ok, updated_submission} =
          submission
          |> Ecto.Changeset.change(%{status: "Completed", rewarded_points: rewarded_points})
          |> Repo.update()

        team = TeamContext.get_team!(updated_submission.team_id)

        TeamContext.update_team(team, %{
          travel_points: team.travel_points + rewarded_points
        })

        broadcast({:ok, updated_submission}, :team_project_updated)
      end
    end)
  end
end
