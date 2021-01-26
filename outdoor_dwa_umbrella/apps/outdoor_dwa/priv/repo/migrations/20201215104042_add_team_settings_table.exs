defmodule OutdoorDwa.Repo.Migrations.AddTeamSettingsTable do
  use Ecto.Migration

  def change do
    create table(:team_setting) do
      add :value, :string
    end
  end
end
