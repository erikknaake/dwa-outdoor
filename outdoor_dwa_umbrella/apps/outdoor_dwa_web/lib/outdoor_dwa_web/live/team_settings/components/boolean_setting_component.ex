defmodule OutdoorDwaWeb.TeamSettings.BooleanSettingComponent do
  use Phoenix.LiveComponent
  alias OutdoorDwa.TeamSettingContext

  @toggled_boolean %{
    "true" => "false",
    "false" => "true"
  }

  @colors %{
    "true" => "bg-green-400",
    "false" => "bg-red-500"
  }

  @boolean_setting_text %{
    "true" => "ON",
    "false" => "OFF"
  }

  @impl true
  def mount(socket) do
    {:ok, assign(socket, colors: @colors, boolean_text: @boolean_setting_text)}
  end

  @impl true
  def handle_event(
        "toggle_status",
        %{"current_value" => current_value, "setting_id" => setting_id} = _params,
        socket
      ) do
    TeamSettingContext.update_boolean_setting(setting_id, @toggled_boolean[current_value])
    {:noreply, socket}
  end
end
