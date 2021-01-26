defmodule OutdoorDwa.TeamContext do
  @moduledoc """
  The TeamContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo
  alias OutdoorDwa.EditionUserRoleContext
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.RivalContext.Rival
  alias OutdoorDwa.{TravelQuestioningContext, TravelQuestionContext}
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion
  alias OutdoorDwa.EctoHelpers
  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.TeamSettingContext

  @topic "track_team"
  @statistics_topic "team_statistics"

  def subscribe(team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{team_id}")
  end

  def subscribe_statistics(team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@statistics_topic}:#{team_id}")
  end

  def broadcast({:ok, team}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team.id}",
      {event, team}
    )

    team
  end

  def broadcast_skip_question(team_id) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_id}",
      {:question_skipped, team_id}
    )
  end

  def broadcast_statistics({:ok, team}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@statistics_topic}:#{team.id}",
      {event, team}
    )

    team
  end

  def broadcast_statistics_questioning_change(event, team_id) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@statistics_topic}:#{team_id}",
      {event, team_id}
    )
  end

  def broadcast_question_answer_update(team_id, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{team_id}",
      {event, team_id}
    )
  end

  def broadcast({:error, _reason} = error, _event), do: error

  @doc """
  Returns the list of team.

  ## Examples

      iex> list_team()
      [%Team{}, ...]

  """
  def list_team do
    Repo.all(Team)
  end

  def buy_travel_question(%Team{} = team, %TravelQuestion{} = travel_question) do
    Repo.transaction(fn ->
      updated_team =
        team
        |> Team.changeset_for_update(%{
          travel_credits: team.travel_credits - travel_question.travel_credit_cost
        })
        |> Repo.update()

      TravelQuestioningContext.get_travel_questioning_by_question(travel_question.id, team.id)
      |> TravelQuestioningContext.update_travel_questioning(%{status: "To Do"})

      question = TravelQuestionContext.get_next_travel_question(travel_question)

      if question != nil do
        TravelQuestioningContext.create_travel_questioning(question, team)
      end

      broadcast(updated_team, :question_bought)
      broadcast_statistics(updated_team, :team_updated)
    end)
  end

  def list_ranking_teams(edition_id, team_id, team_name \\ "") do
    position_query =
      from t in Team,
        where: t.edition_id == ^edition_id,
        select: %{
          team_id: t.id,
          position: fragment("ROW_NUMBER() OVER (ORDER BY ? DESC)", t.travel_points)
        }

    like = "%#{team_name}%"

    query =
      from t in Team,
        left_join: r in Rival,
        on: t.id == r.rival_id and r.team_id == ^team_id,
        inner_join: tp in subquery(position_query),
        on: t.id == tp.team_id,
        where: (t.edition_id == ^edition_id and ilike(t.team_name, ^like)) or t.id == ^team_id,
        select: %{
          team_id: t.id,
          team_name: t.team_name,
          travel_credits: t.travel_credits,
          travel_points: t.travel_points,
          rival: fragment("CASE WHEN ? IS NULL THEN false ELSE true END", r.id),
          position: tp.position
        },
        order_by: [
          desc: t.id == ^team_id,
          desc: fragment("CASE WHEN ? IS NULL THEN false ELSE true END", r.id),
          desc: t.travel_points
        ]

    Repo.all(query)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Gets all teams participating in a specific edition.

  ## Examples

      iex> get_teams_by_edition!(1)
      %Team{}

  """
  def get_teams_by_edition(edition_id) do
    Team
    |> where([t], t.edition_id == ^edition_id)
    |> Repo.all()
  end

  @doc """
  Creates a team and the associated user role for the team leader, when one of the database actions fails, the whole transaction fails
  """
  @spec create_team(Map.t(), %Team{}) ::
          {:ok, Team.t()}
          | {:error, Team.t()}
          | {:error, EditionUserRole.t()}
  def create_team(attrs \\ %{}, initial \\ %Team{}) do
    Repo.transaction(fn ->
      team =
        initial
        |> Team.changeset(attrs)
        |> Repo.insert()

      case team do
        {:ok, result} ->
          TeamSettingContext.create_new_settings_on_team_creation(result.id)

          EditionUserRoleContext.create_edition_user_role(
            initial.edition_id,
            initial.user_id,
            "TeamLeader"
          )

          broadcast_team_count_update(initial.edition_id)
          result

        {:error, result} ->
          result
      end
    end)
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset_for_update(attrs)
    |> Repo.update()
    |> broadcast_statistics(:team_updated)
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Counts all teams in an edition
  """
  def count_teams_in_edition(edition_id) do
    Repo.one(from t in Team, where: t.edition_id == ^edition_id, select: count(t.id))
  end

  @doc """
  Increments travel credits of all teams participating
  in an active edition. Updates are broadcasted.
  """
  def increment_travel_credits_active_editions do
    active_editions =
      from(e in OutdoorDwa.EditionContext.Edition,
        where:
          e.start_datetime <= ^DateTime.utc_now() and
            e.end_datetime > ^DateTime.utc_now(),
        select: e.id
      )

    teams_in_active_edition =
      from(t in Team,
        where: t.edition_id in subquery(active_editions)
      )

    update_teams = teams_in_active_edition |> Repo.update_all(inc: [travel_credits: 1])

    if elem(update_teams, 0) > 0 do
      updated_teams = Repo.all(teams_in_active_edition)

      Enum.each(updated_teams, fn team ->
        broadcast_team_updates({:ok, team})
      end)
    end

    update_teams
  end

  def increment_travel_points_team(team_id, inc_travel_credits) do
    active_editions =
      from(e in OutdoorDwa.EditionContext.Edition,
        where:
          e.start_datetime <= ^DateTime.utc_now() and
            e.end_datetime > ^DateTime.utc_now(),
        select: e.id
      )

    team_in_active_edition =
      from(t in Team,
        where: t.edition_id in subquery(active_editions) and t.id == ^team_id
      )

    team_to_update = Repo.one(team_in_active_edition)

    updated_team =
      team_to_update
      |> update_team(%{travel_points: team_to_update.travel_points + inc_travel_credits})

    updated_team
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  @spec login(String.t(), String.t()) :: {:ok, Struct.t()} | :invalid_login
  def login(username, password) do
    case Repo.one(
           from t in Team,
             where: t.team_name == ^username
         ) do
      nil ->
        :invalid_login

      team ->
        case EctoHelpers.validate_password(team, password) do
          false ->
            :invalid_login

          team ->
            {:ok, %{role: "TeamMember", team_id: team.id, edition_id: team.edition_id}}
        end
    end
  end

  @doc """
  Returns start date if the edition has not yet been started else returns nil
  """
  def check_if_edition_of_team_has_started(team_id) do
    from(t in Team,
      join: e in Edition,
      on: e.id == t.edition_id,
      where: t.id == ^team_id and e.start_datetime > ^DateTime.utc_now(),
      select: e.start_datetime
    )
    |> Repo.one()
  end

  @doc """
  Subscribe to any updates of a specific team
  """
  def subscribe_to_team_updates(team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "team#{team_id}")
  end

  @doc """
  Subscribe to total team count changes
  """
  def subscribe_to_team_count_updates(edition_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "teamCount#{edition_id}}")
  end

  @doc """
  Broadcast changes of a specific team
  """
  def broadcast_team_updates({:ok, team}) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "team#{team.id}",
      team
    )

    team
  end

  @doc """
  Broadcast total team count changes
  """
  def broadcast_team_count_update(edition_id) do
    team_count = count_teams_in_edition(edition_id)

    if team_count != nil do
      Phoenix.PubSub.broadcast(
        OutdoorDwa.PubSub,
        "teamCount#{edition_id}}",
        %{team_count: team_count}
      )
    end
  end

  def use_team_broom_sweeper(team_id) do
    team_to_update = get_team!(team_id)

    team_to_update
    |> update_team(%{
      number_of_broom_sweepers: team_to_update.number_of_broom_sweepers + 1,
      next_broom_sweeper_datetime:
        Timex.shift(Timex.now(),
          minutes: Application.fetch_env!(:outdoor_dwa_web, :travel_question_sweeper_cooldown)
        )
    })
  end
end
