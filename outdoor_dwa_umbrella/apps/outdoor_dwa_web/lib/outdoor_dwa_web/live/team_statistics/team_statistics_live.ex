defmodule OutdoorDwaWeb.TeamStatisticsLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwaWeb.AuthHelpers
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.TravelQuestioningContext
  alias OutdoorDwa.TravelQuestionAnswerContext
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

    team = TeamContext.get_team!(team_id)
    team_count = TeamContext.count_teams_in_edition(edition_id)
    edition = EditionContext.get_edition(edition_id)

    # Format dates to ISO Extended
    edition_end_datetime = Timex.format(edition.end_datetime, "{ISO:Extended}")
    next_broom_sweeper_datetime = Timex.format(team.next_broom_sweeper_datetime, "{ISO:Extended}")

    if connected?(socket) do
      TeamContext.subscribe_statistics(team_id)
      TeamContext.subscribe_to_team_count_updates(team.edition_id)
    end

    socket
    |> assign(team: team)
    |> assign(team_id: team_id)
    |> assign(team_count: team_count)
    |> assign(edition_end_datetime: elem(edition_end_datetime, 1))
    |> assign(next_broom_sweeper_datetime: elem(next_broom_sweeper_datetime, 1))
    |> assign(task_track_count: count_done_travel_questionings(team_id))
    |> assign(is_future_edition: is_future_edition)
    |> assign(user_role: user_role)
  end

  defp count_done_travel_questionings(team_id) do
    TravelQuestioningContext.count_done_travel_questioning_in_track_by_team(team_id)
    |> Enum.map(fn t ->
      Map.put(
        t,
        :next_attempt_datetime,
        elem(
          Timex.format(
            Timex.shift(t.last_attempt_datetime,
              minutes: Application.fetch_env!(:outdoor_dwa_web, :travel_question_cooldown)
            ),
            "{ISO:Extended}"
          ),
          1
        )
      )
    end)
  end

  @impl true
  def handle_info(%{team_count: team_count}, socket) do
    authorized socket do
      {
        :noreply,
        socket
        |> assign(team_count: team_count)
      }
    end
  end

  def handle_info({:team_updated, new_team}, socket) do
    next_broom_sweeper_datetime =
      Timex.format(new_team.next_broom_sweeper_datetime, "{ISO:Extended}")

    {
      :noreply,
      socket
      |> assign(team: new_team)
      |> assign(next_broom_sweeper_datetime: elem(next_broom_sweeper_datetime, 1))
      |> assign(task_track_count: count_done_travel_questionings(new_team.id))
    }
  end

  def handle_info({:travel_questioning_updated, team_id}, socket) do
    {
      :noreply,
      socket
      |> assign(task_track_count: count_done_travel_questionings(team_id))
    }
  end

  @impl true
  def handle_event("countdown_over", params, socket) do
    {
      :noreply,
      socket
    }
  end
end
