defmodule OutdoorDwaWeb.Admin.AnnouncementDetailsLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_organisator}

  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.AnnouncementContext
  alias OutdoorDwa.AnnouncementContext.Announcement

  @impl true
  def on_mount(params, _session, socket) do
    announcement_id = Map.get(params, "announcement_id", nil)
    is_create = announcement_id == nil

    active_or_upcoming_edition = EditionContext.get_active_or_upcoming_edition()

    {
      :ok,
      socket
      |> assign(changeset: AnnouncementContext.get_or_create_changeset(nil))
      |> assign(:is_create, is_create)
      |> assign(:announcement_id, announcement_id)
      |> assign(:active_or_upcoming_edition, active_or_upcoming_edition)
    }
  end

  @impl true
  def on_authorized(%{assigns: %{announcement_id: announcement_id}} = socket) do
    socket
    |> assign(changeset: AnnouncementContext.get_or_create_changeset(announcement_id))
  end

  def handle_event("validate", %{"announcement" => announcement}, socket) do
    changeset =
      %Announcement{}
      |> AnnouncementContext.change_announcement(announcement)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_event(
        "save",
        %{"announcement" => announcement},
        %{
          assigns: %{
            announcement_id: announcement_id,
            active_or_upcoming_edition: %{id: active_or_upcoming_edition_id}
          }
        } = socket
      ) do
    updated_announcement =
      announcement
      |> Map.put("id", announcement_id)
      |> Map.put("edition_ida", active_or_upcoming_edition_id)

    result =
      case socket.assigns.is_create do
        true ->
          AnnouncementContext.create_announcement(updated_announcement)

        false ->
          AnnouncementContext.update_announcement_by_id(
            updated_announcement["id"],
            updated_announcement
          )
      end

    case result do
      {:ok, _} ->
        {:noreply,
         push_redirect(socket, to: Routes.admin_announcement_overview_path(socket, :index))}

      _ ->
        {:noreply, socket |> assign(error: "Something went wrong, please try again later.")}
    end
  end
end
