defmodule OutdoorDwa.Repo.Migrations.AddReasonToSubmission do
  use Ecto.Migration

  def change do
    alter table("practical_task_submission") do
      add :reason, :string
    end
  end
end
