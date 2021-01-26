defmodule OutdoorDwaWeb.Admin.PracticalTaskEditLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}

  alias OutdoorDwa.PracticalTaskContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.PracticalTaskContext.PracticalTask

  @impl true
  def on_mount(params, _session, socket) do
    practical_task_id = Map.get(params, "practical_task_id", nil)
    is_create = practical_task_id == nil

    {
      :ok,
      socket
      |> assign(changeset: PracticalTaskContext.get_or_create_changeset())
      |> assign(:is_create, is_create)
      |> assign(:practical_task_id, practical_task_id)
    }
  end

  @impl true
  def on_authorized(socket) do
    socket
    |> assign(
      changeset: PracticalTaskContext.get_or_create_changeset(socket.assigns.practical_task_id)
    )
  end

  def handle_event("validate", %{"practical_task" => practical_task} = _params, socket) do
    changeset =
      %PracticalTask{}
      |> PracticalTaskContext.change_practical_task(practical_task)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_event("save", %{"practical_task" => practical_task}, socket) do
    active_edition = EditionContext.get_active_or_upcoming_edition()

    practical_task =
      practical_task
      |> Map.put("id", socket.assigns.practical_task_id)
      |> Map.put("edition_id", active_edition.id)

    action_result = PracticalTaskContext.upsert_practical_task(practical_task)

    case action_result do
      :ok ->
        {:noreply,
         push_redirect(socket, to: Routes.admin_practical_task_overview_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> assign(changeset: changeset)
        }
    end
  end
end
