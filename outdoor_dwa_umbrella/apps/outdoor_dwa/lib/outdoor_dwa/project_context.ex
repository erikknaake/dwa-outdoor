defmodule OutdoorDwa.ProjectContext do
  @moduledoc """
  The Project context.
  """
  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.ProjectContext.Project
  alias OutdoorDwa.TeamProjectContext.TeamProject
  alias OutdoorDwa.TeamContext
  @topic "project"
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

  def list_projects_of_edition(edition_id) do
    Repo.all(from p in Project, where: p.edition_id == ^edition_id)
  end

  def create_project(attrs \\ %{}) do
    result =
      %Project{}
      |> Project.changeset(attrs)
      |> Repo.insert()

    broadcast(result, :project_created)
    result
  end

  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  def update_project(id, attrs) do
    project = get_project!(id)
    update_project(project, attrs)
  end

  def get_project!(project_id), do: Repo.get!(Project, project_id)

  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  def get_or_create_changeset(nil) do
    change_project(%Project{})
  end

  def get_or_create_changeset(id) do
    project = get_project!(id)
    change_project(project)
  end

  def list_team_projects_and_team(team_id) do
    team = TeamContext.get_team!(team_id)

    query =
      from p in Project,
        left_join: tp in TeamProject,
        on: p.id == tp.project_id and tp.team_id == ^team_id,
        select: %{
          title: p.title,
          description: p.description,
          project_id: p.id,
          status: tp.status,
          team_project_id: tp.id,
          file_uuid: tp.file_uuid,
          reward: tp.rewarded_points
        },
        where: p.edition_id == ^team.edition_id

    projects = Repo.all(query)
    {team, projects}
  end
end
