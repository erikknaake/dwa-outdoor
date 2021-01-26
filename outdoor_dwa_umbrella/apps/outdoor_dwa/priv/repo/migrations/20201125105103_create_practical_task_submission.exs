defmodule OutdoorDwa.Repo.Migrations.CreatePracticalTaskSubmission do
  use Ecto.Migration

  def change do
    create table(:practical_task_submission) do
      add :attempt_number, :integer
      add :file_uuid, :string
      add :approval_state, :string
    end
  end
end
