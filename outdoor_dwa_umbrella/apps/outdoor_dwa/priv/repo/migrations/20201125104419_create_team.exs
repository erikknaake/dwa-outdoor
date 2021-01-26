defmodule OutdoorDwa.Repo.Migrations.CreateTeam do
  use Ecto.Migration

  def change do
    create table(:team) do
      add :password, :string
      add :salt, :string
      add :group_size, :integer
      add :postalcode, :string
      add :organisation_name, :string
      add :city, :string
      add :travel_credits, :integer
      add :travel_points, :integer
      add :number_of_broom_sweepers, :integer
    end
  end
end
