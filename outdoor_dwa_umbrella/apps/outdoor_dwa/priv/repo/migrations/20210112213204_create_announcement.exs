defmodule OutdoorDwa.Repo.Migrations.CreateAnnouncement do
  use Ecto.Migration

  def change do
    create table(:announcement) do
      add :announcement, :string

      timestamps()
    end
  end
end
