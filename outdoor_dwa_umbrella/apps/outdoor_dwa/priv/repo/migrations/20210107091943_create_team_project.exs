defmodule OutdoorDwa.Repo.Migrations.AddTeamProject do
  use Ecto.Migration

  def change do
    create table(:team_project) do
      add :status, :string
      add :file_uuid, :string
      add :rewarded_points, :integer
      add :team_id, references(:team)
      add :project_id, references(:project)
    end
  end
end
