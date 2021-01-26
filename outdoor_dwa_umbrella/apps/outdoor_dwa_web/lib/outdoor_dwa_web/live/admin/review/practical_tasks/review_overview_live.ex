defmodule OutdoorDwaWeb.Admin.ReviewOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_travel_guide}
  alias OutdoorDwa.PracticalTaskSubmissionContext
  alias OutdoorDwaWeb.ReviewOverviewSubmissionComponent
  alias OutdoorDwa.EditionContext

  @impl true
  def on_mount(_params, _session, socket) do
    socket = assign(socket, submissions: [], is_co_organisator: false, scores_published: true)

    {
      :ok,
      socket
    }
  end

  @impl true
  def on_authorized(socket) do
    if connected?(socket) do
      PracticalTaskSubmissionContext.subscribe("*")
      EditionContext.subscribe()
    end

    to_review = PracticalTaskSubmissionContext.list_pending_reviews()

    assign(
      socket,
      submissions: to_review,
      is_co_organisator: is_user_authorized(socket, :is_co_organisator),
      scores_published: EditionContext.are_scores_published?()
    )
  end

  @impl true
  def handle_info({:practical_task_submission_changed, submission}, socket) do
    authorized socket do
      submissions = PracticalTaskSubmissionContext.list_pending_reviews()

      socket = assign(socket, submissions: submissions)
      {:noreply, socket}
    end
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

  @impl true
  def handle_info({:practical_task_submission_created, submission}, socket) do
    authorized socket do
      submission = PracticalTaskSubmissionContext.get_submission_details(submission.id)

      socket =
        update(
          socket,
          :submissions,
          fn submissions -> [submission | submissions] end
        )

      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:submission_judged, submission}, socket) do
    authorized socket do
      submissions = PracticalTaskSubmissionContext.list_pending_reviews()

      socket = assign(socket, submissions: submissions)
      {:noreply, socket}
    end
  end

  def handle_event("publish_scores", _params, socket) do
    authorized socket, :is_co_organisator do
      case EditionContext.publish_scores() do
        :ok ->
          {
            :noreply,
            socket
          }

        {:error, _} ->
          {
            :noreply,
            socket
            |> put_flash(:error, "Something went wrong while publishing the scores.")
          }
      end
    end
  end

  def render_review_submission(socket, submission, scores_published) do
    assigns = %{
      socket: socket,
      submission: submission,
      scores_published: scores_published
    }

    ~L"""
        <%= live_component @socket, ReviewOverviewSubmissionComponent,
                submission: @submission, scores_published: @scores_published %>
    """
  end
end
