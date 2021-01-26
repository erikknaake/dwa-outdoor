defmodule OutdoorDwaWeb.Admin.HomeLive do
  use OutdoorDwaWeb, {:live_view_auth, :has_user}

  @impl true
  def on_mount(_params, _session, socket) do
    socket
  end

  @impl true
  def on_authorized(socket) do
    socket
  end
end
