defmodule OutdoorDwaWeb.Admin.TravelAgentsLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}

  alias OutdoorDwa.{UserContext, EditionUserRoleContext}

  @impl true
  def on_mount(%{"edition_id" => edition_id}, _session, socket) do
    socket
    |> assign(edition_id: edition_id)
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            edition_id: edition_id
          }
        } = socket
      ) do
    travel_agents = UserContext.get_user_by_edition_role(edition_id, "TravelGuide")
    users = UserContext.list_possible_travel_guides_for_edition(edition_id)

    socket
    |> assign(agents: travel_agents)
    |> assign(users: users)
  end

  def handle_event(
        "add_agent",
        %{"user_id" => user_id},
        %{
          assigns: %{
            edition_id: edition_id
          }
        } = socket
      ) do
    {user_id_integer, _} = Integer.parse(user_id)
    {edition_id_integer, _} = Integer.parse(edition_id)

    selected_travelguide =
      Enum.filter(socket.assigns.users, fn user -> user.id == user_id_integer end)
      |> hd()

    {:ok, travel_agent} =
      case is_nil(selected_travelguide.role) do
        true ->
          EditionUserRoleContext.create_edition_user_role(
            edition_id_integer,
            user_id_integer,
            "TravelGuide"
          )

        false ->
          EditionUserRoleContext.update_existing_role(selected_travelguide.eur_id, "TravelGuide")
      end

    new_agent = UserContext.get_user!(travel_agent.user_id)

    socket = add_travel_agent(socket, new_agent)
    {:noreply, socket}
  end

  defp add_travel_agent(socket, new_agent) do
    socket =
      update(
        socket,
        :agents,
        fn agents -> agents ++ [new_agent] end
      )

    socket =
      update(
        socket,
        :users,
        fn users -> Enum.filter(users, fn user -> user.id != new_agent.id end) end
      )
  end
end
