defmodule OutdoorDwa.CreateTravelQuestionings do
  use Oban.Worker, queue: :default

  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.TravelQuestioningContext
  alias OutdoorDwa.TeamContext

  @impl Oban.Worker
  def perform(args) do
    edition = EditionContext.get_edition(args.args["edition_id"])
    date_diff = Timex.diff(edition.start_datetime, Timex.now(), :minutes)

    case date_diff >= 0 and date_diff <= 2 do
      true -> create_questionings(edition.id)
      false -> :ok
    end
  end

  defp create_questionings(edition_id) do
    case TravelQuestioningContext.create_all_travel_questionings(edition_id) do
      {n, _} when n >= 0 -> :ok
      _ -> {:error, "Create travel questionings error"}
    end
  end
end
