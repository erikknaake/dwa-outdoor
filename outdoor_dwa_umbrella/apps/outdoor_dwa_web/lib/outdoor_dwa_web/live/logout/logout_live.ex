defmodule OutdoorDwaWeb.LogoutLive do
  use OutdoorDwaWeb, :live_view

  alias OutdoorDwaWeb.AuthHelpers

  @impl true
  def handle_event("Logout", %{}, socket) do
    result = AuthHelpers.logout(socket)

    send(self(), {:redirect, Routes.login_path(socket, :index)})
    result
  end

  @impl true
  def handle_info({:redirect, to}, socket) do
    {:noreply, push_redirect(socket, to: to)}
  end
end
