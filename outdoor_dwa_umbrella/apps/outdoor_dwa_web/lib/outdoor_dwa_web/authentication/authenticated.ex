defmodule OutdoorDwaWeb.Authenticated do
  @callback on_mount(
              params :: map() | :not_mounted_at_router,
              session :: map(),
              socket :: Phoenix.LiveView.Socket.t()
            ) ::
              Phoenix.Socket.t()
              | {
                  :ok,
                  Phoenix.Socket.t()
                }
              | {
                  :ok,
                  Phoenix.LiveView.Socket.t(),
                  keyword()
                }

  @callback on_authorized(socket :: Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()

  @optional_callbacks on_mount: 3, on_authorized: 1
end
