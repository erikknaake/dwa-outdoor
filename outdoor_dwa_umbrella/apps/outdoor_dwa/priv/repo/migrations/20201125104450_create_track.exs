defmodule OutdoorDwa.Repo.Migrations.CreateTrack do
  use Ecto.Migration

  def change do
    create table(:track) do
      add :track_name, :string
    end
  end
end
