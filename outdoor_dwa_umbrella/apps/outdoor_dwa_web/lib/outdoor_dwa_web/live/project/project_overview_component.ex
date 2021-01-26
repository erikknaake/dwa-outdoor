defmodule OutdoorDwaWeb.TeamProject.ProjectOverviewComponent do
  use Phoenix.LiveComponent
  alias OutdoorDwa.TeamProjectContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwaWeb.Router.Helpers, as: Routes
  use Phoenix.HTML

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def handle_event(
        "purchase",
        %{"project_id" => project_id, "team_id" => team_id} = params,
        socket
      ) do
    case progression_allowed? =
           EditionContext.is_progression_allowed_for_edition?(socket.assigns.team.edition_id) do
      true ->
        result = TeamProjectContext.purchase_team_project(project_id, team_id)
        {:noreply, put_flash(socket, :info, "Succesfully bought the project")}

      false ->
        socket =
          put_flash(
            socket,
            :error,
            "The edition has ended, purchasing projects isn't possible anymore"
          )

        {:noreply, push_redirect(socket, to: Routes.project_path(socket, :index))}
    end
  end

  defp purchase_button_css_class(
         projects,
         team,
         only_teamleader_can_buy?,
         is_teamleader?,
         progression_allowed?
       ) do
    case purchase_disabled?(
           projects,
           team,
           only_teamleader_can_buy?,
           is_teamleader?,
           progression_allowed?
         ) do
      true -> "button--disabled"
      false -> ""
    end
  end

  defp purchase_disabled?(
         projects,
         team,
         only_teamleader_can_buy?,
         is_teamleader?,
         progression_allowed?
       ) do
    insufficient_travel_points?(team) || already_purchased_project?(projects) ||
      unauthorized_to_buy_project?(only_teamleader_can_buy?, is_teamleader?) ||
      !progression_allowed?
  end

  defp insufficient_travel_points?(team) do
    !(team.travel_points >= TeamProjectContext.project_cost())
  end

  defp already_purchased_project?(projects) do
    purchased_project = Enum.filter(projects, fn project -> !is_nil(project.status) end)
    length(purchased_project) > 0
  end

  defp unauthorized_to_buy_project?(only_teamleader_can_buy?, is_teamleader?) do
    only_teamleader_can_buy? && !is_teamleader?
  end
end
