defmodule OutdoorDwaWeb.TeamProject.ProjectResultComponent do
  use Phoenix.LiveComponent
  alias OutdoorDwa.TeamProjectContext
  use Phoenix.HTML

  @impl true
  def mount(socket) do
    socket = assign(socket, file_uuid: nil)
    {:ok, socket}
  end

  @impl true
  def handle_event("show_file", %{"file_uuid" => file_uuid}, socket) do
    {
      :noreply,
      socket
      |> assign(file_uuid: file_uuid)
    }
  end

  @impl true
  def handle_event("hide_file", _params, socket) do
    {
      :noreply,
      socket
      |> assign(file_uuid: nil)
    }
  end

  def modal_css_classes(file_uuid) do
    "modal" <>
      case file_uuid do
        nil -> ""
        _ -> " modal--active"
      end
  end

  defp reward(points_rewarded) do
    case points_rewarded do
      nil -> "To Be Determined"
      points -> "#{points}"
    end
  end
end
