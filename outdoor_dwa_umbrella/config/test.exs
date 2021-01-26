use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :outdoor_dwa, OutdoorDwa.Repo,
  username: "postgres",
  password: "postgres",
  database: "outdoor_dwa_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :outdoor_dwa_web, OutdoorDwaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure Oban
config :outdoor_dwa_web, Oban, crontab: false, queues: false, plugins: false
