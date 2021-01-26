defmodule OutdoorDwaWeb.TeamRankingsLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwa.{TeamContext, RivalContext, EditionContext}
  alias OutdoorDwaWeb.AuthHelpers

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(search_team_name: "")
    |> assign(teams: [])
    |> maybe_put_non_final_score_notice()
  end

  defp maybe_put_non_final_score_notice(socket) do
    if(EditionContext.are_scores_published?()) do
      socket
    else
      socket
      |> put_flash(
        :info,
        "The scores shown are not yet the final scores and are subject to change. Please wait for the travel guides to finish reviewing all submissions."
      )
    end
  end

  @impl true
  def on_authorized(socket) do
    if connected?(socket) do
      EditionContext.subscribe()
    end

    %{:edition_id => edition_id, :team_id => team_id, role: user_role} =
      AuthHelpers.get_token_data(socket)

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    teams =
      TeamContext.list_ranking_teams(
        edition_id,
        team_id,
        socket.assigns.search_team_name
      )

    socket
    |> assign(teams: teams)
    |> assign(team_id: team_id)
    |> assign(is_future_edition: is_future_edition)
    |> assign(user_role: user_role)
  end

  @impl true
  def handle_event("subscribe_rival", %{"rival_id" => rival_id}, socket) do
    case RivalContext.create_rival(socket.assigns.team_id, String.to_integer(rival_id)) do
      {:ok, _rival} ->
        %{:edition_id => edition_id, :team_id => team_id} = AuthHelpers.get_token_data(socket)

        teams =
          TeamContext.list_ranking_teams(
            edition_id,
            team_id,
            socket.assigns.search_team_name
          )

        {
          :noreply,
          socket
          |> assign(teams: teams)
        }

      {:error, %Ecto.Changeset{} = _changeset} ->
        {
          :noreply,
          socket
        }
    end
  end

  @impl true
  def handle_event("unsubscribe_rival", %{"rival_id" => rival_id}, socket) do
    %{:edition_id => edition_id, :team_id => team_id} = AuthHelpers.get_token_data(socket)

    rival = RivalContext.get_rival_to_delete(team_id, rival_id)
    {:ok, _} = RivalContext.delete_rival(rival)

    teams = TeamContext.list_ranking_teams(edition_id, team_id)

    {
      :noreply,
      socket
      |> assign(teams: teams)
    }
  end

  @impl true
  def handle_event("reset_search", _params, socket) do
    %{:edition_id => edition_id, :team_id => team_id} = AuthHelpers.get_token_data(socket)
    teams = TeamContext.list_ranking_teams(edition_id, team_id)

    {
      :noreply,
      socket
      |> assign(search_team_name: "")
      |> assign(teams: teams)
    }
  end

  @impl true
  def handle_event("team_search", %{"team" => team_name}, socket) do
    %{:edition_id => edition_id, :team_id => team_id} = AuthHelpers.get_token_data(socket)

    teams =
      TeamContext.list_ranking_teams(
        edition_id,
        team_id,
        team_name
      )

    {
      :noreply,
      socket
      |> assign(search_team_name: team_name)
      |> assign(teams: teams)
    }
  end

  @impl true
  def handle_info({:scores_published, _}, socket) do
    authorized socket do
      {
        :noreply,
        socket
        |> put_flash(:info, "The scores have been published and can no longer change.")
      }
    end
  end
end
