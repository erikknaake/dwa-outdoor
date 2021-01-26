defmodule OutdoorDwa.TravelQuestioningContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.TravelQuestioningContext

  describe "travel_questioning" do
    alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def travel_questioning_fixture(attrs \\ %{}) do
      {:ok, travel_questioning} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TravelQuestioningContext.create_travel_questioning()

      travel_questioning
    end

    test "list_travel_questioning/0 returns all travel_questioning" do
      travel_questioning = travel_questioning_fixture()
      assert TravelQuestioningContext.list_travel_questioning() == [travel_questioning]
    end

    test "get_travel_questioning!/1 returns the travel_questioning with given id" do
      travel_questioning = travel_questioning_fixture()

      assert TravelQuestioningContext.get_travel_questioning!(travel_questioning.id) ==
               travel_questioning
    end

    test "create_travel_questioning/1 with valid data creates a travel_questioning" do
      assert {:ok, %TravelQuestioning{} = travel_questioning} =
               TravelQuestioningContext.create_travel_questioning(@valid_attrs)
    end

    test "create_travel_questioning/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               TravelQuestioningContext.create_travel_questioning(@invalid_attrs)
    end

    test "update_travel_questioning/2 with valid data updates the travel_questioning" do
      travel_questioning = travel_questioning_fixture()

      assert {:ok, %TravelQuestioning{} = travel_questioning} =
               TravelQuestioningContext.update_travel_questioning(
                 travel_questioning,
                 @update_attrs
               )
    end

    test "update_travel_questioning/2 with invalid data returns error changeset" do
      travel_questioning = travel_questioning_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TravelQuestioningContext.update_travel_questioning(
                 travel_questioning,
                 @invalid_attrs
               )

      assert travel_questioning ==
               TravelQuestioningContext.get_travel_questioning!(travel_questioning.id)
    end

    test "delete_travel_questioning/1 deletes the travel_questioning" do
      travel_questioning = travel_questioning_fixture()

      assert {:ok, %TravelQuestioning{}} =
               TravelQuestioningContext.delete_travel_questioning(travel_questioning)

      assert_raise Ecto.NoResultsError, fn ->
        TravelQuestioningContext.get_travel_questioning!(travel_questioning.id)
      end
    end

    test "change_travel_questioning/1 returns a travel_questioning changeset" do
      travel_questioning = travel_questioning_fixture()

      assert %Ecto.Changeset{} =
               TravelQuestioningContext.change_travel_questioning(travel_questioning)
    end
  end
end
