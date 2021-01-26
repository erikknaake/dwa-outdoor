defmodule OutdoorDwa.UpdateCooldownQuestioning do
  use Oban.Worker, queue: :default

  alias OutdoorDwa.TravelQuestioningContext
  alias OutdoorDwa.TeamContext

  @impl Oban.Worker
  def perform(args) do
    with travel_questioning <-
           TravelQuestioningContext.get_travel_questioning!(args.args["travel_questioning_id"]),
         true <- travel_questioning.status == "Cooldown",
         {n, result} when n >= 0 <-
           TravelQuestioningContext.update_travel_questioning(travel_questioning, %{
             status: "To Do"
           }) do
      broadcast_success(result)
    else
      false -> :ok
      _ -> {:error, "Increment teams travel credits error"}
    end
  end

  defp broadcast_success(edited_travel_questioning) do
    TravelQuestioningContext.broadcast(
      {:ok, edited_travel_questioning},
      :travel_questioning_updated
    )

    TeamContext.broadcast_question_answer_update(
      edited_travel_questioning.team_id,
      :travel_question_answer_created
    )

    :ok
  end
end
