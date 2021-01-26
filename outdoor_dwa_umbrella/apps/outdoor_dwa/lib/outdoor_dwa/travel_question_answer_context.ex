defmodule OutdoorDwa.TravelQuestionAnswerContext do
  @moduledoc """
  The TravelQuestionAnswerContext context.
  """

  import Ecto.Query, warn: false
  alias OutdoorDwa.Repo
  alias OutdoorDwa.TravelQuestioningContext.TravelQuestioning

  alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
  alias OutdoorDwa.TravelQuestioningContext
  alias OutdoorDwa.TeamContext

  @topic "travel_question_answer"
  def subscribe(travel_questioning_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "#{@topic}:#{travel_questioning_id}")
  end

  def broadcast({:ok, travel_question_answer}, event) do
    Phoenix.PubSub.broadcast(
      OutdoorDwa.PubSub,
      "#{@topic}:#{travel_question_answer.travel_questioning_id}",
      {event, travel_question_answer}
    )

    travel_question_answer
  end

  @doc """
  Returns the list of travel_question_answer.

  ## Examples

      iex> list_travel_question_answer()
      [%TravelQuestionAnswer{}, ...]

  """
  def list_travel_question_answer do
    Repo.all(TravelQuestionAnswer)
  end

  @doc """
  Gets a single travel_question_answer.

  Raises `Ecto.NoResultsError` if the Travel question answer does not exist.

  ## Examples

      iex> get_travel_question_answer!(123)
      %TravelQuestionAnswer{}

      iex> get_travel_question_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_travel_question_answer!(id), do: Repo.get!(TravelQuestionAnswer, id)

  @doc """
  Creates a travel_question_answer.

  ## Examples

      iex> create_travel_question_answer(%{field: value})
      {:ok, %TravelQuestionAnswer{}}

      iex> create_travel_question_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_travel_question_answer(attrs \\ %{}, travel_questioning, travel_question) do
    Repo.transaction(fn ->
      travel_question_answer =
        %TravelQuestionAnswer{}
        |> TravelQuestionAnswer.changeset(attrs)
        |> Repo.insert()

      case attrs["is_correct"] do
        true ->
          team =
            TeamContext.increment_travel_points_team(
              travel_questioning.team_id,
              travel_question.travel_point_reward
            )

          TravelQuestioningContext.update_travel_questioning(travel_questioning, %{
            status: "Done"
          })

        false ->
          TravelQuestioningContext.update_travel_questioning(travel_questioning, %{
            status: "Cooldown"
          })
      end

      TeamContext.broadcast_question_answer_update(
        travel_questioning.team_id,
        :travel_question_answer_created
      )

      broadcast(travel_question_answer, :travel_question_answer_created)
    end)
  end

  def set_questioning_done(travel_questioning, latest_travel_question_answer) do
    TravelQuestioningContext.update_travel_questioning(travel_questioning, %{status: "Done"})
    broadcast({:ok, latest_travel_question_answer}, :travel_question_answer_created)
  end

  @doc """
  Updates a travel_question_answer.

  ## Examples

      iex> update_travel_question_answer(travel_question_answer, %{field: new_value})
      {:ok, %TravelQuestionAnswer{}}

      iex> update_travel_question_answer(travel_question_answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_travel_question_answer(%TravelQuestionAnswer{} = travel_question_answer, attrs) do
    travel_question_answer
    |> TravelQuestionAnswer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a travel_question_answer.

  ## Examples

      iex> delete_travel_question_answer(travel_question_answer)
      {:ok, %TravelQuestionAnswer{}}

      iex> delete_travel_question_answer(travel_question_answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_travel_question_answer(%TravelQuestionAnswer{} = travel_question_answer) do
    Repo.delete(travel_question_answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking travel_question_answer changes.

  ## Examples

      iex> change_travel_question_answer(travel_question_answer)
      %Ecto.Changeset{data: %TravelQuestionAnswer{}}

  """
  def change_travel_question_answer(
        %TravelQuestionAnswer{} = travel_question_answer,
        attrs \\ %{}
      ) do
    TravelQuestionAnswer.submit_answer_changeset(travel_question_answer, attrs)
  end

  def get_answers_for_travel_questioning(travel_questioning_id) do
    Repo.all(
      from tqa in TravelQuestionAnswer,
        where: tqa.travel_questioning_id == ^travel_questioning_id
    )
  end

  @doc """
  Subscribe to new answer
  """
  def subscribe_to_new_answer(team_id) do
    Phoenix.PubSub.subscribe(OutdoorDwa.PubSub, "answer#{team_id}")
  end

  @doc """
  Broadcast new answer
  """
  def broadcast_new_answer(travel_question_answer) do
    if {:ok, result} = travel_question_answer do
      team_id =
        from(t in TravelQuestioning,
          where: t.id == ^travel_question_answer.travel_questioning_id,
          select: t.team_id
        )
        |> Repo.one()

      if team_id != nil do
        Phoenix.PubSub.broadcast(
          OutdoorDwa.PubSub,
          "answer#{team_id}",
          %{new_answer_team_id: team_id}
        )
      end
    end

    travel_question_answer
  end
end
