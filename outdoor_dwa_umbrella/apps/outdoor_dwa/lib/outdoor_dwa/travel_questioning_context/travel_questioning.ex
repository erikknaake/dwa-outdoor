defmodule OutdoorDwa.TravelQuestioningContext.TravelQuestioning do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion

  schema "travel_questioning" do
    field :status, :string
    belongs_to :travel_question, TravelQuestion
    belongs_to :team, Team
    has_many :travel_question_answer, TravelQuestionAnswer
  end

  @doc false
  def changeset(travel_questioning, attrs) do
    travel_questioning
    |> cast(attrs, [])
    |> validate_required([])
  end

  @doc false
  def changeset_for_update(travel_questioning, attrs \\ %{}) do
    travel_questioning
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
