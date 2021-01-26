defmodule OutdoorDwaWeb.EditionOverviewLive do
  use OutdoorDwaWeb, :live_view

  alias OutdoorDwa.EditionContext

  @impl true
  def mount(_params, _session, socket) do
    editions = EditionContext.list_edition()

    if connected?(socket) do
      EditionContext.overview_subscribe()
    end

    {:ok, assign(socket, editions: editions)}
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
