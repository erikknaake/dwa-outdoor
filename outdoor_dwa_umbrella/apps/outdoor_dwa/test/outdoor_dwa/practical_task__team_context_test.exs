defmodule OutdoorDwa.PracticalTask_TeamContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.PracticalTask_TeamContext

  describe "practical_task_team" do
    alias OutdoorDwa.PracticalTask_TeamContext.PracticalTask_Team

    @valid_attrs %{status: "some status"}
    @update_attrs %{status: "some updated status"}
    @invalid_attrs %{status: nil}

    def practical_task__team_fixture(attrs \\ %{}) do
      {:ok, practical_task__team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PracticalTask_TeamContext.create_practical_task__team()

      practical_task__team
    end

    test "list_practical_task_team/0 returns all practical_task_team" do
      practical_task__team = practical_task__team_fixture()
      assert PracticalTask_TeamContext.list_practical_task_team() == [practical_task__team]
    end

    test "get_practical_task__team!/1 returns the practical_task__team with given id" do
      practical_task__team = practical_task__team_fixture()

      assert PracticalTask_TeamContext.get_practical_task__team!(practical_task__team.id) ==
               practical_task__team
    end

    test "create_practical_task__team/1 with valid data creates a practical_task__team" do
      assert {:ok, %PracticalTask_Team{} = practical_task__team} =
               PracticalTask_TeamContext.create_practical_task__team(@valid_attrs)

      assert practical_task__team.status == "some status"
    end

    test "create_practical_task__team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PracticalTask_TeamContext.create_practical_task__team(@invalid_attrs)
    end

    test "update_practical_task__team/2 with valid data updates the practical_task__team" do
      practical_task__team = practical_task__team_fixture()

      assert {:ok, %PracticalTask_Team{} = practical_task__team} =
               PracticalTask_TeamContext.update_practical_task__team(
                 practical_task__team,
                 @update_attrs
               )

      assert practical_task__team.status == "some updated status"
    end

    test "update_practical_task__team/2 with invalid data returns error changeset" do
      practical_task__team = practical_task__team_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PracticalTask_TeamContext.update_practical_task__team(
                 practical_task__team,
                 @invalid_attrs
               )

      assert practical_task__team ==
               PracticalTask_TeamContext.get_practical_task__team!(practical_task__team.id)
    end

    test "delete_practical_task__team/1 deletes the practical_task__team" do
      practical_task__team = practical_task__team_fixture()

      assert {:ok, %PracticalTask_Team{}} =
               PracticalTask_TeamContext.delete_practical_task__team(practical_task__team)

      assert_raise Ecto.NoResultsError, fn ->
        PracticalTask_TeamContext.get_practical_task__team!(practical_task__team.id)
      end
    end

    test "change_practical_task__team/1 returns a practical_task__team changeset" do
      practical_task__team = practical_task__team_fixture()

      assert %Ecto.Changeset{} =
               PracticalTask_TeamContext.change_practical_task__team(practical_task__team)
    end
  end
end
