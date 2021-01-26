defmodule OutdoorDwa.IncrementTravelCreditsWorker do
  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(_args) do
    case OutdoorDwa.TeamContext.increment_travel_credits_active_editions() do
      {n, _} when n >= 0 -> :ok
      _ -> {:error, "Increment teams travel credits error"}
    end
  end
end
