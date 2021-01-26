defmodule OutdoorDwaWeb.MinioConfig do
  def video_extensions do
    Application.fetch_env!(:outdoor_dwa_web, :video_extensions)
  end

  def image_extensions do
    Application.fetch_env!(:outdoor_dwa_web, :image_extensions)
  end

  def allowed_extensions do
    video_extensions() ++ image_extensions()
  end

  def get_config(object) do
    %{
      region: Application.fetch_env!(:outdoor_dwa_web, :region),
      access_key_id: Application.fetch_env!(:outdoor_dwa_web, :access_key_id),
      secret_key: Application.fetch_env!(:outdoor_dwa_web, :secret_key),
      object: object,
      bucket: Application.fetch_env!(:outdoor_dwa_web, :bucket),
      expire_seconds: Application.fetch_env!(:outdoor_dwa_web, :expire_seconds),
      host: Application.fetch_env!(:outdoor_dwa_web, :minio_host),
      port: Application.fetch_env!(:outdoor_dwa_web, :minio_port),
      protocol: Application.fetch_env!(:outdoor_dwa_web, :protocol)
    }
  end
end
