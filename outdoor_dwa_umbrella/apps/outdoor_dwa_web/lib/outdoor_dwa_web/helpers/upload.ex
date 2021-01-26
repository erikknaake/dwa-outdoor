defmodule OutdoorDwaWeb.Helpers.Upload do
  alias OutdoorDwaWeb.MinioSigning
  alias OutdoorDwaWeb.MinioConfig

  def pre_sign_upload(entry, socket) do
    key = "#{entry.uuid}#{Path.extname(entry.client_name)}"

    %{postURL: post_url, formData: form_data} =
      MinioSigning.pre_signed_post_policy(MinioConfig.get_config(key))

    {:ok, %{uploader: "S3", key: key, url: post_url, fields: form_data}, socket}
  end
end
