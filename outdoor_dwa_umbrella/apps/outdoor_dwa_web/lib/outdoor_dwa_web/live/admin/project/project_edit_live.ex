defmodule OutdoorDwaWeb.Admin.ProjectEditLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}

  alias OutdoorDwa.ProjectContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.ProjectContext.Project

  @impl true
  def on_mount(params, _session, socket) do
    project_id = Map.get(params, "project_id", nil)
    is_create = project_id == nil

    {
      :ok,
      socket
      |> assign(changeset: ProjectContext.get_or_create_changeset(nil))
      |> assign(:is_create, is_create)
      |> assign(:project_id, project_id)
    }
  end

  @impl true
  def on_authorized(socket) do
    socket
    |> assign(changeset: ProjectContext.get_or_create_changeset(socket.assigns.project_id))
  end

  def handle_event("validate", %{"project" => project} = _params, socket) do
    changeset =
      %Project{}
      |> ProjectContext.change_project(project)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_event("save", %{"project" => project}, socket) do
    edition = EditionContext.get_active_or_upcoming_edition()

    updated_project =
      project
      |> Map.put("id", socket.assigns.project_id)
      |> Map.put("edition_id", edition.id)

    result =
      case socket.assigns.is_create do
        true -> ProjectContext.create_project(updated_project)
        false -> ProjectContext.update_project(updated_project["id"], updated_project)
      end

    case result do
      {:ok, _project} ->
        {:noreply, push_redirect(socket, to: Routes.admin_project_overview_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> assign(changeset: changeset)
        }
    end
  end
end
