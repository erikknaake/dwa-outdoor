defmodule OutdoorDwa.ResetOverdueProjectReviews do
  use Oban.Worker, queue: :default
  import Ecto.Query
  alias OutdoorDwa.TeamProjectContext.TeamProject
  alias OutdoorDwa.TeamProjectContext

  @review_time 10

  @impl Oban.Worker
  def perform(_args) do
    update_submissions =
      from(tp in TeamProject,
        select: tp,
        where:
          tp.updated_at <= datetime_add(^DateTime.utc_now(), -@review_time, "minute") and
            tp.status == "Being Reviewed",
        update: [set: [status: "Pending"]]
      )
      |> OutdoorDwa.Repo.update_all([])

    case update_submissions do
      {0, result} -> :ok
      {n, result} when n >= 1 -> broadcast_succes(result)
      _ -> {:error, "Error occured while resetting overdue reviews to pending"}
    end
  end

  def broadcast_succes(edited_submissions) do
    TeamProjectContext.broadcast(
      edited_submissions,
      :review_duration_exceeded
    )

    :ok
  end
end
