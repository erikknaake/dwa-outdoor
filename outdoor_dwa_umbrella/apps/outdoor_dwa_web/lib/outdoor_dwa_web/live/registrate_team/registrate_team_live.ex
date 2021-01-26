defmodule OutdoorDwaWeb.RegistrateTeamLive do
  use OutdoorDwaWeb, {:live_view_auth, :has_user}
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwaWeb.AuthHelpers

  defp create_team(socket) do
    socket.assigns

    user_id =
      case socket.assigns.token_session do
        nil -> nil
        token_session -> token_session.user_id
      end

    edition_id = String.to_integer(socket.assigns.edition)
    %Team{user_id: user_id, edition_id: edition_id}
  end

  defp default_changeset(socket) do
    socket
    |> create_team()
    |> TeamContext.change_team()
  end

  @impl true
  def on_mount(params, _session, socket) do
    socket
    |> assign(edition: params["edition_id"])
    |> (fn socket -> assign(socket, changeset: default_changeset(socket)) end).()
  end

  @impl true
  def on_authorized(socket) do
    socket
  end

  @impl true
  def handle_event("save", %{"team" => team}, socket) do
    authorized(socket) do
      team_base = create_team(socket)
      team_changeset = TeamContext.create_team(team, team_base)

      case team_changeset do
        {:ok, team} ->
          previous_session = socket.assigns.token_session

          updated_session = %{
            user_id: previous_session.user_id,
            role: "TeamLeader",
            team_id: team.id,
            edition_id: team.edition_id
          }

          result = AuthHelpers.send_token(socket, updated_session)
          send(self(), :redirect)
          result

        {:error, :rollback} ->
          {
            :noreply,
            socket
            |> assign(changeset: default_changeset(socket))
            |> put_flash(
              :error,
              "Something went wrong while creating your team, perhaps your team name is already taken?"
            )
          }
      end
    end
  end

  @impl true
  def handle_event("validate", %{"team" => team}, socket) do
    authorized(socket) do
      changeset =
        create_team(socket)
        |> TeamContext.change_team(team)
        |> Map.put(:action, :insert)

      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info(:redirect, socket) do
    {:noreply, push_redirect(socket, to: Routes.task_overview_path(socket, :index))}
  end
end
