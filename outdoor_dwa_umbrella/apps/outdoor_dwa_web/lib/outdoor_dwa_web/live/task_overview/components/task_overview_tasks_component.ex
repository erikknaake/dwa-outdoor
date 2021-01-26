defmodule OutdoorDwaWeb.TaskOverviewTasksComponent do
  use OutdoorDwaWeb, :live_component

  @colors %{
    "Easy" => "bg-green-500",
    "Medium" => "bg-orange-500",
    "Hard" => "bg-red-600"
  }
  def mount(socket) do
    {:ok, assign(socket, colors: @colors)}
  end
end
