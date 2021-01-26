defmodule OutdoorDwaWeb.ProjectLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}
  alias OutdoorDwaWeb.AuthHelpers
  alias OutdoorDwa.ProjectContext
  alias OutdoorDwa.TeamProjectContext
  alias OutdoorDwa.TeamSettingContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.EditionContext
  alias OutdoorDwaWeb.Helpers.Upload
  alias OutdoorDwaWeb.MinioSigning
  alias OutdoorDwaWeb.MinioConfig

  # 200 MB
  @max_file_size_project 200_000_000

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(file_uuid: nil)
  end

  @impl true
  def on_authorized(socket) do
    %{
      edition_id: edition_id,
      team_id: team_id,
      role: role
    } = AuthHelpers.get_token_data(socket)

    only_teamleader_can_buy_setting = TeamSettingContext.get_project_purchase_setting(team_id)
    only_teamleader_can_buy? = only_teamleader_can_buy_setting.value == "true"

    if connected?(socket) do
      EditionContext.subscribe()
      TeamProjectContext.subscribe(team_id)
      TeamContext.subscribe_to_team_updates(team_id)
      TeamSettingContext.subscribe(team_id, only_teamleader_can_buy_setting.id)
    end

    {team, projects} = ProjectContext.list_team_projects_and_team(team_id)
    progression_allowed? = EditionContext.is_progression_allowed_for_edition?(team.edition_id)
    projects_with_status = Enum.filter(projects, fn project -> !is_nil(project.status) end)

    bought_project =
      case length(projects_with_status) do
        0 -> nil
        _ -> hd(projects_with_status)
      end

    is_teamleader? = role == "TeamLeader"

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    socket
    |> allow_upload(
      :file,
      accept: MinioConfig.allowed_extensions(),
      max_entries: 1,
      external: &Upload.pre_sign_upload/2,
      max_file_size: @max_file_size_project
    )
    |> assign(
      team: team,
      projects: projects,
      only_teamleader_can_buy?: only_teamleader_can_buy?,
      is_teamleader?: is_teamleader?,
      bought_project: bought_project,
      team_id: team_id,
      user_role: role,
      is_future_edition: is_future_edition,
      progression_allowed?: progression_allowed?
    )
  end

  def handle_info(%Team{} = team, socket) do
    {team, _projects} = ProjectContext.list_team_projects_and_team(team.id)
    socket = assign(socket, team: team)
    {:noreply, socket}
  end

  def handle_info({:project_submission_skipped, team_project}, socket) do
    result = TeamProjectContext.get_team_project_detailed!(team_project.id)
    socket = assign(socket, bought_project: result)
    {:noreply, socket}
  end

  def handle_info({:scores_published, _}, socket) do
    socket =
      socket
      |> put_flash(:info, "Edition scores have been published!")
      |> assign(progression_allowed?: false)

    {:noreply, socket}
  end

  def handle_info({:settings_changed, team_id}, socket) do
    only_teamleader_can_buy_setting = TeamSettingContext.get_project_purchase_setting(team_id)
    only_teamleader_can_buy? = only_teamleader_can_buy_setting.value == "true"
    socket = assign(socket, only_teamleader_can_buy?: only_teamleader_can_buy?)
    {:noreply, socket}
  end

  def handle_info({:team_project_updated, team_project}, socket) do
    result = TeamProjectContext.get_team_project_detailed!(team_project.id)
    socket = assign(socket, bought_project: result)
    {:noreply, socket}
  end

  def handle_info({:review_duration_exceeded, team_project}, socket) do
    result = TeamProjectContext.get_team_project_detailed!(team_project.id)
    socket = assign(socket, bought_project: result)
    {:noreply, socket}
  end

  def handle_info({:team_project_created, team_project}, socket) do
    {_team, projects} = ProjectContext.list_team_projects_and_team(team_project.team_id)
    bought_project = hd(Enum.filter(projects, fn project -> !is_nil(project.status) end))

    socket =
      socket
      |> assign(socket, projects: projects, bought_project: bought_project)
      |> put_flash(:info, "The project has been purchased succesfully")

    {:noreply, assign(socket, bought_project: bought_project)}
  end

  # A minimal implementation is required in order to validate file extension
  def handle_event("validate", _params, socket) do
    case EditionContext.is_progression_allowed_for_edition?(socket.assigns.team.edition_id) do
      true ->
        {
          :noreply,
          active_edition_check(socket)
        }

      false ->
        show_flash_on_edition_ended(socket)
    end
  end

  @in_review_status "Being Reviewed"

  @impl true
  def handle_event("save", _params, %{assigns: assigns} = socket) do
    authorized socket do
      case EditionContext.is_progression_allowed_for_edition?(socket.assigns.team.edition_id) do
        true ->
          consume_uploaded_entries(
            socket,
            :file,
            fn upload, _ ->
              TeamProjectContext.update_team_project(
                assigns.bought_project.team_project_id,
                %{status: "Pending", file_uuid: upload.key}
              )
            end
          )

          {:noreply, put_flash(socket, :info, "The file has been submitted")}

        false ->
          show_flash_on_edition_ended(socket)
      end
    end
  end

  defp active_edition_check(socket) do
    case(OutdoorDwa.EditionContext.get_active_edition()) do
      nil ->
        socket
        |> put_flash(:error, "The edition has ended, submissions are no longer accepted.")
        |> assign(disabled: true)

      _ ->
        socket
    end
  end

  def show_flash_on_edition_ended(socket) do
    socket =
      put_flash(
        socket,
        :error,
        "The edition has ended, purchasing projects isn't possible anymore"
      )

    {:noreply, push_redirect(socket, to: Routes.project_path(socket, :index))}
  end

  def upload_button_css_classes(status, uploads) do
    "button button--primary " <>
      if status != "Bought" || length(uploads.file.entries) == 0 ||
           length(uploads.file.errors) > 0 do
        "button--disabled"
      else
        ""
      end
  end
end
