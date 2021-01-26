defmodule OutdoorDwa.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :password_hash, :string
    end
  end
end
