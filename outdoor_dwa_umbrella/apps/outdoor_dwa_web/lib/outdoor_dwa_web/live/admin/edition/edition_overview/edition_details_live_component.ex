defmodule OutdoorDwaWeb.Admin.EditionDetailsLiveComponent do
  use OutdoorDwaWeb, :live_component

  def format_date(date) do
    OutdoorDwaWeb.DateFormatter.format_full_date(date)
  end

  def get_year(date) do
    case Timex.format(date, "{YYYY}") do
      {:ok, date} -> date
    end
  end
end
