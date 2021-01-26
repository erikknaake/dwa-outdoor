defmodule OutdoorDwa.TrackContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.TrackContext

  describe "track" do
    alias OutdoorDwa.TrackContext.Track

    @valid_attrs %{track_name: "some track_name"}
    @update_attrs %{track_name: "some updated track_name"}
    @invalid_attrs %{track_name: nil}

    def track_fixture(attrs \\ %{}) do
      {:ok, track} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TrackContext.create_track()

      track
    end

    test "list_track/0 returns all track" do
      track = track_fixture()
      assert TrackContext.list_track() == [track]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture()
      assert TrackContext.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      assert {:ok, %Track{} = track} = TrackContext.create_track(@valid_attrs)
      assert track.track_name == "some track_name"
    end

    test "create_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TrackContext.create_track(@invalid_attrs)
    end

    test "update_track/2 with valid data updates the track" do
      track = track_fixture()
      assert {:ok, %Track{} = track} = TrackContext.update_track(track, @update_attrs)
      assert track.track_name == "some updated track_name"
    end

    test "update_track/2 with invalid data returns error changeset" do
      track = track_fixture()
      assert {:error, %Ecto.Changeset{}} = TrackContext.update_track(track, @invalid_attrs)
      assert track == TrackContext.get_track!(track.id)
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture()
      assert {:ok, %Track{}} = TrackContext.delete_track(track)
      assert_raise Ecto.NoResultsError, fn -> TrackContext.get_track!(track.id) end
    end

    test "change_track/1 returns a track changeset" do
      track = track_fixture()
      assert %Ecto.Changeset{} = TrackContext.change_track(track)
    end
  end
end
