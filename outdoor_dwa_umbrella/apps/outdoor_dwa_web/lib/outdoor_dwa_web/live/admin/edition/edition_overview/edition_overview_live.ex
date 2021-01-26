defmodule OutdoorDwaWeb.Admin.EditionOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator_or_admin}

  alias OutdoorDwa.EditionContext

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(editions: [], is_admin: false)
  end

  @impl true
  def on_authorized(socket) do
    editions = EditionContext.list_edition()

    if connected?(socket) do
      EditionContext.overview_subscribe()
    end

    socket
    |> assign(editions: editions, is_admin: is_user_authorized(socket, :is_admin))
  end

  def handle_info({:new_edition, edition}, socket) do
    socket =
      update(
        socket,
        :editions,
        fn editions -> EditionContext.sort_editions_list([edition | editions]) end
      )

    {:noreply, socket}
  end

  def handle_info({:updated_edition, edition}, socket) do
    socket =
      update(
        socket,
        :editions,
        fn editions -> EditionContext.update_and_sort_editions_list(editions, edition) end
      )

    {:noreply, socket}
  end
end
