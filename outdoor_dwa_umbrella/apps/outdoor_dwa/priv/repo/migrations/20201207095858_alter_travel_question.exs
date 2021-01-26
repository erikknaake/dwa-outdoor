defmodule OutdoorDwa.Repo.Migrations.AlterTravelQuestion do
  use Ecto.Migration

  def change do
    alter table("travel_question") do
      add :track_seq_no, :integer
    end
  end
end
