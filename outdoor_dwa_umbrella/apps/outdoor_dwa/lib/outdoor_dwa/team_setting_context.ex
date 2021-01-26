defmodule OutdoorDwa.TeamSettingContext do
  @moduledoc """
  The TeamSettingContext context.
  """
  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo
  alias OutdoorDwa.TeamSettingContext.TeamSetting
  alias OutdoorDwa.SettingContext.Setting

  @string_to_bool %{
    "false" => false,
    "true" => true
  }

  @topic "team_settings"
  def subscribe(team_id, setting_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{team_id}:#{setting_id}")
  end

  def broadcast_settings_changed(%{:team_id => team_id, :id => id} = updated_setting) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_id}:#",
      {:settings_changed, team_id}
    )

    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_id}:#{id}",
      {:settings_changed, team_id}
    )
  end

  @doc """
  Returns the list of non-team-related settings.
  """
  def list_settings() do
    result = Repo.all(Setting)
    result
  end

  @doc """
  Returns the list of team_settings.
  """
  def list_all_team_settings(team_id) do
    query =
      from s in Setting,
        left_join: ts in TeamSetting,
        on: s.id == ts.setting_id,
        select: %{
          id: s.id,
          name: s.setting_name,
          value_type: s.value_type,
          team_setting_id: ts.id,
          team_value: ts.value,
          team_id: ts.team_id
        },
        where: ts.team_id == ^team_id,
        order_by: [desc: ts.id]

    Repo.all(query)
  end

  @doc """
  Retrieves the team_setting to see if PDF Downloads are enabled.
  """
  @pdf_setting_name "Allow PDF Download"
  def get_pdf_setting(team_id) do
    query =
      from s in Setting,
        left_join: ts in TeamSetting,
        on: s.id == ts.setting_id,
        select: %{value: ts.value, id: ts.id},
        where: s.setting_name == @pdf_setting_name and ts.team_id == ^team_id

    Repo.one(query)
  end

  @project_purchase_setting_name "Only allow Team-Leader to buy projects"
  def get_project_purchase_setting(team_id) do
    query =
      from s in Setting,
        left_join: ts in TeamSetting,
        on: s.id == ts.setting_id,
        select: %{value: ts.value, id: ts.id},
        where: s.setting_name == @project_purchase_setting_name and ts.team_id == ^team_id

    Repo.one(query)
  end

  @doc """
  Creates team_settings for all existing settings on team creation (based on default value)
  """
  def create_new_settings_on_team_creation(team_id) do
    settings = list_settings()

    default_team_settings =
      Enum.map(settings, fn setting ->
        %{
          value: setting.default_value,
          setting_id: setting.id,
          team_id: team_id
        }
      end)

    Repo.insert_all(TeamSetting, default_team_settings)
  end

  @doc """
  Given the ID of a team_setting, and a value, update the value of the existing team_setting.
  """
  def update_boolean_setting(team_setting_id, new_value) do
    {_n, team_id_list} =
      from(ts in TeamSetting,
        where: ts.id == ^team_setting_id,
        select: %{team_id: ts.team_id, id: ts.id},
        update: [set: [value: ^new_value]]
      )
      |> Repo.update_all([])

    broadcast_settings_changed(List.first(team_id_list))
  end
end
