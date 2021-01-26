defmodule OutdoorDwa.AnnouncementContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.AnnouncementContext

  describe "announcement" do
    alias OutdoorDwa.AnnouncementContext.Announcement

    @valid_attrs %{announcement: "some announcement"}
    @update_attrs %{announcement: "some updated announcement"}
    @invalid_attrs %{announcement: nil}

    def announcement_fixture(attrs \\ %{}) do
      {:ok, announcement} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AnnouncementContext.create_announcement()

      announcement
    end

    test "list_announcement/0 returns all announcement" do
      announcement = announcement_fixture()
      assert AnnouncementContext.list_announcement() == [announcement]
    end

    test "get_announcement!/1 returns the announcement with given id" do
      announcement = announcement_fixture()
      assert AnnouncementContext.get_announcement!(announcement.id) == announcement
    end

    test "create_announcement/1 with valid data creates a announcement" do
      assert {:ok, %Announcement{} = announcement} =
               AnnouncementContext.create_announcement(@valid_attrs)

      assert announcement.announcement == "some announcement"
    end

    test "create_announcement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AnnouncementContext.create_announcement(@invalid_attrs)
    end

    test "update_announcement/2 with valid data updates the announcement" do
      announcement = announcement_fixture()

      assert {:ok, %Announcement{} = announcement} =
               AnnouncementContext.update_announcement(announcement, @update_attrs)

      assert announcement.announcement == "some updated announcement"
    end

    test "update_announcement/2 with invalid data returns error changeset" do
      announcement = announcement_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AnnouncementContext.update_announcement(announcement, @invalid_attrs)

      assert announcement == AnnouncementContext.get_announcement!(announcement.id)
    end

    test "delete_announcement/1 deletes the announcement" do
      announcement = announcement_fixture()
      assert {:ok, %Announcement{}} = AnnouncementContext.delete_announcement(announcement)

      assert_raise Ecto.NoResultsError, fn ->
        AnnouncementContext.get_announcement!(announcement.id)
      end
    end

    test "change_announcement/1 returns a announcement changeset" do
      announcement = announcement_fixture()
      assert %Ecto.Changeset{} = AnnouncementContext.change_announcement(announcement)
    end
  end
end
