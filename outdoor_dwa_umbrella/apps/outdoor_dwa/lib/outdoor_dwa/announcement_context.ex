defmodule OutdoorDwa.AnnouncementContext do
  @moduledoc """
  The AnnouncementContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.AnnouncementContext.Announcement

  @doc """
  Returns the list of announcement.

  ## Examples

      iex> list_announcement()
      [%Announcement{}, ...]

  """
  def list_announcement do
    Announcement
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single announcement.

  Raises `Ecto.NoResultsError` if the Announcement does not exist.

  ## Examples

      iex> get_announcement!(123)
      %Announcement{}

      iex> get_announcement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_announcement!(id), do: Repo.get!(Announcement, id)

  @doc """
  Creates a announcement.

  ## Examples

      iex> create_announcement(%{field: value})
      {:ok, %Announcement{}}

      iex> create_announcement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_announcement(attrs \\ %{}) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
    |> broadcast_announcement()
  end

  @doc """
  Updates a announcement.

  ## Examples

      iex> update_announcement(announcement, %{field: new_value})
      {:ok, %Announcement{}}

      iex> update_announcement(announcement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
    |> broadcast_announcement()
  end

  def update_announcement_by_id(id, attrs) do
    announcement = get_announcement!(id)
    update_announcement(announcement, attrs)
  end

  @doc """
  Deletes a announcement.

  ## Examples

      iex> delete_announcement(announcement)
      {:ok, %Announcement{}}

      iex> delete_announcement(announcement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking announcement changes.

  ## Examples

      iex> change_announcement(announcement)
      %Ecto.Changeset{data: %Announcement{}}

  """
  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end

  def get_or_create_changeset(nil) do
    change_announcement(%Announcement{})
  end

  def get_or_create_changeset(id) do
    announcement = get_announcement!(id)
    change_announcement(announcement)
  end

  def list_announcements_by_edition_id(edition_id) do
    Announcement
    |> where([a], a.edition_id == ^edition_id)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def broadcast_announcement(result) do
    case result do
      {:ok, announcement} ->
        Phoenix.PubSub.broadcast(
          OutdoorDwa.PubSub,
          "announcement#{announcement.edition_id}",
          {:announcement, %{announcement: announcement}}
        )

        result

      _ ->
        result
    end
  end

  def subscribe(edition_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "announcement#{edition_id}")
  end
end
