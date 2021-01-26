defmodule OutdoorDwa.Repo.Migrations.AddUniqueUsernameConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:name], name: :unique_user_name)
    create unique_index(:team, [:team_name], name: :unique_team_name)
  end
end
