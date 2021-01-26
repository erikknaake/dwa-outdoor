defmodule OutdoorDwa.ProjectContext.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.TeamProjectContext.TeamProject

  schema "project" do
    field :title, :string
    field :description, :string
    belongs_to :edition, Edition
    has_many :team_project, TeamProject
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :title,
      :description,
      :edition_id
    ])
    |> validate_required([:title, :description])
  end
end
