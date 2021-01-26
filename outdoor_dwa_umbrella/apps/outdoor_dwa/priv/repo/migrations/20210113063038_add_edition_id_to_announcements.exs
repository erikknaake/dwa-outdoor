defmodule OutdoorDwa.Repo.Migrations.AddEditionIdToAnnouncements do
  use Ecto.Migration

  def change do
    alter table("announcement") do
      add :edition_id, references(:edition)
    end
  end
end
