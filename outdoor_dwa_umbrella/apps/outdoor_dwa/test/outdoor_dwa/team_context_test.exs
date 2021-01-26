defmodule OutdoorDwa.TeamContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.TeamContext

  describe "team" do
    alias OutdoorDwa.TeamContext.Team

    @valid_attrs %{
      city: "some city",
      group_size: 42,
      number_of_broom_sweeper: 42,
      organisation_name: "some organisation_name",
      password: "some password",
      postalcode: "some postalcode",
      salt: "some salt",
      travel_credits: 42,
      travel_points: 42
    }
    @update_attrs %{
      city: "some updated city",
      group_size: 43,
      number_of_broom_sweeper: 43,
      organisation_name: "some updated organisation_name",
      password: "some updated password",
      postalcode: "some updated postalcode",
      salt: "some updated salt",
      travel_credits: 43,
      travel_points: 43
    }
    @invalid_attrs %{
      city: nil,
      group_size: nil,
      number_of_broom_sweeper: nil,
      organisation_name: nil,
      password: nil,
      postalcode: nil,
      salt: nil,
      travel_credits: nil,
      travel_points: nil
    }

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TeamContext.create_team()

      team
    end

    test "list_team/0 returns all team" do
      team = team_fixture()
      assert TeamContext.list_team() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert TeamContext.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = TeamContext.create_team(@valid_attrs)
      assert team.city == "some city"
      assert team.group_size == 42
      assert team.number_of_broom_sweeper == 42
      assert team.organisation_name == "some organisation_name"
      assert team.password == "some password"
      assert team.postalcode == "some postalcode"
      assert team.salt == "some salt"
      assert team.travel_credits == 42
      assert team.travel_points == 42
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TeamContext.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = TeamContext.update_team(team, @update_attrs)
      assert team.city == "some updated city"
      assert team.group_size == 43
      assert team.number_of_broom_sweeper == 43
      assert team.organisation_name == "some updated organisation_name"
      assert team.password == "some updated password"
      assert team.postalcode == "some updated postalcode"
      assert team.salt == "some updated salt"
      assert team.travel_credits == 43
      assert team.travel_points == 43
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = TeamContext.update_team(team, @invalid_attrs)
      assert team == TeamContext.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = TeamContext.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> TeamContext.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = TeamContext.change_team(team)
    end
  end
end
