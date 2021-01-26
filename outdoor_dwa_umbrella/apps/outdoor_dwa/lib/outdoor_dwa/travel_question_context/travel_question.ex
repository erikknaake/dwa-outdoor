defmodule OutdoorDwa.TravelQuestionContext.TravelQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning

  schema "travel_question" do
    field :description, :string
    field :area, {:array, :map}
    field :question, :string
    field :travel_credit_cost, :integer, default: 2
    field :travel_point_reward, :integer, default: 2
    field :track_seq_no, :integer

    has_many :travel_questioning, TravelQuestioning
    belongs_to :track, Track
  end

  @doc false
  def changeset(travel_question, attrs) do
    travel_question
    |> cast(attrs, [
      :question,
      :description,
      :area,
      :travel_point_reward,
      :travel_credit_cost,
      :track_id,
      :track_seq_no
    ])
    |> validate_required([
      :question,
      :description,
      :area,
      :travel_point_reward,
      :travel_credit_cost,
      :track_id
    ])
    |> validate_number(:travel_point_reward, greater_than: 0)
    |> validate_number(:travel_credit_cost, greater_than: 0)
  end
end
