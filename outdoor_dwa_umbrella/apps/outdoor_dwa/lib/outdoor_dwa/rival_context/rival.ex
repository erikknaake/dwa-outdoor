defmodule OutdoorDwa.RivalContext.Rival do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.TeamContext.Team

  schema "rival" do
    belongs_to :team, Team
    belongs_to :rival, Team
  end

  @doc false
  def changeset(rival, attrs \\ %{}) do
    rival
    |> cast(attrs, [])
    |> cast_assoc(:team)
    |> cast_assoc(:rival)
    |> validate_required([])
  end
end
