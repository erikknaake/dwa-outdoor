defmodule OutdoorDwa.TrackContext.Track do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion

  schema "track" do
    field :track_name, :string
    belongs_to :edition, Edition
    has_many :travel_question, TravelQuestion
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:track_name])
    |> validate_required([:track_name])
  end
end
