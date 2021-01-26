defmodule OutdoorDwa.Repo.Migrations.AddPhotoFileUuidColumnTeam do
  use Ecto.Migration

  def change do
    alter table("team") do
      add :photo_file_uuid, :string
    end
  end
end
