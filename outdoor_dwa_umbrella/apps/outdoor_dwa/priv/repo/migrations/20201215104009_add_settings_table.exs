defmodule OutdoorDwa.Repo.Migrations.AddSettingsTable do
  use Ecto.Migration

  def change do
    # All this table should contain is a list of possible settings
    create table(:setting) do
      add :setting_name, :string
      add :value_type, :string
      add :default_value, :string
    end
  end
end
