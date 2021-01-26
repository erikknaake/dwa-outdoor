defmodule OutdoorDwaWeb.Admin.TravelQuestionOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}
  alias OutdoorDwa.{TravelQuestionContext, EditionContext}

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(travel_questions: [])
    |> assign(:active_edition, nil)
  end

  @impl true
  def on_authorized(socket) do
    if connected?(socket) do
      TravelQuestionContext.subscribe()
    end

    active_edition = EditionContext.get_active_or_upcoming_edition()

    travel_questions =
      case active_edition do
        nil -> []
        _ -> TravelQuestionContext.list_travel_question_of_edition(active_edition.id)
      end

    socket
    |> assign(travel_questions: travel_questions)
    |> assign(:active_edition, active_edition)
  end

  def handle_info({:travel_question_created, travel_question}, socket) do
    socket =
      update(
        socket,
        :travel_questions,
        fn travel_questions -> [travel_question | travel_questions] end
      )

    {:noreply, socket}
  end
end
