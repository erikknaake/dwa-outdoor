defmodule OutdoorDwa.EditionContext.Edition do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.PracticalTaskContext.PracticalTask
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole

  schema "edition" do
    field :end_datetime, :utc_datetime
    field :is_open_for_registration, :boolean, default: false
    field :start_datetime, :utc_datetime
    field :scores_published, :boolean, default: false
    has_many :user_roles, EditionUserRole
    has_many :tracks, Track
    has_many :practical_task, PracticalTask
    has_many :team, Team
  end

  @doc false
  def changeset(edition, attrs \\ %{}) do
    edition
    |> cast(attrs, [:start_datetime, :end_datetime, :is_open_for_registration, :scores_published])
    |> validate_required([
      :start_datetime,
      :end_datetime,
      :is_open_for_registration,
      :scores_published
    ])
  end
end
