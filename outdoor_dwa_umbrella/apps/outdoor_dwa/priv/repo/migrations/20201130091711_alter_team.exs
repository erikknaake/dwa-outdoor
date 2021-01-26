defmodule OutdoorDwa.Repo.Migrations.AlterTeam do
  use Ecto.Migration

  def change do
    alter table("team") do
      add :team_name, :string
      add :password_hash, :string
      remove :password
      remove :salt
    end
  end
end
