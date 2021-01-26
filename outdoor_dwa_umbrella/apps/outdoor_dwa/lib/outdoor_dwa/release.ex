defmodule OutdoorDwa.Release do
  @app :outdoor_dwa

  def migrate do
    load_app()
    Application.ensure_all_started(@app)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    if System.get_env("SKIP_SEED") != true do
      IO.puts("Running seeds")
      OutdoorDwa.Seeder.seed()
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
