defmodule OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission
  alias OutdoorDwa.PracticalTaskContext.PracticalTask

  schema "practical_task_team" do
    field :status, :string

    belongs_to :team, Team
    belongs_to :practical_task, PracticalTask
    has_many :practical_task_submission, PracticalTaskSubmission
  end

  @doc false
  def changeset(practical_task__team, attrs) do
    practical_task__team
    |> cast(attrs, [:status, :practical_task_id, :team_id])
    |> validate_required([:status, :practical_task_id, :team_id])
  end
end
