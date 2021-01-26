defmodule OutdoorDwa.EditionUserRoleContext do
  @moduledoc """
  The EditionUserRoleContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole

  @doc """
  Returns the list of edition_user_role.

  ## Examples

      iex> list_edition_user_role()
      [%EditionUserRole{}, ...]

  """
  def list_edition_user_role do
    Repo.all(EditionUserRole)
  end

  @doc """
  Gets a single edition__user_role.

  Raises `Ecto.NoResultsError` if the Edition  user role does not exist.

  ## Examples

      iex> get_edition__user_role!(123)
      %EditionUserRole{}

      iex> get_edition__user_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_edition__user_role!(id), do: Repo.get!(EditionUserRole, id)

  @doc """
  Creates a edition__user_role.

  ## Examples

      iex> create_edition__user_role(%{field: value})
      {:ok, %EditionUserRole{}}

      iex> create_edition__user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_edition_user_role(edition_id, user_id, role) do
    %EditionUserRole{edition_id: edition_id, user_id: user_id, role: role}
    |> EditionUserRole.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a edition__user_role.

  ## Examples

      iex> update_edition__user_role(edition__user_role, %{field: new_value})
      {:ok, %EditionUserRole{}}

      iex> update_edition__user_role(edition__user_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_edition__user_role(%EditionUserRole{} = edition__user_role, attrs) do
    edition__user_role
    |> EditionUserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a edition__user_role.

  ## Examples

      iex> delete_edition__user_role(edition__user_role)
      {:ok, %EditionUserRole{}}

      iex> delete_edition__user_role(edition__user_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_edition__user_role(%EditionUserRole{} = edition__user_role) do
    Repo.delete(edition__user_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking edition__user_role changes.

  ## Examples

      iex> change_edition__user_role(edition__user_role)
      %Ecto.Changeset{data: %EditionUserRole{}}

  """
  def change_edition__user_role(%EditionUserRole{} = edition__user_role, attrs \\ %{}) do
    EditionUserRole.changeset(edition__user_role, attrs)
  end

  def update_existing_role(edition_user_role_id, role) do
    {_n, user_id_list} =
      from(eur in EditionUserRole,
        where: eur.id == ^edition_user_role_id,
        select: eur,
        update: [set: [role: ^role]]
      )
      |> Repo.update_all([])

    {:ok, hd(user_id_list)}
  end
end
