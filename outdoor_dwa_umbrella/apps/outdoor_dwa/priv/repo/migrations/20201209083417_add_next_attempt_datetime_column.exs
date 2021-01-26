defmodule OutdoorDwa.Repo.Migrations.AddNextAttemptDatetimeColumn do
  use Ecto.Migration

  def change do
    alter table("travel_question_answer") do
      add :next_attempt_datetime, :utc_datetime
    end
  end
end
