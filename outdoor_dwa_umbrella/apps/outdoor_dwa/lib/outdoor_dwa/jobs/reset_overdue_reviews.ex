defmodule OutdoorDwa.ResetOverdueReviews do
  use Oban.Worker, queue: :default
  import Ecto.Query
  alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission
  alias OutdoorDwa.PracticalTaskSubmissionContext

  @review_time 10

  @impl Oban.Worker
  def perform(_args) do
    update_submissions =
      from(pts in PracticalTaskSubmission,
        select: pts,
        where:
          pts.updated_at <= datetime_add(^DateTime.utc_now(), -@review_time, "minute") and
            pts.approval_state == "Being Reviewed",
        update: [set: [approval_state: "Pending"]]
      )
      |> OutdoorDwa.Repo.update_all([])

    case update_submissions do
      {n, result} when n >= 0 -> broadcast_succes(result)
      _ -> {:error, "Error occured while resetting overdue reviews to pending"}
    end
  end

  def broadcast_succes(edited_submissions) do
    PracticalTaskSubmissionContext.broadcast(
      edited_submissions,
      :practical_task_submission_changed
    )

    :ok
  end
end
