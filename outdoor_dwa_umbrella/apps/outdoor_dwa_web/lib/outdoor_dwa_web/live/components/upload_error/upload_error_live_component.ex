defmodule OutdoorDwaWeb.UploadErrorLiveComponent do
  use Phoenix.LiveComponent

  defp human_readable_bytes(bytes) when bytes < 1_000, do: "#{bytes} Byte"

  defp human_readable_bytes(bytes) when bytes < 1_000_000,
    do: "#{Float.round(bytes / 1_000, 2)}KB"

  defp human_readable_bytes(bytes) when bytes < 1_000_000_000,
    do: "#{Float.round(bytes / 1_000_000, 2)}MB"

  defp human_readable_bytes(bytes), do: "#{Float.round(bytes / 1_000_000_000, 2)}GB"

  def error_to_string(:too_large, entry, max_size),
    do:
      "Selected file is #{human_readable_bytes(entry.client_size)}, which is larger than the maximum size allowed (#{
        human_readable_bytes(max_size)
      })"

  def error_to_string(:too_many_files, _, _), do: "You have selected too many files"

  def error_to_string(:external_client_failure, _, _),
    do: "The file upload server could not accept your file, it may be offline"

  def error_to_string(:not_accepted, _, _), do: "The file you selected is unsupported"

  @impl true
  def render(assigns) do
    ~L"""
      <%= for entry <- @file.entries do %>
        <%= for err <- upload_errors(@file, entry) do %>
          <div class="form form__invalid-feedback">
              <%= error_to_string(err, entry, @file.max_file_size) %>
          </div>
        <% end %>
      <% end %>
    """
  end
end
