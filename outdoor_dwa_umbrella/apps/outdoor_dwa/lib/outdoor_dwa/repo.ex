defmodule OutdoorDwa.Repo do
  use Ecto.Repo,
    otp_app: :outdoor_dwa,
    adapter: Ecto.Adapters.Postgres
end
