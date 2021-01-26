defmodule OutdoorDwa.TrackContext do
  @moduledoc """
  The TrackContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo

  alias OutdoorDwa.TrackContext.Track
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning

  @doc """
  Returns the list of track.

  ## Examples

      iex> list_track()
      [%Track{}, ...]

  """
  def list_track do
    Repo.all(Track)
    |> Repo.preload(:edition)
  end

  def list_track_for_edition(edition_id) do
    Repo.all(from t in Track, where: t.edition_id == ^edition_id)
  end

  def list_tracks_by_edition(edition_id, team_id) do
    query =
      from t in Track,
        where: t.edition_id == ^edition_id,
        preload: [
          travel_question: [
            travel_questioning: ^from(tq in TravelQuestioning, where: tq.team_id == ^team_id)
          ]
        ]

    Repo.all(query)
  end

  @doc """
  Gets a single track.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get_track!(123)
      %Track{}

      iex> get_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_track!(id), do: Repo.get!(Track, id)

  @doc """
  Creates a track.

  ## Examples

      iex> create_track(%{field: value})
      {:ok, %Track{}}

      iex> create_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_track(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update_track(track, %{field: new_value})
      {:ok, %Track{}}

      iex> update_track(track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_track(%Track{} = track, attrs) do
    track
    |> Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete_track(track)
      {:ok, %Track{}}

      iex> delete_track(track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_track(%Track{} = track) do
    Repo.delete(track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change_track(track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change_track(%Track{} = track, attrs \\ %{}) do
    Track.changeset(track, attrs)
  end

  def create_edition_tracks(edition_id, tracks) do
    Repo.transaction(fn ->
      for track_name <- tracks do
        %Track{track_name: track_name, edition_id: edition_id}
        |> Repo.insert!()
      end
    end)
  end
end
