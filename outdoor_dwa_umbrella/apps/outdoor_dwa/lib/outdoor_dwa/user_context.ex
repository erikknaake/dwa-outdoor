defmodule OutdoorDwa.UserContext do
  @moduledoc """
  The UserContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.UserContext.User
  alias OutdoorDwa.TeamContext.Team

  alias OutdoorDwa.EditionContext.Edition
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
  alias OutdoorDwa.EctoHelpers

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @blocking_roles_co_organisator ["Organisator", "TeamLeader", "CoOrganisator"]
  @blocking_roles_travel_guide ["TravelGuide" | @blocking_roles_co_organisator]
  def list_possible_users_for_edition(edition_id, blocking_roles) do
    possible_users_query =
      from u in User,
        left_join: eur in EditionUserRole,
        on: u.id == eur.user_id and eur.edition_id == ^edition_id,
        where: is_nil(eur.role) or not (eur.role in ^blocking_roles),
        select: %{
          id: u.id,
          name: u.name,
          role: eur.role,
          eur_id: eur.id
        },
        order_by: u.id

    Repo.all(possible_users_query)
  end

  def list_possible_coorganisators_for_edition(edition_id) do
    list_possible_users_for_edition(edition_id, @blocking_roles_co_organisator)
  end

  def list_possible_travel_guides_for_edition(edition_id) do
    list_possible_users_for_edition(edition_id, @blocking_roles_travel_guide)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
    Checks whether or not the combination of username and password exists
  """
  @spec is_login_correct(String.t(), String.t()) :: false | %User{}
  def is_login_correct(username, password) do
    case Repo.one(from u in User, where: u.name == ^username) do
      nil ->
        false

      user ->
        EctoHelpers.validate_password(user, password)
    end
  end

  @type roleless_user :: %{
          user_id: integer(),
          role: String.t()
        }
  @type rolefull_user :: %{
          user_id: integer(),
          role: String.t(),
          team_id: integer() | nil,
          edition_id: integer() | nil,
          is_admin: boolean()
        }

  @doc """
    Gets the most current team and role of a user
    If there is an edition that has not ended, either the role the user has in that edition, or role = "User" when the user does not yet have a role in the edition
    If there is not an edition that has not ended role = "User"
    In case the user is a team leader the team_id will be filled, otherwise team_id = nil
  """
  @spec get_current_team_role(integer(), DateTime.t()) ::
          {:roleless, roleless_user()}
          | {:rolefull, rolefull_user()}
  def get_current_team_role(user_id, min_end_datetime \\ DateTime.utc_now()) do
    query =
      from u in User,
        left_join: t in Team,
        on: t.user_id == u.id,
        left_join: eur in EditionUserRole,
        on: eur.user_id == u.id,
        left_join: e in Edition,
        on: e.id == eur.edition_id,
        where: u.id == ^user_id and (u.is_admin or e.end_datetime > ^min_end_datetime),
        order_by: e.end_datetime,
        select: %{
          edition_id: e.id,
          role: eur.role,
          team_id: t.id,
          user_id: u.id,
          is_admin: u.is_admin
        },
        limit: 1

    result_set =
      Repo.one(query)
      |> IO.inspect()

    case result_set do
      nil ->
        {:roleless, %{user_id: user_id, role: "User"}}

      result ->
        {:rolefull, result}
    end
  end

  def get_user_by_edition_role(edition_id, role) do
    query =
      from u in User,
        join: eur in EditionUserRole,
        on: u.id == eur.user_id,
        where: eur.edition_id == ^edition_id and eur.role == ^role

    Repo.all(query)
  end

  def get_non_admins() do
    Repo.all(
      from u in User,
        where: u.is_admin == ^false
    )
  end

  def make_admin(user_id) do
    get_user!(user_id)
    |> Ecto.Changeset.change(is_admin: true)
    |> Repo.update()
  end
end
