defmodule OutdoorDwa.PracticalTaskSubmissionContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.PracticalTaskSubmissionContext

  describe "practical_task_submission" do
    alias OutdoorDwa.PracticalTaskSubmissionContext.PracticalTaskSubmission

    @valid_attrs %{
      approval_state: "some approval_state",
      attemp_number: 42,
      file_uuid: "some file_uuid"
    }
    @update_attrs %{
      approval_state: "some updated approval_state",
      attemp_number: 43,
      file_uuid: "some updated file_uuid"
    }
    @invalid_attrs %{approval_state: nil, attemp_number: nil, file_uuid: nil}

    def practical_task_submission_fixture(attrs \\ %{}) do
      {:ok, practical_task_submission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PracticalTaskSubmissionContext.create_practical_task_submission()

      practical_task_submission
    end

    test "list_practical_task_submission/0 returns all practical_task_submission" do
      practical_task_submission = practical_task_submission_fixture()

      assert PracticalTaskSubmissionContext.list_practical_task_submission() == [
               practical_task_submission
             ]
    end

    test "get_practical_task_submission!/1 returns the practical_task_submission with given id" do
      practical_task_submission = practical_task_submission_fixture()

      assert PracticalTaskSubmissionContext.get_practical_task_submission!(
               practical_task_submission.id
             ) == practical_task_submission
    end

    test "create_practical_task_submission/1 with valid data creates a practical_task_submission" do
      assert {:ok, %PracticalTaskSubmission{} = practical_task_submission} =
               PracticalTaskSubmissionContext.create_practical_task_submission(@valid_attrs)

      assert practical_task_submission.approval_state == "some approval_state"
      assert practical_task_submission.attemp_number == 42
      assert practical_task_submission.file_uuid == "some file_uuid"
    end

    test "create_practical_task_submission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PracticalTaskSubmissionContext.create_practical_task_submission(@invalid_attrs)
    end

    test "update_practical_task_submission/2 with valid data updates the practical_task_submission" do
      practical_task_submission = practical_task_submission_fixture()

      assert {:ok, %PracticalTaskSubmission{} = practical_task_submission} =
               PracticalTaskSubmissionContext.update_practical_task_submission(
                 practical_task_submission,
                 @update_attrs
               )

      assert practical_task_submission.approval_state == "some updated approval_state"
      assert practical_task_submission.attemp_number == 43
      assert practical_task_submission.file_uuid == "some updated file_uuid"
    end

    test "update_practical_task_submission/2 with invalid data returns error changeset" do
      practical_task_submission = practical_task_submission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PracticalTaskSubmissionContext.update_practical_task_submission(
                 practical_task_submission,
                 @invalid_attrs
               )

      assert practical_task_submission ==
               PracticalTaskSubmissionContext.get_practical_task_submission!(
                 practical_task_submission.id
               )
    end

    test "delete_practical_task_submission/1 deletes the practical_task_submission" do
      practical_task_submission = practical_task_submission_fixture()

      assert {:ok, %PracticalTaskSubmission{}} =
               PracticalTaskSubmissionContext.delete_practical_task_submission(
                 practical_task_submission
               )

      assert_raise Ecto.NoResultsError, fn ->
        PracticalTaskSubmissionContext.get_practical_task_submission!(
          practical_task_submission.id
        )
      end
    end

    test "change_practical_task_submission/1 returns a practical_task_submission changeset" do
      practical_task_submission = practical_task_submission_fixture()

      assert %Ecto.Changeset{} =
               PracticalTaskSubmissionContext.change_practical_task_submission(
                 practical_task_submission
               )
    end
  end
end
