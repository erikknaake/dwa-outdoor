defmodule OutdoorDwa.PracticalTaskContext.PracticalTask do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team

  schema "practical_task" do
    field :description, :string
    field :is_published, :boolean, default: false
    field :title, :string
    field :difficulty, :string
    field :travel_credit_reward, :integer, default: 2
    has_many :practical_task_team, PracticalTask_Team
    belongs_to :edition, Edition
    timestamps()
  end

  @doc false
  def changeset(practical_task, attrs) do
    practical_task
    |> cast(attrs, [
      :title,
      :description,
      :difficulty,
      :travel_credit_reward,
      :is_published,
      :edition_id
    ])
    |> validate_required([:title, :description, :difficulty, :travel_credit_reward, :is_published])
  end
end
