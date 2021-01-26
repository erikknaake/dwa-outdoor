defmodule OutdoorDwaWeb.Admin.TaskReviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_travel_guide}
  alias OutdoorDwa.PracticalTaskSubmissionContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwaWeb.MinioSigning
  alias OutdoorDwaWeb.MinioConfig

  @impl true
  def on_mount(%{"submission_id" => submission_id} = _params, _session, socket) do
    socket
    |> put_flash(
      :info,
      "If the submission hasn't been reviewed in 10 minutes, you will be redirected to the overview"
    )
    |> assign(submission_id: submission_id, reason: "", scores_published: true)
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            submission_id: submission_id
          }
        } = socket
      ) do
    submission = PracticalTaskSubmissionContext.get_reviewable_submission(submission_id)
    submissionTeam = TeamContext.get_team!(submission.practical_task__team.team_id)

    if connected?(socket) do
      PracticalTaskSubmissionContext.subscribe(submission.practical_task__team_id)
      EditionContext.subscribe()
    end

    if(submission.approval_state == "Pending") do
      PracticalTaskSubmissionContext.update_practical_task_submission(
        submission,
        %{approval_state: "Being Reviewed"}
      )
    end

    edition = EditionContext.get_active_edition()

    new_socket =
      socket
      |> assign(photo_file_uuid: submissionTeam.photo_file_uuid)
      |> assign(team_name: submissionTeam.team_name)
      |> assign(submission: submission)
      |> assign(scores_published: EditionContext.are_scores_published?())

    case edition do
      nil ->
        new_socket

      _ ->
        push_event(new_socket, "reviewImage", %{
          editionStartDate: edition.start_datetime,
          editionEndDate: edition.end_datetime
        })
    end
  end

  @impl true
  def handle_event("update_reason", %{"reason" => reason}, socket) do
    socket = assign(socket, reason: reason)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "approve_submission",
        %{"submission_id" => submission_id, "reason" => reason},
        socket
      ) do
    authorized socket do
      PracticalTaskSubmissionContext.approve_submission(submission_id, reason)
      socket = put_flash(socket, :info, "The submission has been approved successfully")
      redirect_to_overview(socket)
    end
  end

  @impl true
  def handle_event(
        "reject_submission",
        %{"submission_id" => submission_id, "reason" => reason},
        socket
      ) do
    authorized socket do
      case blank?(reason) do
        true ->
          socket = assign(socket, feedback: "Please enter a reason for rejecting the task")
          {:noreply, socket}

        false ->
          PracticalTaskSubmissionContext.reject_submission(submission_id, reason)
          socket = put_flash(socket, :info, "The submission has been rejected successfully")
          redirect_to_overview(socket)
      end
    end
  end

  @impl true
  def handle_event("skip_submission", %{"submission_id" => submission_id}, socket) do
    authorized socket do
      PracticalTaskSubmissionContext.skip_submission(submission_id)

      socket = put_flash(socket, :info, "You skipped the submission")
      redirect_to_overview(socket)
    end
  end

  @impl true
  def handle_info({:practical_task_submission_changed, submission}, socket) do
    if(submission.approval_state == "Pending") do
      socket =
        put_flash(
          socket,
          :info,
          "Reviewing took too long, submission has been made visible for other travelguides"
        )

      redirect_to_overview(socket)
    else
      socket = assign(socket, submission: submission)
      {:noreply, socket}
    end
  end

  def handle_info({:submission_review_skipped, _}, socket) do
    {:noreply, socket}
  end

  def handle_info({:submission_judged, {_, _}}, socket) do
    socket =
      put_flash(
        socket,
        :info,
        "You have been redirected because someone else reviewed this submission."
      )

    redirect_to_overview(socket)
  end

  def redirect_to_overview(socket) do
    {:noreply, redirect(socket, to: Routes.admin_review_overview_path(socket, :index))}
  end

  defp blank?(reason),
    do:
      "" ==
        reason
        |> to_string()
        |> String.trim()

  def reviewed?(approval_state) do
    case approval_state do
      "Approved" -> true
      "Rejected" -> true
      _ -> false
    end
  end

  def signed_url(photo_file_uuid) do
    MinioSigning.pre_signed_get_url(MinioConfig.get_config(photo_file_uuid))
  end

  @impl true
  def handle_event("hide_file", _params, socket) do
    {
      :noreply,
      socket
      |> assign(show_team_photo: nil)
    }
  end

  @impl true
  def handle_event("show_file", %{"show_team_photo" => show_team_photo}, socket) do
    {
      :noreply,
      socket
      |> assign(show_team_photo: show_team_photo)
    }
  end

  def modal_css_classes(show_team_photo) do
    "modal" <>
      case show_team_photo do
        nil -> ""
        _ -> " modal--active"
      end
  end

  def handle_info({:scores_published, _}, socket) do
    authorized socket do
      {
        :noreply,
        socket
        |> assign(:scores_published, true)
        |> put_flash(:info, "The scores have been published and can no longer be edited.")
      }
    end
  end
end
