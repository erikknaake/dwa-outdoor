defmodule OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team
  alias OutdoorDwa.EditionContext

  schema "practical_task_submission" do
    field :approval_state, :string
    field :attempt_number, :integer
    field :file_uuid, :string
    field :reason, :string
    belongs_to :practical_task__team, PracticalTask_Team
    timestamps()
  end

  defp validate_active_edition(changeset) do
    inserted_at =
      case get_field(changeset, :inserted_at) do
        nil -> DateTime.utc_now()
        value -> value
      end

    case EditionContext.get_active_edition(inserted_at) do
      nil ->
        add_error(
          changeset,
          :inserted_at,
          "The edition no longer accepts submission for practical tasks"
        )

      value ->
        changeset
    end
  end

  @doc false
  def changeset(practical_task_submission, attrs) do
    practical_task_submission
    |> cast(attrs, [
      :attempt_number,
      :file_uuid,
      :approval_state,
      :practical_task__team_id,
      :reason
    ])
    |> validate_required([:attempt_number, :file_uuid, :approval_state])
    |> validate_active_edition()
  end
end
