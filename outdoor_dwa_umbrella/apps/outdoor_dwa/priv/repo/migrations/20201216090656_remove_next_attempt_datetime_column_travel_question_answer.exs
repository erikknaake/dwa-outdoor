defmodule OutdoorDwa.Repo.Migrations.RemoveNextAttemptDatetimeColumnTravelQuestionAnswer do
  use Ecto.Migration

  def change do
    alter table("travel_question_answer") do
      remove :next_attempt_datetime, :utc_datetime
    end
  end
end
