use Mix.Config

# Exists for migrator production config, phoenix uses config/runtime.exs

IO.puts("Prod config")
IO.inspect(System.get_env("COMPILE_PROD_CONFIG"))

if(System.get_env("COMPILE_PROD_CONFIG") == "true") do
  IO.puts("compiling prod config")
  config :logger, level: :info

  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :outdoor_dwa, OutdoorDwa.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
end
