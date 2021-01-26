defmodule OutdoorDwaWeb.AuthHelpers do
  alias Phoenix.LiveView

  def send_token(socket, session_info) do
    token = sign(session_info)

    {:noreply,
     LiveView.push_event(socket, "token", %{
       token: token,
       role: session_info.role,
       is_admin: Map.has_key?(session_info, :is_admin) && session_info.is_admin
     })}

    ## Token gets send to Token Hook
  end

  def logout(socket) do
    {:noreply, LiveView.push_event(socket, "loggedOut", %{})}
  end

  def get_token_data(socket) do
    case socket.assigns.token_session do
      nil ->
        nil

      token_session ->
        token_session
    end
  end

  # One day
  @token_expiry 86400

  def sign(token_data) do
    Phoenix.Token.sign(OutdoorDwaWeb.Endpoint, "user auth", token_data)
  end

  def verify(token) do
    Phoenix.Token.verify(OutdoorDwaWeb.Endpoint, "user auth", token, max_age: @token_expiry)
  end
end
