defmodule OutdoorDwa.TeamProjectContext.TeamProject do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.ProjectContext.Project

  schema "team_project" do
    field :status, :string
    field :file_uuid, :string
    field :rewarded_points, :integer
    belongs_to :team, Team
    belongs_to :project, Project
    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :status,
      :file_uuid,
      :rewarded_points,
      :team_id,
      :project_id
    ])
    |> validate_required([:status, :team_id, :project_id])
  end
end
