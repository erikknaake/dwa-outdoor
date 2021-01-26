defmodule OutdoorDwaWeb.Admin.EditionFormLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_admin}

  alias OutdoorDwaWeb.AuthHelpers
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.EditionContext.Edition

  @impl true
  def on_mount(params, _session, socket) do
    socket
    |> assign(changeset: EditionContext.change_edition(%Edition{}))
    |> apply_action(socket.assigns.live_action, params)
  end

  @impl true
  def on_authorized(socket) do
    socket
  end

  defp apply_action(socket, :edit, %{"edition_id" => id}) do
    edition = EditionContext.get_edition(id)

    socket
    |> assign(action_type: "Edit")
    |> assign(edition: edition)
    |> assign(changeset: EditionContext.change_edition(edition))
  end

  defp apply_action(socket, :create, _params) do
    socket
    |> assign(action_type: "Create")
    |> assign(changeset: EditionContext.change_edition(%Edition{}))
  end

  @impl true
  def handle_event("save", %{"edition" => params}, socket) do
    authorized(socket) do
      save_edition(socket, socket.assigns.live_action, params)
    end
  end

  @impl true
  def handle_event("validate", %{"edition" => edition}, socket) do
    authorized(socket) do
      changeset =
        %Edition{}
        |> EditionContext.change_edition(edition)
        |> Map.put(:action, :insert)

      {
        :noreply,
        socket
        |> assign(changeset: changeset)
      }
    end
  end

  defp save_edition(socket, :create, params) do
    if EditionContext.find_overlapping_editions(params["start_datetime"], params["end_datetime"]) !=
         [] do
      overlapping_edition_error(socket)
    else
      case EditionContext.create_edition(params, get_user_id(socket)) do
        {:ok, edition} ->
          create_new_questioning_create_job(edition.id, edition.start_datetime)

          result =
            AuthHelpers.send_token(socket, %{socket.assigns.token_session | role: "Organisator"})

          send(self(), {:redirect, Routes.admin_edition_overview_path(socket, :index)})
          result

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_edition(socket, :edit, params) do
    if EditionContext.find_overlapping_editions(
         params["start_datetime"],
         params["end_datetime"],
         socket.assigns.edition.id
       ) != [] do
      overlapping_edition_error(socket)
    else
      case EditionContext.update_edition(socket.assigns.edition, params) do
        {:ok, edition} ->
          %{start_datetime: old_start_datetime} = socket.assigns.edition
          %{start_datetime: new_start_datetime, id: edition_id} = edition

          if old_start_datetime != new_start_datetime do
            create_new_questioning_create_job(edition_id, new_start_datetime)
          end

          {:noreply,
           push_redirect(socket, to: Routes.admin_edition_overview_path(socket, :index))}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp create_new_questioning_create_job(edition_id, scheduled_datetime) do
    %{edition_id: edition_id}
    |> OutdoorDwa.CreateTravelQuestionings.new(scheduled_at: scheduled_datetime)
    |> Oban.insert()
  end

  defp get_user_id(socket) do
    case socket.assigns.token_session do
      nil -> nil
      token_session -> token_session.user_id
    end
  end

  @impl true
  def handle_info({:redirect, to}, socket) do
    {:noreply, push_redirect(socket, to: to)}
  end

  @impl true
  def overlapping_edition_error(socket) do
    {:noreply,
     assign(socket,
       error_message: "Your edition term is overlapping with an edition term that already exists"
     )}
  end
end
