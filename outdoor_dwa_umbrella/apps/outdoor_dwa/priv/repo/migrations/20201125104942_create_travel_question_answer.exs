defmodule OutdoorDwa.Repo.Migrations.CreateTravelQuestionAnswer do
  use Ecto.Migration

  def change do
    create table(:travel_question_answer) do
      add :attempt_number, :integer
      add :longitude, :float
      add :latitude, :float
      add :is_correct, :boolean, default: false, null: false
      add :timestamp, :utc_datetime
    end
  end
end
