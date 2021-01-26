defmodule OutdoorDwaWeb.DateFormatter do
  @moduledoc false

  def format_full_date(date) do
    case Timex.format(date, "{0D}-{0M}-{YYYY} {h24}:{m}") do
      {:ok, date} -> date
    end
  end
end
