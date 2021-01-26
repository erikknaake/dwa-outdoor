defmodule OutdoorDwaWeb.UploadedFileLiveComponent do
  alias OutdoorDwaWeb.MinioConfig
  alias OutdoorDwaWeb.MinioSigning
  use Phoenix.LiveComponent

  def render_image?(file_uuid) do
    Enum.member?(MinioConfig.image_extensions(), file_uuid |> Path.extname() |> String.downcase())
  end

  def signed_url(file_uuid) do
    MinioSigning.pre_signed_get_url(MinioConfig.get_config(file_uuid))
  end

  @impl true
  def render(assigns) do
    ~L"""
      <%= if render_image?(@file_uuid) do %>
        <img src="<%= signed_url(@file_uuid) %>"/>
      <% else %>
        <video autoplay controls class="w-full">
          <source src="<%= signed_url(@file_uuid) %>"/>
        </video>
      <% end %>
    """
  end
end
