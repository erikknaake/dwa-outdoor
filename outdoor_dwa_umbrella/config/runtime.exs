import Config
IO.puts("Runtime config")
IO.inspect(System.get_env("MIX_ENV"))

# Travel questions
config :outdoor_dwa_web,
  travel_question_cooldown: System.get_env("TRAVEL_QUESTION_COOLDOWN") || 5,
  travel_question_sweeper_cooldown: System.get_env("TRAVEL_QUESTION_SWEEPER_COOLDOWN") || 15

if System.get_env("MIX_ENV") == "prod" do
  IO.puts("Production runtime config")
  host = System.get_env("HOST") || "localhost"
  port = System.get_env("PORT") || "4000"

  origin =
    case port do
      "80" -> host
      port -> "#{host}:#{port}"
    end

  IO.puts("Origin: ")
  IO.inspect(origin)
  config :logger, level: :info

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :outdoor_dwa,
         OutdoorDwa.Repo,
         # ssl: true,
         url: database_url,
         pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :outdoor_dwa,
         Oban,
         repo: OutdoorDwa.Repo,
         crontab: [
           {"*/30 * * * *", OutdoorDwa.IncrementTravelCreditsWorker},
           {"*/7 * * * *", OutdoorDwa.ResetOverdueReviews},
           {"*/7 * * * *", OutdoorDwa.ResetOverdueProjectReviews}
         ],
         plugins: [Oban.Plugins.Pruner],
         queues: [
           default: 10
         ]

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :outdoor_dwa_web,
         OutdoorDwaWeb.Endpoint,
         http: [
           port: String.to_integer(System.get_env("PORT") || "4000"),
           transport_options: [
             socket_opts: [:inet6]
           ]
         ],
         url: [
           host: host,
           port: port
         ],
         check_origin: ["http://#{origin}", "//#{origin}", "ws://#{origin}"],
         server: true,
         secret_key_base: secret_key_base

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
end
