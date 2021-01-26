defmodule OutdoorDwa.Repo.Migrations.AddTimestampsPracticalTaskSubmission do
  use Ecto.Migration

  def change do
    alter table("practical_task_submission") do
      timestamps()
    end
  end
end
