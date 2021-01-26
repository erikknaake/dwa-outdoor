defmodule OutdoorDwaWeb.PracticalTaskLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}
  alias OutdoorDwa.PracticalTask_TeamContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.PracticalTaskContext
  alias OutdoorDwa.PracticalTaskSubmissionContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwaWeb.AuthHelpers
  alias OutdoorDwaWeb.MinioSigning
  alias OutdoorDwaWeb.MinioConfig
  alias OutdoorDwaWeb.Helpers.Upload

  # 200 MB
  @max_file_size 200_000_000

  @impl true
  def on_mount(%{"task_id" => task_id}, _session, socket) do
    socket =
      socket
      |> assign(task_id: task_id, practical_task_submissions: [])
      |> active_edition_check()

    {
      :ok,
      socket,
      temporary_assigns: [
        practical_task_submissions: []
      ]
    }
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            task_id: task_id
          }
        } = socket
      ) do
    %{edition_id: _, team_id: team_id, role: user_role} = AuthHelpers.get_token_data(socket)

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    # There is a chance a practical_task_team doesnt exist yet, causing the practical task to not be preloaded
    # hence it gets nil-checked, and if it doesnt exist, a practical_task_team gets created.
    practical_task_team_query_result =
      PracticalTask_TeamContext.get_by_team_and_task_id(team_id, task_id)

    if is_nil(practical_task_team_query_result) do
      PracticalTask_TeamContext.upsert(team_id, task_id, "To Do")
    end

    socket = initial_assigns(socket, team_id, task_id, is_future_edition, user_role)

    if connected?(socket) do
      PracticalTaskSubmissionContext.subscribe(socket.assigns.practical_task_team.id)
      PracticalTask_TeamContext.subscribe(socket.assigns.practical_task_team.team_id)
      EditionContext.subscribe()
    end

    socket
    |> allow_upload(
      :file,
      accept: MinioConfig.allowed_extensions(),
      max_entries: 1,
      external: &Upload.pre_sign_upload/2,
      max_file_size: @max_file_size
    )
  end

  @impl true
  def handle_info({:practical_task_submission_created, practical_task_submission}, socket) do
    socket =
      update(
        socket,
        :practical_task_submissions,
        fn submissions -> [practical_task_submission | submissions] end
      )

    {:noreply, socket}
  end

  def handle_info({:practical_task_submission_changed, practical_task_submission}, socket) do
    socket =
      update(
        socket,
        :practical_task_submissions,
        fn submissions -> [practical_task_submission | submissions] end
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:practical_task_team_updated, practical_task_team}, socket) do
    socket = assign(socket, practical_task_team: practical_task_team)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:submission_judged, {practical_task_submission, practical_task_team}}, socket) do
    socket = assign(socket, practical_task_team: practical_task_team)

    socket =
      update(
        socket,
        :practical_task_submissions,
        fn submissions -> [practical_task_submission | submissions] end
      )

    {:noreply, socket}
  end

  def handle_info({:submission_review_skipped, practical_task_submission}, socket) do
    socket =
      update(
        socket,
        :practical_task_submissions,
        fn submissions -> [practical_task_submission | submissions] end
      )

    {:noreply, socket}
  end

  def handle_info({:scores_published, _}, socket) do
    socket =
      socket
      |> put_flash(:info, "Edition scores have been published!")
      |> assign(progression_allowed?: false)

    {:noreply, socket}
  end

  defp active_edition_check(socket) do
    case(EditionContext.get_active_edition()) do
      nil ->
        socket
        |> put_flash(:error, "The edition has ended, submissions are no longer accepted.")
        |> assign(disabled: true)

      _ ->
        socket
    end
  end

  # A minimal implementation is required in order to validate file extension
  def handle_event("validate", _params, socket) do
    case EditionContext.is_progression_allowed_for_edition?(
           socket.assigns.practical_task.edition_id
         ) do
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
      case EditionContext.is_progression_allowed_for_edition?(
             socket.assigns.practical_task.edition_id
           ) do
        true ->
          {:ok, practical_task__team} =
            PracticalTask_TeamContext.upsert(
              assigns.team_id,
              assigns.practical_task_team.practical_task_id,
              @in_review_status
            )

          consume_uploaded_entries(
            socket,
            :file,
            fn upload, _ ->
              next_attempt =
                PracticalTaskSubmissionContext.get_max_attempt_number(practical_task__team.id) + 1

              PracticalTaskSubmissionContext.create_practical_task_submission(
                practical_task__team.id,
                %{
                  file_uuid: upload.key,
                  approval_state: "Pending",
                  attempt_number: next_attempt
                }
              )
            end
          )

          {
            :noreply,
            socket
            |> put_flash(:info, "The file has been submitted")
          }

        false ->
          show_flash_on_edition_ended(socket)
      end
    end
  end

  def upload_button_css_classes(status, uploads, progression_allowed?) do
    "button button--primary " <>
      if status == "Done" || status == @in_review_status || length(uploads.file.entries) == 0 ||
           length(uploads.file.errors) > 0 || !progression_allowed? do
        "button--disabled"
      else
        ""
      end
  end

  defp initial_assigns(socket, team_id, task_id, is_future_edition, user_role) do
    practical_task = PracticalTaskContext.get_practical_task!(task_id)
    {:ok, practical_task_team} = PracticalTask_TeamContext.find_or_create(team_id, task_id)

    progression_allowed? =
      EditionContext.is_progression_allowed_for_edition?(practical_task.edition_id)

    practical_task_submissions_query_result =
      PracticalTaskSubmissionContext.get_submissions_for_practical_task_team(
        practical_task_team.id
      )

    practical_task_submissions =
      case practical_task_submissions_query_result do
        nil -> []
        result -> result
      end

    socket
    |> assign(
      practical_task: practical_task,
      practical_task_team: practical_task_team,
      practical_task_submissions: practical_task_submissions,
      progression_allowed?: progression_allowed?,
      is_future_edition: is_future_edition,
      user_role: user_role,
      team_id: team_id
    )
  end

  defp show_flash_on_edition_ended(socket) do
    socket =
      put_flash(
        socket,
        :error,
        "The edition has ended, you cant work on this practical task anymore."
      )

    {:noreply, push_redirect(socket, to: Routes.project_path(socket, :index))}
  end
end
