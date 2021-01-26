defmodule OutdoorDwa.Repo.Migrations.CreatePracticalTaskTeam do
  use Ecto.Migration

  def change do
    create table(:practical_task_team) do
      add :status, :string
    end
  end
end
