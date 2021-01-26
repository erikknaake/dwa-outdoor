defmodule OutdoorDwaWeb.EditionDetailsLiveComponent do
  use OutdoorDwaWeb, :live_component

  def format_date(date) do
    OutdoorDwaWeb.DateFormatter.format_full_date(date)
  end

  def get_year(date) do
    case Timex.format(date, "{YYYY}") do
      {:ok, date} -> date
    end
  end

  def edition_row_css_class(edition) do
    if edition.is_open_for_registration do
      "table__row--active"
    else
      ""
    end
  end
end
