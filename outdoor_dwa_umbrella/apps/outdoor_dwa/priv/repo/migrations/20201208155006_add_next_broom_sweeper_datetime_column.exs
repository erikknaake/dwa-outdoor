defmodule OutdoorDwa.Repo.Migrations.AddNextBroomSweeperDatetimeColumn do
  use Ecto.Migration

  def change do
    alter table("team") do
      add :next_broom_sweeper_datetime, :utc_datetime
    end
  end
end
