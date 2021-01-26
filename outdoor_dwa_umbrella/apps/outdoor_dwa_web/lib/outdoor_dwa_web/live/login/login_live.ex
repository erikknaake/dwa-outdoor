defmodule OutdoorDwaWeb.LoginLive do
  use OutdoorDwaWeb, :live_view

  alias OutdoorDwa.UserContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwaWeb.AuthHelpers

  @impl true
  def mount(params, _session, socket) do
    {
      :ok,
      socket
      |> assign(success: true, redirection: params["redirect"])
    }
  end

  @impl true
  def handle_event(
        "save",
        %{
          "login" => %{
            "name" => username,
            "password" => password
          }
        },
        socket
      ) do
    case UserContext.is_login_correct(username, password) do
      false ->
        try_login_as_team(username, password, socket)

      user ->
        handle_user_login_success(user, socket)
    end
  end

  defp try_login_as_team(username, password, socket) do
    case TeamContext.login(username, password) do
      {:ok, session_info} ->
        set_token_and_redirect(socket, session_info, Routes.task_overview_path(socket, :index))

      _ ->
        {:noreply, assign(socket, success: false)}
    end
  end

  defp handle_user_login_success(user, socket) do
    {_, session_info} = UserContext.get_current_team_role(user.id)
    set_token_and_redirect(socket, session_info, get_user_redirect_path(session_info, socket))
  end

  defp get_user_redirect_path(session_info, socket) do
    if Map.has_key?(session_info, :is_admin) && session_info.is_admin == true do
      Routes.admin_edition_overview_path(socket, :index)
    else
      case session_info.role do
        "CoOrganisator" ->
          Routes.admin_edition_overview_path(socket, :index)

        "TeamLeader" ->
          Routes.task_overview_path(socket, :index)

        "Organisator" ->
          Routes.admin_review_overview_path(socket, :index)

        "TravelGuide" ->
          Routes.admin_review_overview_path(socket, :index)

        "User" ->
          Routes.edition_overview_path(socket, :index)

        role ->
          raise "Redirect is not implemented for role: #{role}"
      end
    end
  end

  defp get_redirection(socket, to) do
    case socket.assigns.redirection do
      nil -> to
      path -> path
    end
  end

  defp set_token_and_redirect(socket, session_info, to) do
    result = AuthHelpers.send_token(socket, session_info)

    # You probably think why use message passing for this, simple if you dont only the event or the redirect is done, this way both happen
    send(self(), {:redirect, get_redirection(socket, to)})
    result
  end

  @impl true
  def handle_info({:redirect, to}, socket) do
    {:noreply, push_redirect(socket, to: to)}
  end

  def form_input_css_classes(success) do
    "form form__input" <>
      case success do
        true -> ""
        false -> " form--input-error"
      end
  end
end
