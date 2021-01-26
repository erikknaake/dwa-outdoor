defmodule OutdoorDwaWeb.AuthenticatedLive do
  def __using__(required_auth_level) do
    quote do
      @behaviour OutdoorDwaWeb.Authenticated

      import OutdoorDwa.UserContext

      use Phoenix.LiveView,
        layout: {OutdoorDwaWeb.LayoutView, "live_auth.html"}

      @doc """
        Assigns the token values to a state which can be interpret as not authorized
        This makes sure that functions that rely on checking authorization will not fire when not supposed to
      """
      @impl true
      def mount(params, session, socket) do
        delegate_result =
          socket
          |> assign(token_session: nil)
          |> delegate_mount(params, session)

        if(is_tuple(delegate_result)) do
          delegate_result
        else
          {:ok, delegate_result}
        end
      end

      @impl true
      def handle_params(_params, url, socket) do
        {
          :noreply,
          socket
          |> assign(url: URI.parse(url).path)
        }
      end

      #        Allows implementer to hook on mount, notice this should not expose sensitive information since the socket is yet to be authenticated
      #        Implementers should implement on_mount/3 which signature matches Phoenix.LiveView.mount
      defp delegate_mount(socket, params, session) do
        if function_exported?(__MODULE__, :on_mount, 3) do
          __MODULE__.on_mount(params, session, socket)
        else
          socket
        end
      end

      @doc """
        Handles the receiving of a token by either redirecting the user when the token is invalid or assigning the token data
        Allows implementers to hook when the token is valid.
      """
      @impl true
      def handle_event("AuthenticateToken", %{"token" => token}, socket) do
        case OutdoorDwaWeb.AuthHelpers.verify(token) do
          {:ok, token_session} ->
            if validate_auth_level(token_session, unquote(required_auth_level)) do
              {
                :noreply,
                socket
                |> assign(token_session: token_session)
                |> delegate_auth_completed()
              }
            else
              {:noreply, redirect_unauthed(socket)}
            end

          _ ->
            {:noreply, redirect_unauthed(socket)}
        end
      end

      #      Gives implementers of this module a chance to hook when the user is confirmed to be authorized.
      #      This can be used to assign sensitive data to the socket that should not be available to unauthorized users.
      #
      #      An implementer that wants to use this should implement the on_authorized(Phoenix.Socket.t()) :: Phoenix.Socket.t() function
      @spec delegate_auth_completed(Phoenix.Socket.t()) :: Phoenix.Socket.t()
      defp delegate_auth_completed(socket) do
        if function_exported?(__MODULE__, :on_authorized, 1) do
          __MODULE__.on_authorized(socket)
        else
          socket
        end
      end

      @doc """
        Redirects the socket to where it is not needed to be authorized
      """
      def redirect_unauthed(socket) do
        push_redirect(socket, to: "/login?redirect=#{socket.assigns.url}")
      end

      @type auth_level ::
              :has_token
              | :is_team_leader
              | :is_travel_guide
              | :is_organisator
              | :is_admin
              | :is_team_member
              | :has_user
              | :is_co_organisator
              | :is_co_organisator_or_admin

      @spec validate_auth_level(Struct.t(), auth_level()) :: boolean()
      defp validate_auth_level(token_session, auth_level) do
        case auth_level do
          :has_token ->
            true

          :has_user ->
            token_session.user_id != nil

          :is_team_member ->
            token_session.role == "TeamMember" || token_session.role == "TeamLeader"

          :is_team_leader ->
            token_session.role == "TeamLeader" && token_session.user_id != nil

          :is_travel_guide ->
            (token_session.role == "TravelGuide" || token_session.role == "Organisator" ||
               token_session.role == "CoOrganisator") && token_session.user_id != nil

          :is_co_organisator ->
            is_co_organisator(token_session)

          :is_organisator ->
            token_session.role == "Organisator" && token_session.user_id != nil

          :is_admin ->
            is_admin(token_session)

          :is_co_organisator_or_admin ->
            is_admin(token_session) || is_co_organisator(token_session)

          _ ->
            raise "Not implemented yet"
        end
      end

      defp is_admin(token_session) do
        token_session.is_admin == true && token_session.user_id != nil
      end

      defp is_co_organisator(token_session) do
        (token_session.role == "CoOrganisator" || token_session.role == "Organisator") &&
          token_session.user_id != nil
      end

      @doc """
        Returns true when the socket is authorized, otherwise false
      """
      @spec is_user_authorized(Phoenix.Socket.t(), auth_level()) :: boolean()
      def is_user_authorized(socket, auth_level) do
        case socket.assigns.token_session == nil do
          true ->
            false

          false ->
            validate_auth_level(socket.assigns.token_session, auth_level)
        end
      end

      @doc """
        Fires action only when the socket is found to be authorized
      """
      @spec authorized(Phoenix.Socket.t(), auth_level(), any()) :: any()
      defmacro authorized(socket, auth_level \\ unquote(required_auth_level), do: action) do
        quote do
          if(is_user_authorized(unquote(socket), unquote(auth_level)), do: unquote(action))
        end
      end
    end
  end
end
