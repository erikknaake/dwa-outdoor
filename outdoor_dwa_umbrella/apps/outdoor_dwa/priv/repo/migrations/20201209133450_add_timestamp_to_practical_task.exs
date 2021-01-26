defmodule OutdoorDwa.Repo.Migrations.AddTimestampToPracticalTask do
  use Ecto.Migration

  def change do
    alter table("practical_task") do
      timestamps()
    end
  end
end
