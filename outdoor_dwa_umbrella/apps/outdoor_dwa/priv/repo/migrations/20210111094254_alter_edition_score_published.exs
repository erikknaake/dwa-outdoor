defmodule OutdoorDwa.Repo.Migrations.AlterEditionScorePublished do
  use Ecto.Migration

  def change do
    alter table(:edition) do
      add :scores_published, :boolean, default: false
    end
  end
end
