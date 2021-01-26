defmodule OutdoorDwaWeb.TeamSettingsLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_leader}

  alias OutdoorDwa.TeamSettingContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwaWeb.TeamSettings.SettingComponent
  alias OutdoorDwaWeb.MinioSigning
  alias OutdoorDwaWeb.MinioConfig
  alias OutdoorDwaWeb.Helpers.Upload

  # 15 MB
  @max_file_size_team_photo 15_000_000

  @impl true
  def on_mount(_params, _session, socket) do
    socket
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            token_session: %{team_id: team_id}
          }
        } = socket
      ) do
    if connected?(socket), do: TeamSettingContext.subscribe(team_id, "#")
    team_settings = TeamSettingContext.list_all_team_settings(team_id)
    team = TeamContext.get_team!(team_id)
    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    socket
    |> allow_upload(
      :file,
      accept: MinioConfig.allowed_extensions(),
      max_entries: 1,
      external: &Upload.pre_sign_upload/2,
      max_file_size: @max_file_size_team_photo
    )
    |> assign(team_id: team_id)
    |> assign(team_settings: team_settings)
    |> assign(is_future_edition: is_future_edition)
    |> assign(photo_file_uuid: team.photo_file_uuid)
    |> assign(team: team)
  end

  def handle_info({"settings_changed", team_id}, socket) do
    team_settings = TeamSettingContext.list_all_team_settings(team_id)
    socket = assign(socket, team_settings: team_settings)
    {:noreply, socket}
  end

  def handle_event("validate", _params, socket) do
    if !socket.assigns.photo_file_uuid do
      socket
      |> put_flash(:error, "A team photo for your team was already submitted.")
      |> assign(disabled: true)
    end

    case(
      TeamContext.check_if_edition_of_team_has_started(socket.assigns.token_session.team_id)
    ) do
      nil ->
        socket
        |> put_flash(
          :error,
          "The edition has already been started, team photo submissions are no longer accepted."
        )
        |> assign(disabled: true)

      _ ->
        socket
    end

    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_event("save", _params, %{assigns: assigns} = socket) do
    authorized socket do
      consume_uploaded_entries(
        socket,
        :file,
        fn upload, _ ->
          TeamContext.update_team(
            assigns.team,
            %{
              photo_file_uuid: upload.key
            }
          )
        end
      )

      team = TeamContext.get_team!(assigns.team_id)

      {
        :noreply,
        socket
        |> assign(photo_file_uuid: team.photo_file_uuid)
        |> put_flash(:info, "The file has been submitted")
      }
    end
  end

  def upload_button_css_classes(uploads) do
    "" <>
      if length(uploads.file.entries) == 0 || length(uploads.file.errors) > 0 do
        "opacity-50"
      else
        ""
      end
  end

  def signed_url(file_uuid) do
    MinioSigning.pre_signed_get_url(MinioConfig.get_config(file_uuid))
  end

  def handle_info({:settings_changed, team_id}, socket) do
    team_settings = TeamSettingContext.list_all_team_settings(team_id)
    socket = assign(socket, team_settings: team_settings)
    {:noreply, socket}
  end
end
