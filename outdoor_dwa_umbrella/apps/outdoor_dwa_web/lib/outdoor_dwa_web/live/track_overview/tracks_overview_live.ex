defmodule OutdoorDwaWeb.TracksOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwa.TrackContext
  alias OutdoorDwaWeb.AuthHelpers

  alias OutdoorDwa.{
    TeamContext,
    TravelQuestionContext,
    TravelQuestioningContext,
    TravelQuestionAnswerContext,
    EditionContext
  }

  @success "You bought a new question!"
  @failed "Something went wrong."
  @not_enough "Your team does not have enough travel credits to buy this question."
  @wrong_state "Your team can not buy this question, because the last question in this track is not completed or skipped yet."

  @impl true
  def on_mount(_params, _session, socket) do
    socket
  end

  @impl true
  def on_authorized(socket) do
    %{edition_id: _, team_id: team_id, role: user_role} = AuthHelpers.get_token_data(socket)

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    if connected?(socket) do
      TeamContext.subscribe(team_id)
      EditionContext.subscribe()
    end

    tracks = get_tracks(team_id, socket)
    team = TeamContext.get_team!(team_id)
    progression_allowed? = EditionContext.is_progression_allowed_for_edition?(team.edition_id)

    socket
    |> assign(tracks: tracks)
    |> assign(team: team)
    |> assign(progression_allowed?: progression_allowed?)
    |> assign(team_id: team_id)
    |> assign(is_future_edition: is_future_edition)
    |> assign(user_role: user_role)
  end

  def handle_event(
        "buy-question",
        %{"question_id" => question_id},
        %{
          assigns: %{
            team_id: team_id,
            team: team
          }
        } = socket
      ) do
    case EditionContext.is_progression_allowed_for_edition?(team.edition_id) do
      true ->
        question = TravelQuestionContext.get_travel_question(question_id)
        previous_questioning = get_previous_question(question, team_id)

        if previous_questioning == nil or
             (previous_questioning.status == "Done" or previous_questioning.status == "Skipped") do
          buy_question(team, question, socket)
        else
          {
            :noreply,
            socket
            |> put_flash(:error, @wrong_state)
          }
        end

      false ->
        show_flash_on_edition_ended(socket)
    end
  end

  defp buy_question(team, question, socket) do
    with true <- team.travel_credits >= question.travel_credit_cost,
         {:ok, new_team} <- TeamContext.buy_travel_question(team, question) do
      tracks = get_tracks(team.id, socket)

      {
        :noreply,
        socket
        |> assign(tracks: tracks)
        |> assign(team: new_team)
        |> put_flash(:info, @success)
      }
    else
      false -> {:noreply, socket |> put_flash(:error, @not_enough)}
      {:error, _reasons} -> {:noreply, socket |> put_flash(:error, @failed)}
    end
  end

  def handle_info({:question_bought, team}, socket) do
    tracks = get_tracks(team.id, socket)

    {
      :noreply,
      socket
      |> assign(team: team)
      |> assign(tracks: tracks)
    }
  end

  def handle_info({:question_skipped, team_id}, socket) do
    tracks = get_tracks(team_id, socket)

    {
      :noreply,
      socket
      |> assign(tracks: tracks)
    }
  end

  def handle_info({:travel_question_answer_created, team_id}, socket) do
    tracks = get_tracks(team_id, socket)

    {
      :noreply,
      socket
      |> assign(tracks: tracks)
    }
  end

  def handle_info({:scores_published, _}, socket) do
    socket =
      socket
      |> put_flash(:info, "Edition scores have been published!")
      |> assign(progression_allowed?: false)

    {:noreply, socket}
  end

  defp get_previous_question(question, team_id) do
    case TravelQuestionContext.get_previous_travel_question(question) do
      nil ->
        nil

      previous_question ->
        TravelQuestioningContext.get_travel_questioning_by_question(previous_question.id, team_id)
    end
  end

  defp get_tracks(team_id, socket) do
    %{edition_id: edition_id, team_id: _} = AuthHelpers.get_token_data(socket)

    TrackContext.list_tracks_by_edition(edition_id, team_id)
    |> Enum.map(fn track -> map_track(track) end)
  end

  defp map_track(track) do
    %{
      id: track.id,
      track_name: track.track_name,
      questions:
        Enum.filter(track.travel_question, fn question ->
          length(question.travel_questioning) > 0
        end)
        |> Enum.map(fn question -> map_question(question) end)
        |> Enum.sort(fn q1, q2 -> q1.track_seq_no < q2.track_seq_no end)
    }
  end

  defp map_question(question) do
    %{
      id: question.id,
      status: get_status(question.travel_questioning),
      track_seq_no: question.track_seq_no,
      travel_credit_cost: question.travel_credit_cost
    }
  end

  defp show_flash_on_edition_ended(socket) do
    socket = put_flash(socket, :error, "The edition has ended, you cant buy tracks anymore.")

    {:noreply,
     push_redirect(socket, to: Routes.live_path(socket, OutdoorDwaWeb.TracksOverviewLive))}
  end

  defp get_status([head | _]) do
    case head.status do
      "To Do" -> "in-progress"
      "Not Bought Yet" -> "not-bought"
      "Skipped" -> "skipped"
      "Done" -> "completed"
      "Cooldown" -> "waiting-for-next-attempt"
    end
  end
end
