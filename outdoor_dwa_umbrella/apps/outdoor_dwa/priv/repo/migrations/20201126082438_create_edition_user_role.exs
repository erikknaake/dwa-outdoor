defmodule OutdoorDwa.Repo.Migrations.CreateEditionUserRole do
  use Ecto.Migration

  def change do
    create table(:edition_user_role) do
      add :role, :string
    end
  end
end
