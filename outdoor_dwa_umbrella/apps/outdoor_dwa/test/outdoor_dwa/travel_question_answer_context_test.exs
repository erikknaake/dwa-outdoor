defmodule OutdoorDwa.TravelQuestionAnswerContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.TravelQuestionAnswerContext

  describe "travel_question_answer" do
    alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer

    @valid_attrs %{
      attemp_number: 42,
      is_correct: true,
      latitude: 120.5,
      longitude: 120.5,
      timestamp: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      attemp_number: 43,
      is_correct: false,
      latitude: 456.7,
      longitude: 456.7,
      timestamp: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{
      attemp_number: nil,
      is_correct: nil,
      latitude: nil,
      longitude: nil,
      timestamp: nil
    }

    def travel_question_answer_fixture(attrs \\ %{}) do
      {:ok, travel_question_answer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TravelQuestionAnswerContext.create_travel_question_answer()

      travel_question_answer
    end

    test "list_travel_question_answer/0 returns all travel_question_answer" do
      travel_question_answer = travel_question_answer_fixture()
      assert TravelQuestionAnswerContext.list_travel_question_answer() == [travel_question_answer]
    end

    test "get_travel_question_answer!/1 returns the travel_question_answer with given id" do
      travel_question_answer = travel_question_answer_fixture()

      assert TravelQuestionAnswerContext.get_travel_question_answer!(travel_question_answer.id) ==
               travel_question_answer
    end

    test "create_travel_question_answer/1 with valid data creates a travel_question_answer" do
      assert {:ok, %TravelQuestionAnswer{} = travel_question_answer} =
               TravelQuestionAnswerContext.create_travel_question_answer(@valid_attrs)

      assert travel_question_answer.attemp_number == 42
      assert travel_question_answer.is_correct == true
      assert travel_question_answer.latitude == 120.5
      assert travel_question_answer.longitude == 120.5

      assert travel_question_answer.timestamp ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_travel_question_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               TravelQuestionAnswerContext.create_travel_question_answer(@invalid_attrs)
    end

    test "update_travel_question_answer/2 with valid data updates the travel_question_answer" do
      travel_question_answer = travel_question_answer_fixture()

      assert {:ok, %TravelQuestionAnswer{} = travel_question_answer} =
               TravelQuestionAnswerContext.update_travel_question_answer(
                 travel_question_answer,
                 @update_attrs
               )

      assert travel_question_answer.attemp_number == 43
      assert travel_question_answer.is_correct == false
      assert travel_question_answer.latitude == 456.7
      assert travel_question_answer.longitude == 456.7

      assert travel_question_answer.timestamp ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_travel_question_answer/2 with invalid data returns error changeset" do
      travel_question_answer = travel_question_answer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TravelQuestionAnswerContext.update_travel_question_answer(
                 travel_question_answer,
                 @invalid_attrs
               )

      assert travel_question_answer ==
               TravelQuestionAnswerContext.get_travel_question_answer!(travel_question_answer.id)
    end

    test "delete_travel_question_answer/1 deletes the travel_question_answer" do
      travel_question_answer = travel_question_answer_fixture()

      assert {:ok, %TravelQuestionAnswer{}} =
               TravelQuestionAnswerContext.delete_travel_question_answer(travel_question_answer)

      assert_raise Ecto.NoResultsError, fn ->
        TravelQuestionAnswerContext.get_travel_question_answer!(travel_question_answer.id)
      end
    end

    test "change_travel_question_answer/1 returns a travel_question_answer changeset" do
      travel_question_answer = travel_question_answer_fixture()

      assert %Ecto.Changeset{} =
               TravelQuestionAnswerContext.change_travel_question_answer(travel_question_answer)
    end
  end
end
