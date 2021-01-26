defmodule OutdoorDwa.TeamContext.Team do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.UserContext.User
  alias OutdoorDwa.RivalContext.Rival
  alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team
  alias OutdoorDwa.TeamSettingContext.TeamSetting
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning
  alias OutdoorDwa.TeamProjectContext.TeamProject
  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.EctoHelpers

  @required_fields ~w(city group_size number_of_broom_sweepers organisation_name postalcode travel_credits travel_points team_name)a
  @optional_fields ~w(next_broom_sweeper_datetime photo_file_uuid)a
  @password_fields ~w(password password_confirmation)a
  @all_fields @required_fields ++ @optional_fields
  schema "team" do
    field :team_name, :string
    field :city, :string
    field :group_size, :integer
    field :number_of_broom_sweepers, :integer, default: 0
    field :next_broom_sweeper_datetime, :utc_datetime
    field :organisation_name, :string
    field :postalcode, :string
    field :travel_credits, :integer, default: 7
    field :travel_points, :integer, default: 0
    field :password_hash, :string
    field :photo_file_uuid, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    belongs_to :user, User
    belongs_to :edition, Edition
    has_many :rival, Rival
    has_many :team_setting, TeamSetting
    has_many :practical_task_team, PracticalTask_Team
    has_many :travel_questioning, TravelQuestioning
    has_one :team_project, TeamProject
  end

  @doc false
  def changeset(team, attrs \\ %{}) do
    team
    |> cast(attrs, @all_fields ++ @password_fields)
    |> cast_assoc(:user)
    |> cast_assoc(:edition)
    |> validate_confirmation(:password)
    |> validate_required(@required_fields ++ @password_fields)
    |> EctoHelpers.put_hash()
    |> unique_constraint(:unique_team_name, name: :unique_team_name)
  end

  def changeset_for_update(team, attrs \\ %{}) do
    team
    |> cast(attrs, @all_fields)
    |> cast_assoc(:user)
    |> cast_assoc(:edition)
    |> validate_required(@required_fields)
    |> unique_constraint(:unique_team_name, name: :unique_team_name)
  end
end
