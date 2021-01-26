defmodule OutdoorDwaWeb.Admin.CoorganisatorLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_organisator}
  alias OutdoorDwaWeb.AuthHelpers
  alias OutdoorDwa.{UserContext, EditionUserRoleContext}
  alias OutdoorD

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
    possible_coorganisators = UserContext.list_possible_coorganisators_for_edition(edition_id)
    coorganisators = UserContext.get_user_by_edition_role(edition_id, "CoOrganisator")

    socket
    |> assign(coorganisators: coorganisators)
    |> assign(possible_coorganisators: possible_coorganisators)
  end

  def handle_event(
        "add_coorganisator",
        %{"user_id" => user_id},
        %{
          assigns: %{
            edition_id: edition_id
          }
        } = socket
      ) do
    {user_id_integer, _} = Integer.parse(user_id)
    {edition_id_integer, _} = Integer.parse(edition_id)

    selected_coorganisator =
      Enum.filter(socket.assigns.possible_coorganisators, fn user ->
        user.id == user_id_integer
      end)
      |> hd()

    {:ok, edition_user_role} =
      case is_nil(selected_coorganisator.role) do
        true ->
          EditionUserRoleContext.create_edition_user_role(
            edition_id_integer,
            user_id_integer,
            "CoOrganisator"
          )

        false ->
          EditionUserRoleContext.update_existing_role(
            selected_coorganisator.eur_id,
            "CoOrganisator"
          )
      end

    new_coorganisator = UserContext.get_user!(edition_user_role.user_id)

    socket = add_coorganisator(socket, new_coorganisator)

    {:noreply, socket}
  end

  defp add_coorganisator(socket, new_coorganisator) do
    socket =
      update(
        socket,
        :coorganisators,
        fn coorganisators -> [new_coorganisator | coorganisators] end
      )

    socket =
      update(
        socket,
        :possible_coorganisators,
        fn possible_coorganisators ->
          Enum.filter(
            possible_coorganisators,
            fn user -> user.id != new_coorganisator.id end
          )
        end
      )
  end
end
