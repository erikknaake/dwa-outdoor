defmodule OutdoorDwaWeb.TaskOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwa.{
    EditionContext,
    TeamSettingContext,
    PracticalTaskContext,
    PracticalTask_TeamContext,
    PracticalTaskContext,
    TeamContext,
    PdfModule
  }

  alias OutdoorDwaWeb.{MinioSigning, MinioConfig, AuthHelpers, TaskOverviewTasksComponent}

  @impl true
  def on_mount(_params, _session, socket) do
    socket
  end

  @impl true
  def on_authorized(socket) do
    %{edition_id: _, team_id: team_id, role: user_role} = AuthHelpers.get_token_data(socket)
    pdf_allowed_setting = TeamSettingContext.get_pdf_setting(team_id)
    pdf_allowed = pdf_allowed_setting.value == "true"

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    if connected?(socket) do
      PracticalTaskContext.subscribe()
      PracticalTask_TeamContext.subscribe(team_id)
      TeamSettingContext.subscribe(team_id, pdf_allowed_setting.id)
      EditionContext.subscribe()
    end

    tasks = PracticalTaskContext.list_team_practical_tasks(team_id)
    team = TeamContext.get_team!(team_id)
    progression_allowed? = EditionContext.is_progression_allowed_for_edition?(team.edition_id)
    pdf_path = handle_pdf_logic(tasks, socket)

    assign(socket,
      tasks: tasks,
      team_id: team_id,
      pdf_path: pdf_path,
      edition_id: team.edition_id,
      progression_allowed?: progression_allowed?,
      pdf_allowed: pdf_path != "" && pdf_allowed,
      is_future_edition: is_future_edition,
      user_role: user_role
    )
  end

  @impl true
  def handle_event("start_task", %{"team_id" => team_id, "task_id" => task_id} = _params, socket) do
    authorized socket do
      case EditionContext.is_progression_allowed_for_edition?(socket.assigns.edition_id) do
        true ->
          case PracticalTask_TeamContext.get_by_team_and_task_id(team_id, task_id) do
            nil -> create_practical_task_team(team_id, task_id)
            practical_task_team -> update_practical_task__team(practical_task_team)
          end

          {:noreply, socket}

        false ->
          socket =
            put_flash(
              socket,
              :error,
              "The scores for the edition have been published, starting tasks isn't allowed anymore"
            )

          {:noreply, assign(socket, progression_allowed?: false)}
      end
    end
  end

  @impl true
  def handle_event("load_task", %{"task_id" => task_id} = _params, socket) do
    authorized socket do
      {:noreply, redirect(socket, to: Routes.practical_task_path(socket, :index, task_id))}
    end
  end

  defp create_practical_task_team(team_id, task_id) do
    practical_task_team = %{
      status: "Doing",
      team_id: team_id,
      practical_task_id: task_id
    }

    PracticalTask_TeamContext.create_practical_task__team(practical_task_team)
  end

  defp update_practical_task__team(practical_task_team) do
    PracticalTask_TeamContext.update_practical_task__team(practical_task_team, %{status: "Doing"})
  end

  @impl true
  def handle_info({:practical_task_team_created, practical_task_team}, socket) do
    authorized socket do
      case practical_task_team.team_id == socket.assigns.team_id do
        true ->
          {:noreply, update_practical_tasks(socket)}

        false ->
          {:noreply, socket}
      end
    end
  end

  def handle_info({:settings_changed, team_id}, socket) do
    pdf_allowed_setting = TeamSettingContext.get_pdf_setting(team_id)
    pdf_allowed = pdf_allowed_setting.value == "true"

    socket =
      socket
      |> put_flash(
        :info,
        "The PDF settings have been changed. Please adjust your workflow appropriately."
      )
      |> assign(pdf_allowed: pdf_allowed)

    {:noreply, socket}
  end

  defp update_practical_tasks(socket) do
    tasks = PracticalTaskContext.list_team_practical_tasks(socket.assigns.team_id)
    assign(socket, tasks: tasks)
  end

  @impl true
  def handle_info({:practical_task_team_updated, practical_task_team}, socket) do
    authorized socket do
      case practical_task_team.team_id == socket.assigns.team_id do
        true ->
          {:noreply, update_practical_tasks(socket)}

        false ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_info({:practical_task_published, _}, socket) do
    authorized socket do
      {:noreply, update_practical_tasks(socket)}
    end
  end

  def handle_info({:scores_published, _}, socket) do
    socket =
      socket
      |> put_flash(:info, "Edition scores have been published!")
      |> assign(progression_allowed?: false)

    {:noreply, socket}
  end

  defp handle_pdf_logic([], socket), do: ""

  defp handle_pdf_logic(tasks, socket) do
    edition_id = hd(tasks).edition_id
    last_update_date = get_last_update_date(tasks)
    file_name = PdfModule.generate_pdf?(edition_id, last_update_date)
    home_path = Routes.home_path(socket, :index)
    Path.join(home_path, "static/practical_task_pdf/#{file_name}")
  end

  def get_last_update_date(tasks) do
    Enum.map(tasks, fn x -> x.updated_at end)
    |> Enum.reduce(fn x, acc ->
      case Timex.before?(x, acc) do
        true -> acc
        false -> x
      end
    end)
  end

  defp render_to_do(socket, all_tasks, progression_allowed?) do
    tasks =
      Enum.filter(all_tasks, fn x -> x.status == "To Do" || x.status == nil end)
      |> Enum.map(fn x -> %{x | status: "To Do"} end)

    assigns = %{
      socket: socket,
      tasks: tasks,
      progression_allowed?: progression_allowed?
    }

    ~L"""
      <%= live_component @socket, TaskOverviewTasksComponent,
        tasks: @tasks, progression_allowed?: @progression_allowed?
      %>
    """
  end

  defp render_doing(socket, all_tasks, progression_allowed?) do
    tasks = Enum.filter(all_tasks, fn x -> x.status == "Doing" end)

    assigns = %{
      socket: socket,
      tasks: tasks,
      progression_allowed?: progression_allowed?
    }

    ~L"""
      <%= live_component @socket, TaskOverviewTasksComponent,
        tasks: @tasks, progression_allowed?: @progression_allowed?
      %>
    """
  end

  defp render_review(socket, all_tasks, progression_allowed?) do
    tasks = Enum.filter(all_tasks, fn x -> x.status == "Being Reviewed" end)

    assigns = %{
      socket: socket,
      tasks: tasks,
      progression_allowed?: progression_allowed?
    }

    ~L"""
      <%= live_component @socket, TaskOverviewTasksComponent,
        tasks: @tasks, progression_allowed?: @progression_allowed?
      %>
    """
  end

  defp render_done(socket, all_tasks, progression_allowed?) do
    tasks = Enum.filter(all_tasks, fn x -> x.status == "Done" end)

    assigns = %{
      socket: socket,
      tasks: tasks,
      progression_allowed?: progression_allowed?
    }

    ~L"""
      <%= live_component @socket, TaskOverviewTasksComponent,
        tasks: @tasks, progression_allowed?: @progression_allowed?
      %>
    """
  end
end
