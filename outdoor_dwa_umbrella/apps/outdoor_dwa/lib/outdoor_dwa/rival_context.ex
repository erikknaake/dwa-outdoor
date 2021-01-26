defmodule OutdoorDwa.RivalContext do
  @moduledoc """
  The RivalContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.RivalContext.Rival

  @doc """
  Returns the list of rival.

  ## Examples

      iex> list_rival()
      [%Rival{}, ...]

  """
  def list_rival do
    Repo.all(Rival)
  end

  @doc """
  Gets a single rival.

  Raises `Ecto.NoResultsError` if the Rival does not exist.

  ## Examples

      iex> get_rival!(123)
      %Rival{}

      iex> get_rival!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rival!(id), do: Repo.get!(Rival, id)

  @doc """
  Creates a rival.

  ## Examples

      iex> create_rival(%{field: value})
      {:ok, %Rival{}}

      iex> create_rival(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rival(team_id, rival_id) do
    %Rival{team_id: team_id, rival_id: rival_id}
    |> Rival.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a rival.

  ## Examples

      iex> update_rival(rival, %{field: new_value})
      {:ok, %Rival{}}

      iex> update_rival(rival, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rival(%Rival{} = rival, attrs) do
    rival
    |> Rival.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rival.

  ## Examples

      iex> delete_rival(rival)
      {:ok, %Rival{}}

      iex> delete_rival(rival)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rival(%Rival{} = rival) do
    Repo.delete(rival)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rival changes.

  ## Examples

      iex> change_rival(rival)
      %Ecto.Changeset{data: %Rival{}}

  """
  def change_rival(%Rival{} = rival, attrs \\ %{}) do
    Rival.changeset(rival, attrs)
  end

  def get_rival_to_delete(team_id, rival_id) do
    query =
      from r in Rival,
        where: r.team_id == ^team_id and r.rival_id == ^rival_id

    Repo.one(query)
  end
end
