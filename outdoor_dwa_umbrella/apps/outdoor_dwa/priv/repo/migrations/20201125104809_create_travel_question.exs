defmodule OutdoorDwa.Repo.Migrations.CreateTravelQuestion do
  use Ecto.Migration

  def change do
    create table(:travel_question) do
      add :question, :string
      add :description, :string
      add :longitude, :float
      add :latitude, :float
      add :marge, :float
      add :travel_point_reward, :integer
      add :travel_credit_cost, :integer
    end
  end
end
