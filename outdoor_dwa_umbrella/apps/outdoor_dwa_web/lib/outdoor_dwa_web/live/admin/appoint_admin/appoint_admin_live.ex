defmodule OutdoorDwaWeb.Admin.AppointAdminLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_admin}

  alias OutdoorDwa.{UserContext}

  def on_mount(_params, _session, socket) do
    socket
    |> assign(possible_admins: [], valid: false, user: nil)
  end

  def on_authorized(socket) do
    socket
    |> assign(
      possible_admins:
        UserContext.get_non_admins()
        |> to_selectable_data()
    )
  end

  defp to_selectable_data(users) do
    Enum.map(users, &{&1.name, &1.id})
  end

  def submit_css_classes(disabled) do
    "button button--primary " <>
      if(disabled) do
        "button--disabled"
      else
        ""
      end
  end

  defp is_valid(user) do
    user != ""
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "appointment" => %{
            "user" => user
          }
        },
        socket
      ) do
    {:noreply, assign(socket, valid: is_valid(user), user: user)}
  end

  @success_message "Successfully appointed the user as admin."
  defp save_success(socket) do
    {
      :noreply,
      socket
      |> assign(valid: false, user: nil)
      |> put_flash(:info, @success_message)
    }
  end

  @error_message "Something went wrong while appointing the user as admin."
  defp save_error(socket) do
    {
      :noreply,
      socket
      |> put_flash(:error, @error_message)
    }
  end

  @impl true
  def handle_event(
        "save",
        %{
          "appointment" => %{
            "user" => user
          }
        },
        socket
      ) do
    if(is_valid(user)) do
      case UserContext.make_admin(user) do
        {:error, _} ->
          save_error(socket)

        {:ok, _} ->
          save_success(socket)
      end
    else
      save_error(socket)
    end
  end
end
