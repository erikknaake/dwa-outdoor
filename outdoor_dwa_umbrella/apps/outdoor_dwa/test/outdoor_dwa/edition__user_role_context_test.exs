defmodule OutdoorDwa.EditionUserRoleContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.EditionUserRoleContext

  describe "edition_user_role" do
    alias OutdoorDwa.EditionUserRoleContext.EditionUserRole

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def edition__user_role_fixture(attrs \\ %{}) do
      {:ok, edition__user_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> EditionUserRoleContext.create_edition__user_role()

      edition__user_role
    end

    test "list_edition_user_role/0 returns all edition_user_role" do
      edition__user_role = edition__user_role_fixture()
      assert EditionUserRoleContext.list_edition_user_role() == [edition__user_role]
    end

    test "get_edition__user_role!/1 returns the edition__user_role with given id" do
      edition__user_role = edition__user_role_fixture()

      assert EditionUserRoleContext.get_edition__user_role!(edition__user_role.id) ==
               edition__user_role
    end

    test "create_edition__user_role/1 with valid data creates a edition__user_role" do
      assert {:ok, %EditionUserRole{} = edition__user_role} =
               EditionUserRoleContext.create_edition__user_role(@valid_attrs)
    end

    test "create_edition__user_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               EditionUserRoleContext.create_edition__user_role(@invalid_attrs)
    end

    test "update_edition__user_role/2 with valid data updates the edition__user_role" do
      edition__user_role = edition__user_role_fixture()

      assert {:ok, %EditionUserRole{} = edition__user_role} =
               EditionUserRoleContext.update_edition__user_role(edition__user_role, @update_attrs)
    end

    test "update_edition__user_role/2 with invalid data returns error changeset" do
      edition__user_role = edition__user_role_fixture()

      assert {:error, %Ecto.Changeset{}} =
               EditionUserRoleContext.update_edition__user_role(
                 edition__user_role,
                 @invalid_attrs
               )

      assert edition__user_role ==
               EditionUserRoleContext.get_edition__user_role!(edition__user_role.id)
    end

    test "delete_edition__user_role/1 deletes the edition__user_role" do
      edition__user_role = edition__user_role_fixture()

      assert {:ok, %EditionUserRole{}} =
               EditionUserRoleContext.delete_edition__user_role(edition__user_role)

      assert_raise Ecto.NoResultsError, fn ->
        EditionUserRoleContext.get_edition__user_role!(edition__user_role.id)
      end
    end

    test "change_edition__user_role/1 returns a edition__user_role changeset" do
      edition__user_role = edition__user_role_fixture()

      assert %Ecto.Changeset{} =
               EditionUserRoleContext.change_edition__user_role(edition__user_role)
    end
  end
end
