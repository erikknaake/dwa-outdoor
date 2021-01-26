defmodule OutdoorDwaWeb.AnnouncementLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.AnnouncementContext
  alias OutdoorDwaWeb.AuthHelpers

  @impl true
  def on_mount(_params, _session, socket) do
    socket
  end

  @impl true
  def on_authorized(socket) do
    %{edition_id: edition_id, team_id: team_id, role: user_role} =
      AuthHelpers.get_token_data(socket)

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    if connected?(socket) do
      AnnouncementContext.subscribe(edition_id)
    end

    announcements = AnnouncementContext.list_announcements_by_edition_id(edition_id)

    assign(socket,
      announcements: announcements,
      team_id: team_id,
      is_future_edition: is_future_edition,
      user_role: user_role
    )
  end

  @impl true
  def handle_info({:announcement, %{announcement: announcement}}, socket) do
    authorized socket do
      announcements =
        AnnouncementContext.list_announcements_by_edition_id(announcement.edition_id)

      {
        :noreply,
        assign(socket, announcements: announcements)
      }
    end
  end
end
