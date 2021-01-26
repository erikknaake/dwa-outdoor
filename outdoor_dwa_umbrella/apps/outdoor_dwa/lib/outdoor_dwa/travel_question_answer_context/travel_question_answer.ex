defmodule OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning

  schema "travel_question_answer" do
    field :attempt_number, :integer
    field :is_correct, :boolean, default: false
    field :latitude, :float
    field :longitude, :float
    field :timestamp, :utc_datetime

    belongs_to :travel_questioning, TravelQuestioning
  end

  @doc false
  def changeset(travel_question_answer, attrs) do
    travel_question_answer
    |> cast(attrs, [
      :travel_questioning_id,
      :attempt_number,
      :longitude,
      :latitude,
      :is_correct,
      :timestamp
    ])
    |> validate_required([
      :travel_questioning_id,
      :attempt_number,
      :longitude,
      :latitude,
      :is_correct,
      :timestamp
    ])
  end

  @doc false
  def submit_answer_changeset(travel_question_answer, attrs) do
    travel_question_answer
    |> cast(attrs, [
      :travel_questioning_id,
      :attempt_number,
      :longitude,
      :latitude,
      :is_correct,
      :timestamp
    ])
    |> validate_required([:longitude, :latitude])
  end
end
