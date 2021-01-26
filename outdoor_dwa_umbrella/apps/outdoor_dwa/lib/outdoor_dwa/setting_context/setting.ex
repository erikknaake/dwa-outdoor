defmodule OutdoorDwa.SettingContext.Setting do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.TeamSettingContext.TeamSetting

  schema "setting" do
    field :setting_name, :string
    field :value_type, :string
    field :default_value, :string
    has_many :team_setting, TeamSetting
  end

  @doc false
  def changeset(setting, attrs \\ %{}) do
    setting
    |> cast(attrs, [:setting_name, :value_type])
    |> validate_required([:setting_name, :value_type])
  end
end
