defmodule OutdoorDwa.Repo.Migrations.AddRelationships do
  use Ecto.Migration

  def change do
    alter table(:edition_user_role) do
      add :edition_id, references(:edition)
      add :user_id, references(:users)
    end

    create unique_index(:edition_user_role, [:edition_id, :user_id])

    alter table("team") do
      add :user_id, references(:users)
      add :edition_id, references(:edition)
    end

    alter table("rival") do
      add :team_id, references(:team)
      add :rival_id, references(:team)
    end

    create unique_index(:rival, [:rival_id, :team_id])

    alter table("track") do
      add :edition_id, references(:edition)
    end

    alter table("travel_question") do
      add :track_id, references(:track)
    end

    alter table("travel_question_answer") do
      add :travel_questioning_id, references(:travel_questioning)
    end

    alter table("practical_task") do
      add :edition_id, references(:edition)
    end

    alter table("practical_task_submission") do
      add :practical_task__team_id, references(:practical_task_team)
    end

    alter table("travel_questioning") do
      add :team_id, references(:team)
      add :travel_question_id, references(:travel_question)
    end

    alter table("practical_task_team") do
      add :team_id, references(:team)
      add :practical_task_id, references(:practical_task)
    end
  end
end
