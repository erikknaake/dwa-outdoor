defmodule OutdoorDwa.Repo.Migrations.CreatePracticalTask do
  use Ecto.Migration

  def change do
    create table(:practical_task) do
      add :title, :string
      add :description, :string
      add :travel_credit_reward, :integer
      add :difficulty, :string
      add :is_published, :boolean, default: false, null: false
    end
  end
end
