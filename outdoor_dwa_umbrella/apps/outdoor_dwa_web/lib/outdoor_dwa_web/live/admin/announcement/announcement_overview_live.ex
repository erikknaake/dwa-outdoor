defmodule OutdoorDwaWeb.Admin.AnnouncementOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_organisator}

  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.AnnouncementContext

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(:announcements, [])
    |> assign(:edition, nil)
  end

  @impl true
  def on_authorized(socket) do
    edition = EditionContext.get_active_or_upcoming_edition()
    announcements = AnnouncementContext.list_announcements_by_edition_id(edition.id)

    socket
    |> assign(announcements: announcements, edition: edition)
  end
end
