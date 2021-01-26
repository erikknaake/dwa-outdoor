defmodule OutdoorDwaWeb.PracticalTaskSubmissionsLiveComponent do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    {:ok, assign(socket, file_uuid: nil)}
  end

  def make_file_name(title, attempt_number, file) do
    "#{title}_v#{attempt_number}#{Path.extname(file)}"
  end

  @impl true
  def handle_event("hide_file", _params, socket) do
    {
      :noreply,
      socket
      |> assign(file_uuid: nil)
    }
  end

  @impl true
  def handle_event("show_file", %{"file_uuid" => file_uuid}, socket) do
    {
      :noreply,
      socket
      |> assign(file_uuid: file_uuid)
    }
  end

  def modal_css_classes(file_uuid) do
    "modal" <>
      case file_uuid do
        nil -> ""
        _ -> " modal--active"
      end
  end
end
