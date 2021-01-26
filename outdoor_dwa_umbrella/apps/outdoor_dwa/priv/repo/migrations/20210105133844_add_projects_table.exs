defmodule OutdoorDwa.Repo.Migrations.AddProjectsTable do
  use Ecto.Migration

  def change do
    create table(:project) do
      add :title, :string
      add :description, :text
      add :edition_id, references(:edition)
    end
  end
end
