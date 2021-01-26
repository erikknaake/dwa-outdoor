defmodule OutdoorDwaWeb.Admin.ProjectReviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_travel_guide}
  alias OutdoorDwa.TeamProjectContext
  alias OutdoorDwa.EditionContext

  @impl true
  def on_mount(%{"submission_id" => submission_id} = _params, _session, socket) do
    socket
    |> put_flash(
      :info,
      "If the submission hasn't been reviewed in 10 minutes, you will be redirected to the overview"
    )
    |> assign(submission_id: submission_id, scores_published: true)
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            submission_id: submission_id
          }
        } = socket
      ) do
    submission = TeamProjectContext.get_team_project_detailed!(submission_id)

    if connected?(socket) do
      TeamProjectContext.subscribe(submission.team_id)
      EditionContext.subscribe()
    end

    if(submission.status == "Pending") do
      TeamProjectContext.update_team_project(
        submission.team_project_id,
        %{status: "Being Reviewed"}
      )
    end

    edition = EditionContext.get_active_edition()

    new_socket =
      socket
      |> assign(submission: submission, scores_published: EditionContext.are_scores_published?())

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

  def handle_event(
        "review_submission",
        %{"review" => %{"rewarded_points" => rewarded_points} = review},
        socket
      ) do
    {parsed_rewarded_points, _} = Integer.parse(rewarded_points)

    case TeamProjectContext.assign_points_for_project(
           socket.assigns.submission_id,
           parsed_rewarded_points
         ) do
      {:error, :forbidden_point_reward} ->
        {:noreply,
         put_flash(socket, :error, "Trying to judge with a forbidden ammount of points.")}

      _ ->
        socket
        |> put_flash(:info, "Project has been judged succesfully")
        |> redirect_to_overview()
    end
  end

  @impl true
  def handle_event("skip_submission", %{"submission_id" => submission_id}, socket) do
    authorized socket do
      TeamProjectContext.skip_submission(submission_id)

      socket = put_flash(socket, :info, "You skipped the submission")
      redirect_to_overview(socket)
    end
  end

  @impl true
  def handle_info({:team_project_updated, submission}, socket) do
    if(submission.status == "Pending") do
      socket =
        put_flash(
          socket,
          :info,
          "Reviewing took too long, submission has been made visible for other travelguides"
        )

      redirect_to_overview(socket)
    else
      detailed_submission = TeamProjectContext.get_team_project_detailed!(submission.id)
      socket = assign(socket, submission: detailed_submission)
      {:noreply, socket}
    end
  end

  def handle_info({:project_submission_skipped, submission}, socket) do
    {:noreply, socket}
  end

  def handle_info({:review_duration_exceeded, submission}, socket) do
    socket
    |> put_flash(
      :info,
      "The review duration has been exceeded, and has been made available for review again."
    )
    |> redirect_to_overview()
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

  @impl true
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

  def redirect_to_overview(socket) do
    {:noreply, redirect(socket, to: Routes.admin_project_review_overview_path(socket, :index))}
  end

  def reviewed?(approval_state) do
    case approval_state do
      "Completed" -> true
      _ -> false
    end
  end
end
