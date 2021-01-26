defmodule OutdoorDwa.TeamSettingContext.TeamSetting do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.SettingContext.Setting

  schema "team_setting" do
    field :value, :string
    belongs_to :team, Team
    belongs_to :setting, Setting
  end

  @doc false
  def changeset(team_setting, attrs \\ %{}) do
    team_setting
    |> cast(attrs, [:value, :team_id, :setting_id])
    |> validate_required([:status, :practical_task_id, :team_id])
  end
end
