defmodule OutdoorDwaWeb.EditionsLive do
  use OutdoorDwaWeb, :live_view

  alias OutdoorDwa.{EditionContext, TeamContext}

  @impl true
  def mount(%{"edition_id" => edition_id}, _session, socket) do
    case EditionContext.get_edition(edition_id) do
      nil ->
        {:ok, redirect(socket, to: Routes.edition_overview_path(socket, :index))}

      edition ->
        teams = TeamContext.get_teams_by_edition(edition_id)
        {:ok, assign(socket, edition: edition, teams: teams)}
    end
  end
end
