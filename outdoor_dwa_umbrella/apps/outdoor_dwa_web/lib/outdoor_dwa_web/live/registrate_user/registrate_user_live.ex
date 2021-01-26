defmodule OutdoorDwaWeb.RegistrateUserLive do
  use OutdoorDwaWeb, :live_view
  use Phoenix.HTML
  alias OutdoorDwa.UserContext.User
  alias OutdoorDwa.UserContext
  alias OutdoorDwaWeb.AuthHelpers

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(changeset: UserContext.change_user(%User{}))
    }
  end

  @impl true
  def handle_event("validate", %{"user" => user}, socket) do
    changeset =
      %User{}
      |> UserContext.change_user(user)
      |> Map.put(:action, :insert)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case UserContext.create_user(params) do
      {:ok, user} ->
        result = AuthHelpers.send_token(socket, %{user_id: user.id, role: "User"})

        # You probably think why use message passing for this, simple if you dont only the event or the redirect is done, this way both happen
        send(self(), :redirect)
        result

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> assign(changeset: changeset)
        }
    end
  end

  @impl true
  def handle_info(:redirect, socket) do
    {:noreply, push_redirect(socket, to: Routes.edition_overview_path(socket, :index))}
  end
end
