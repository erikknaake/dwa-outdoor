defmodule OutdoorDwa.PracticalTaskContextTest do
  use OutdoorDwa.DataCase

  alias OutdoorDwa.PracticalTaskContext

  describe "practical_task" do
    alias OutdoorDwa.PracticalTaskContext.PracticalTask

    @valid_attrs %{
      description: "some description",
      is_published: true,
      title: "some title",
      travel_credit_reward: 42
    }
    @update_attrs %{
      description: "some updated description",
      is_published: false,
      title: "some updated title",
      travel_credit_reward: 43
    }
    @invalid_attrs %{description: nil, is_published: nil, title: nil, travel_credit_reward: nil}

    def practical_task_fixture(attrs \\ %{}) do
      {:ok, practical_task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PracticalTaskContext.create_practical_task()

      practical_task
    end

    test "list_practical_task/0 returns all practical_task" do
      practical_task = practical_task_fixture()
      assert PracticalTaskContext.list_practical_task() == [practical_task]
    end

    test "get_practical_task!/1 returns the practical_task with given id" do
      practical_task = practical_task_fixture()
      assert PracticalTaskContext.get_practical_task!(practical_task.id) == practical_task
    end

    test "create_practical_task/1 with valid data creates a practical_task" do
      assert {:ok, %PracticalTask{} = practical_task} =
               PracticalTaskContext.create_practical_task(@valid_attrs)

      assert practical_task.description == "some description"
      assert practical_task.is_published == true
      assert practical_task.title == "some title"
      assert practical_task.travel_credit_reward == 42
    end

    test "create_practical_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PracticalTaskContext.create_practical_task(@invalid_attrs)
    end

    test "update_practical_task/2 with valid data updates the practical_task" do
      practical_task = practical_task_fixture()

      assert {:ok, %PracticalTask{} = practical_task} =
               PracticalTaskContext.update_practical_task(practical_task, @update_attrs)

      assert practical_task.description == "some updated description"
      assert practical_task.is_published == false
      assert practical_task.title == "some updated title"
      assert practical_task.travel_credit_reward == 43
    end

    test "update_practical_task/2 with invalid data returns error changeset" do
      practical_task = practical_task_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PracticalTaskContext.update_practical_task(practical_task, @invalid_attrs)

      assert practical_task == PracticalTaskContext.get_practical_task!(practical_task.id)
    end

    test "delete_practical_task/1 deletes the practical_task" do
      practical_task = practical_task_fixture()
      assert {:ok, %PracticalTask{}} = PracticalTaskContext.delete_practical_task(practical_task)

      assert_raise Ecto.NoResultsError, fn ->
        PracticalTaskContext.get_practical_task!(practical_task.id)
      end
    end

    test "change_practical_task/1 returns a practical_task changeset" do
      practical_task = practical_task_fixture()
      assert %Ecto.Changeset{} = PracticalTaskContext.change_practical_task(practical_task)
    end
  end
end
