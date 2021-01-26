defmodule OutdoorDwa.TravelQuestionContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.TravelQuestionContext

  describe "travel_question" do
    alias OutdoorDwa.TravelQuestionContext.TravelQuestion

    @valid_attrs %{
      description: "some description",
      latitude: 120.5,
      longitude: 120.5,
      marge: 120.5,
      question: "some question",
      travel_credit_cost: 42,
      travel_point_reward: 42
    }
    @update_attrs %{
      description: "some updated description",
      latitude: 456.7,
      longitude: 456.7,
      marge: 456.7,
      question: "some updated question",
      travel_credit_cost: 43,
      travel_point_reward: 43
    }
    @invalid_attrs %{
      description: nil,
      latitude: nil,
      longitude: nil,
      marge: nil,
      question: nil,
      travel_credit_cost: nil,
      travel_point_reward: nil
    }

    def travel_question_fixture(attrs \\ %{}) do
      {:ok, travel_question} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TravelQuestionContext.create_travel_question()

      travel_question
    end

    test "list_travel_question/0 returns all travel_question" do
      travel_question = travel_question_fixture()
      assert TravelQuestionContext.list_travel_question() == [travel_question]
    end

    test "get_travel_question/1 returns the travel_question with given id" do
      travel_question = travel_question_fixture()
      assert TravelQuestionContext.get_travel_question(travel_question.id) == travel_question
    end

    test "create_travel_question/1 with valid data creates a travel_question" do
      assert {:ok, %TravelQuestion{} = travel_question} =
               TravelQuestionContext.create_travel_question(@valid_attrs)

      assert travel_question.description == "some description"
      assert travel_question.latitude == 120.5
      assert travel_question.longitude == 120.5
      assert travel_question.marge == 120.5
      assert travel_question.question == "some question"
      assert travel_question.travel_credit_cost == 42
      assert travel_question.travel_point_reward == 42
    end

    test "create_travel_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               TravelQuestionContext.create_travel_question(@invalid_attrs)
    end

    test "update_travel_question/2 with valid data updates the travel_question" do
      travel_question = travel_question_fixture()

      assert {:ok, %TravelQuestion{} = travel_question} =
               TravelQuestionContext.update_travel_question(travel_question, @update_attrs)

      assert travel_question.description == "some updated description"
      assert travel_question.latitude == 456.7
      assert travel_question.longitude == 456.7
      assert travel_question.marge == 456.7
      assert travel_question.question == "some updated question"
      assert travel_question.travel_credit_cost == 43
      assert travel_question.travel_point_reward == 43
    end

    test "update_travel_question/2 with invalid data returns error changeset" do
      travel_question = travel_question_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TravelQuestionContext.update_travel_question(travel_question, @invalid_attrs)

      assert travel_question == TravelQuestionContext.get_travel_question(travel_question.id)
    end

    test "delete_travel_question/1 deletes the travel_question" do
      travel_question = travel_question_fixture()

      assert {:ok, %TravelQuestion{}} =
               TravelQuestionContext.delete_travel_question(travel_question)

      assert_raise Ecto.NoResultsError, fn ->
        TravelQuestionContext.get_travel_question(travel_question.id)
      end
    end

    test "change_travel_question/1 returns a travel_question changeset" do
      travel_question = travel_question_fixture()
      assert %Ecto.Changeset{} = TravelQuestionContext.change_travel_question(travel_question)
    end
  end
end
