defmodule OutdoorDwaWeb.EditionActive do
  alias OutdoorDwa.EditionContext

  @moduledoc false

  @doc """
    Check whether or not there is an active edition, puts a flash when the edition is not active, executes the action when the edition is active
  """
  defmacro guard_edition_is_active(socket, do: action) do
    quote do
      {
        :noreply,
        case EditionContext.get_active_edition() do
          nil ->
            unquote(socket)
            |> put_flash(:error, "The edition has ended, submissions are no longer accepted.")

          _ ->
            unquote(action)
        end
      }
    end
  end
end
