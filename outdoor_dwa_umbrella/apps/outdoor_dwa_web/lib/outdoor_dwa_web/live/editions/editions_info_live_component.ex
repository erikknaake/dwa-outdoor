defmodule OutdoorDwaWeb.EditionsInfoLiveComponent do
  use OutdoorDwaWeb, :live_component

  def format_date(date) do
    NaiveDateTime.to_string(date)
    |> String.slice(0, 16)
  end

  def get_year(date) do
    {{y, _, _}, {_, _, _}} = NaiveDateTime.to_erl(date)
    "#{y}"
  end
end
