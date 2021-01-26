defmodule OutdoorDwa.Repo.Migrations.TravelQuestionGeoJson do
  use Ecto.Migration

  def change do
    alter table(:travel_question) do
      remove :marge
      remove :longitude
      remove :latitude

      add :area, :jsonb
    end
  end
end
