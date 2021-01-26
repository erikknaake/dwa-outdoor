defmodule OutdoorDwa.Repo.Migrations.AddUniqueConstraintsTravelquestioningPracticaltaskteam do
  use Ecto.Migration

  def change do
    alter table("travel_questioning") do
      modify :team_id, :id, null: false
      modify :travel_question_id, :id, null: false
      add :status, :string, default: "To Do", null: false
    end

    alter table("practical_task_team") do
      modify :team_id, :id, null: false
      modify :practical_task_id, :id, null: false
    end

    unique_index("travel_questioning", [:team_id, :travel_question_id])
    unique_index("practical_task_team", [:team_id, :practical_task_id])
  end
end
