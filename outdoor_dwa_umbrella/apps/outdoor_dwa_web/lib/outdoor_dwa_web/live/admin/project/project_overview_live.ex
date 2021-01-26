defmodule OutdoorDwaWeb.Admin.ProjectOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}
  alias OutdoorDwa.{ProjectContext, EditionContext}

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(projects: [])
    |> assign(:edition, nil)
  end

  @impl true
  def on_authorized(socket) do
    if connected?(socket) do
      ProjectContext.subscribe()
    end

    edition = EditionContext.get_active_or_upcoming_edition()

    {edition_started, projects} =
      case edition do
        nil ->
          {false, []}

        _ ->
          {edition_started = Timex.before?(edition.start_datetime, Timex.now()),
           ProjectContext.list_projects_of_edition(edition.id)}
      end

    socket
    |> assign(projects: projects, edition_started: edition_started, edition: edition)
  end

  def handle_info({:project_created, project}, socket) do
    socket =
      update(
        socket,
        :projects,
        fn projects -> [project | projects] end
      )

    {:noreply, socket}
  end
end
