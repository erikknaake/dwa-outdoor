defmodule OutdoorDwa.EditionContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.EditionContext

  describe "edition" do
    alias OutdoorDwa.EditionContext.Edition

    @valid_attrs %{
      end_datetime: "2010-04-17T14:00:00Z",
      is_open_for_registration: true,
      start_datetime: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      end_datetime: "2011-05-18T15:01:01Z",
      is_open_for_registration: false,
      start_datetime: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{end_datetime: nil, is_open_for_registration: nil, start_datetime: nil}

    def edition_fixture(attrs \\ %{}) do
      {:ok, edition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> EditionContext.create_edition()

      edition
    end

    test "list_edition/0 returns all edition" do
      edition = edition_fixture()
      assert EditionContext.list_edition() == [edition]
    end

    test "get_edition!/1 returns the edition with given id" do
      edition = edition_fixture()
      assert EditionContext.get_edition!(edition.id) == edition
    end

    test "create_edition/1 with valid data creates a edition" do
      assert {:ok, %Edition{} = edition} = EditionContext.create_edition(@valid_attrs)
      assert edition.end_datetime == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert edition.is_open_for_registration == true
      assert edition.start_datetime == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_edition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = EditionContext.create_edition(@invalid_attrs)
    end

    test "update_edition/2 with valid data updates the edition" do
      edition = edition_fixture()
      assert {:ok, %Edition{} = edition} = EditionContext.update_edition(edition, @update_attrs)
      assert edition.end_datetime == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert edition.is_open_for_registration == false
      assert edition.start_datetime == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_edition/2 with invalid data returns error changeset" do
      edition = edition_fixture()
      assert {:error, %Ecto.Changeset{}} = EditionContext.update_edition(edition, @invalid_attrs)
      assert edition == EditionContext.get_edition!(edition.id)
    end

    test "delete_edition/1 deletes the edition" do
      edition = edition_fixture()
      assert {:ok, %Edition{}} = EditionContext.delete_edition(edition)
      assert_raise Ecto.NoResultsError, fn -> EditionContext.get_edition!(edition.id) end
    end

    test "change_edition/1 returns a edition changeset" do
      edition = edition_fixture()
      assert %Ecto.Changeset{} = EditionContext.change_edition(edition)
    end
  end
end
