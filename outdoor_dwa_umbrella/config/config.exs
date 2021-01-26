# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :outdoor_dwa,
  ecto_repos: [OutdoorDwa.Repo]

config :outdoor_dwa_web,
  ecto_repos: [OutdoorDwa.Repo],
  generators: [
    context_app: :outdoor_dwa
  ]

# Configures the endpoint
config :outdoor_dwa_web,
       OutdoorDwaWeb.Endpoint,
       url: [
         host: "localhost"
       ],
       secret_key_base: "70hlWF4rxAfETkp8/HSdsx3kPMLOql8SHG5wsBnWO9xY05aNcRZUxJ0BAa+cSFT7",
       render_errors: [
         view: OutdoorDwaWeb.ErrorView,
         accepts: ~w(html json),
         layout: false
       ],
       pubsub_server: OutdoorDwa.PubSub,
       live_view: [
         signing_salt: "yafYTN58"
       ]

# Configures Elixir's Logger
config :logger,
       :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Minio
config :outdoor_dwa_web,
  region: "us-east-1",
  access_key_id: System.get_env("MINIO_ACCESS_KEY") || "minio",
  secret_key: System.get_env("MINIO_SECRET_KEY") || "minio123",
  bucket: "uploads",
  expire_seconds: 30 * 60,
  minio_host: System.get_env("MINIO_HOST") || "localhost",
  minio_port: System.get_env("MINIO_PORT") || 9000,
  protocol: "http",
  image_extensions: ~w(.jpg .jpeg .png .tiff .gif),
  video_extensions: ~w(.mp4 .ogg)

# Configure Oban
config :outdoor_dwa, Oban,
  repo: OutdoorDwa.Repo,
  crontab: [
    {"*/30 * * * *", OutdoorDwa.IncrementTravelCreditsWorker},
    {"*/7 * * * *", OutdoorDwa.ResetOverdueReviews},
    {"*/7 * * * *", OutdoorDwa.ResetOverdueProjectReviews}
  ],
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
