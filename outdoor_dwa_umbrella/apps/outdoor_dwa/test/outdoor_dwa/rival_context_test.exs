defmodule OutdoorDwa.RivalContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.RivalContext

  describe "rival" do
    alias OutdoorDwa.RivalContext.Rival

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def rival_fixture(attrs \\ %{}) do
      {:ok, rival} =
        attrs
        |> Enum.into(@valid_attrs)
        |> RivalContext.create_rival()

      rival
    end

    test "list_rival/0 returns all rival" do
      rival = rival_fixture()
      assert RivalContext.list_rival() == [rival]
    end

    test "get_rival!/1 returns the rival with given id" do
      rival = rival_fixture()
      assert RivalContext.get_rival!(rival.id) == rival
    end

    test "create_rival/1 with valid data creates a rival" do
      assert {:ok, %Rival{} = rival} = RivalContext.create_rival(@valid_attrs)
    end

    test "create_rival/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RivalContext.create_rival(@invalid_attrs)
    end

    test "update_rival/2 with valid data updates the rival" do
      rival = rival_fixture()
      assert {:ok, %Rival{} = rival} = RivalContext.update_rival(rival, @update_attrs)
    end

    test "update_rival/2 with invalid data returns error changeset" do
      rival = rival_fixture()
      assert {:error, %Ecto.Changeset{}} = RivalContext.update_rival(rival, @invalid_attrs)
      assert rival == RivalContext.get_rival!(rival.id)
    end

    test "delete_rival/1 deletes the rival" do
      rival = rival_fixture()
      assert {:ok, %Rival{}} = RivalContext.delete_rival(rival)
      assert_raise Ecto.NoResultsError, fn -> RivalContext.get_rival!(rival.id) end
    end

    test "change_rival/1 returns a rival changeset" do
      rival = rival_fixture()
      assert %Ecto.Changeset{} = RivalContext.change_rival(rival)
    end
  end
end
