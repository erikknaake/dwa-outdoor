defmodule OutdoorDwaWeb.FutureEditionMessageLiveComponent do
  use Phoenix.LiveComponent

  alias OutdoorDwaWeb.Router.Helpers, as: Routes
  alias OutdoorDwa.TeamContext

  @impl true
  def update(assigns, socket) do
    team = TeamContext.get_team!(assigns.team_id)

    if assigns.is_future_edition !== nil do
      {_, future_edition_start_datetime} =
        assigns.is_future_edition
        |> Timex.format("{ISO:Extended}")

      {:ok,
       socket
       |> assign(:photo_file_uuid, team.photo_file_uuid)
       |> assign(:user_role, assigns.user_role)
       |> assign(:future_edition_start_datetime, future_edition_start_datetime)}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
      <p class="mb-8">The edition that your team participates in has not been started yet!</p>

      <div class="shadow-md rounded-lg bg-white p-5">
        <p class="font-light text-2xl">
          This edition starts in
          <span class="grid-item__content count-down default"
                id="c1"
                phx-hook="Countdown"
                data-countdown-date="<%= @future_edition_start_datetime %>">
          </span>
        </p>
      </div>

      <%= if @user_role == "TeamLeader" && @photo_file_uuid == nil do %>
        <br>
        <div class="shadow-md rounded-lg bg-white p-5">
          <p class="font-light text-2xl">
            Your team has not submitted a team photo.
            Upload your team photo on the <a href="<%= Routes.team_settings_path(@socket, :index) %>">team settings</a>
            page before the edition starts please.
          </p>
        </div>
      <% end %>
    """
  end
end
