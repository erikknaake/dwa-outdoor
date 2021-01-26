defmodule OutdoorDwa.Repo.Migrations.AddTimestampsTeamProjects do
  use Ecto.Migration

  def change do
    alter table("team_project") do
      timestamps()
    end
  end
end
