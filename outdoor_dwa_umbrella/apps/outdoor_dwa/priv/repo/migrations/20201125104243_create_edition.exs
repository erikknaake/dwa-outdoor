defmodule OutdoorDwa.Repo.Migrations.CreateEdition do
  use Ecto.Migration

  def change do
    create table(:edition) do
      add :start_datetime, :utc_datetime
      add :end_datetime, :utc_datetime
      add :is_open_for_registration, :boolean, default: false, null: false
    end
  end
end
