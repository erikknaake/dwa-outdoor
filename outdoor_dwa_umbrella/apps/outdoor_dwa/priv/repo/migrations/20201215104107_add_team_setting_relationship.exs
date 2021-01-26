defmodule OutdoorDwa.Repo.Migrations.AddTeamSettingRelationship do
  use Ecto.Migration

  def change do
    alter table("team_setting") do
      add :team_id, references(:team)
      add :setting_id, references(:setting)
    end
  end
end
