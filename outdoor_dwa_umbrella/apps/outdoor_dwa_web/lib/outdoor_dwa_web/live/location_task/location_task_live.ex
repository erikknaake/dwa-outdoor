defmodule OutdoorDwaWeb.LocationTaskLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_team_member}

  alias OutdoorDwa.TravelQuestionContext
  alias OutdoorDwa.TravelQuestioningContext
  alias OutdoorDwa.TravelQuestionAnswerContext
  alias OutdoorDwa.TeamContext
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.TravelQuestionAnswerContext.TravelQuestionAnswer
  alias OutdoorDwaWeb.AuthHelpers
  require OutdoorDwaWeb.EditionActive
  alias OutdoorDwaWeb.EditionActive

  @impl true
  def on_mount(%{"task_id" => task_id}, _session, socket) do
    case TravelQuestionContext.get_travel_question(task_id) do
      nil ->
        {:ok, redirect(socket, to: Routes.live_path(socket, OutdoorDwaWeb.TracksOverviewLive))}

      travel_question ->
        {
          :ok,
          socket
          |> assign(task_id: task_id, travel_question_answers: [])
          |> active_edition_check()
          |> mount_initial_assigns()
        }
    end
  end

  @impl true
  def on_authorized(
        %{
          assigns: %{
            task_id: task_id_assign
          }
        } = socket
      ) do
    %{edition_id: _, team_id: team_id, role: user_role} = AuthHelpers.get_token_data(socket)
    socket_with_assigns = authorized_initial_assigns(socket, team_id, task_id_assign)

    is_future_edition = TeamContext.check_if_edition_of_team_has_started(team_id)

    socket =
      assign(socket, is_future_edition: is_future_edition, team_id: team_id, user_role: user_role)

    case Map.has_key?(socket_with_assigns.assigns, :travel_questioning) do
      true ->
        if connected?(socket_with_assigns) do
          EditionContext.subscribe()
          TravelQuestionAnswerContext.subscribe(socket_with_assigns.assigns.travel_questioning.id)
          TravelQuestioningContext.subscribe(socket_with_assigns.assigns.travel_questioning.id)
        end

        socket_with_assigns

      false ->
        redirect(socket, to: Routes.live_path(socket, OutdoorDwaWeb.TracksOverviewLive))
    end
  end

  def handle_event("request_coords", %{"latitude" => latitude, "longitude" => longitude}, socket) do
    coords = %{latitude: latitude, longitude: longitude}

    {
      :reply,
      coords,
      socket
      |> assign(:coords, coords)
    }
  end

  def handle_event(
        "skip_question",
        _params,
        %{
          assigns: %{
            travel_questioning: travel_questioning_assign,
            edition_id: edition_id
          }
        } = socket
      ) do
    case EditionContext.is_progression_allowed_for_edition?(edition_id) do
      true ->
        EditionActive.guard_edition_is_active socket do
          with true <- check_if_skippable(socket),
               {:ok, travel_questioning} <-
                 TravelQuestioningContext.skip_travel_questioning(travel_questioning_assign) do
            TeamContext.broadcast_skip_question(travel_questioning.team_id)
            send(self(), {:show_polygon, {nil, false}})

            socket
            |> assign(travel_questioning: travel_questioning)
            |> put_flash(:error, "Your team successfully skipped this travel question!")
          else
            _ ->
              socket
              |> put_flash(:error, "Something went wrong, reload the page and try again!")
          end
        end

      false ->
        show_flash_on_edition_ended(socket)
    end
  end

  def handle_event(
        "save",
        %{"travel_question_answer" => params},
        %{
          assigns: %{
            travel_question: travel_question_assign,
            travel_questioning: travel_questioning_assign,
            travel_question_answers: travel_question_answers_assign,
            edition_id: edition_id
          }
        } = socket
      ) do
    case EditionContext.is_progression_allowed_for_edition?(edition_id) do
      true ->
        EditionActive.guard_edition_is_active socket do
          new_params =
            params
            |> Map.put("travel_questioning_id", travel_questioning_assign.id)
            |> Map.put("attempt_number", get_attempt_number(travel_question_answers_assign))
            |> Map.put(
              "is_correct",
              TravelQuestionContext.is_answer_correct(
                String.to_float(params["latitude"]),
                String.to_float(params["longitude"]),
                socket.assigns.task_id
              )
            )
            |> Map.put("timestamp", DateTime.utc_now())

          case TravelQuestionAnswerContext.create_travel_question_answer(
                 new_params,
                 travel_questioning_assign,
                 travel_question_assign
               ) do
            {:ok, travel_question_answer} ->
              socket
              |> handle_successful_create(travel_questioning_assign, travel_question_answer)
              |> mount_initial_assigns()

            {:error, _reason} ->
              socket
              |> put_flash(:error, "Something went wrong")
          end
        end

      false ->
        show_flash_on_edition_ended(socket)
    end
  end

  def handle_event("countdown_over", _params, socket) do
    {
      :noreply,
      socket
      |> assign(skippable: true)
    }
  end

  def handle_event("load_coords", params, socket) do
    {
      :noreply,
      push_event(socket, "load_coords", params)
    }
  end

  def handle_info(
        {:show_polygon, {travel_question_answer, on_page_load}},
        %{
          assigns: %{
            travel_question: travel_question
          }
        } = socket
      ) do
    {
      :noreply,
      push_event(
        socket,
        "show_polygon",
        %{
          on_page_load: on_page_load,
          area: travel_question.area,
          lngLat: get_correct_given_answer(travel_question_answer)
        }
      )
    }
  end

  def handle_event(
        "send_new_coords",
        %{"latitude" => latitude, "longitude" => longitude} = params,
        socket
      ) do
    send(self(), {:validate, params})

    {
      :noreply,
      socket
      |> assign(:coords, %{longitude: longitude, latitude: latitude})
    }
  end

  def handle_info({:validate, %{"latitude" => latitude, "longitude" => longitude}}, socket) do
    travel_question_answer = %{
      latitude: latitude,
      longitude: longitude
    }

    changeset =
      %TravelQuestionAnswer{}
      |> TravelQuestionAnswerContext.change_travel_question_answer(travel_question_answer)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_info({:travel_question_answer_created, travel_question_answer}, socket) do
    socket =
      update(
        socket,
        :travel_question_answers,
        fn answers -> answers ++ [travel_question_answer] end
      )

    {:noreply, socket}
  end

  def handle_info(
        {:travel_questioning_updated, travel_questioning},
        %{
          assigns: %{
            travel_question_answers: travel_question_answers
          }
        } = socket
      ) do
    if Enum.member?(["Done", "Skipped"], travel_questioning.status) do
      send(self(), {:show_polygon, {List.last(travel_question_answers), false}})
    end

    {
      :noreply,
      socket
      |> assign(travel_questioning: travel_questioning)
    }
  end

  def handle_info({:scores_published, _}, socket) do
    socket =
      socket
      |> put_flash(:info, "Edition scores have been published!")
      |> assign(progression_allowed?: false)

    {:noreply, socket}
  end

  defp handle_successful_create(socket, travel_questioning, travel_question_answer) do
    case travel_question_answer.is_correct do
      true ->
        updated_travel_questioning =
          travel_questioning
          |> Map.replace(:status, "Done")

        TravelQuestionAnswerContext.set_questioning_done(
          travel_questioning,
          travel_question_answer
        )

        send(self(), {:show_polygon, {travel_question_answer, false}})

        socket
        |> put_flash(:info, "The submitted answer is correct!")
        |> assign(travel_questioning: updated_travel_questioning)

      false ->
        updated_travel_questioning =
          travel_questioning
          |> Map.replace(:status, "Cooldown")

        %{travel_questioning_id: updated_travel_questioning.id}
        |> OutdoorDwa.UpdateCooldownQuestioning.new(
          scheduled_at:
            Timex.shift(
              travel_question_answer.timestamp,
              minutes: Application.fetch_env!(:outdoor_dwa_web, :travel_question_cooldown)
            )
        )
        |> Oban.insert()

        socket
        |> put_flash(
          :info,
          "The submitted answer is wrong! Try again in #{
            Application.fetch_env!(:outdoor_dwa_web, :travel_question_cooldown)
          } minutes."
        )
        |> assign(travel_questioning: updated_travel_questioning)
    end
  end

  defp get_attempt_number(travel_question_answers) do
    case List.last(travel_question_answers) do
      nil -> 1
      last -> last.attempt_number + 1
    end
  end

  defp authorized_initial_assigns(socket, team_id, task_id) do
    with travel_question <- TravelQuestionContext.get_travel_question(task_id),
         travel_questioning <-
           TravelQuestioningContext.find_by_team_and_task_id(team_id, task_id),
         true <- travel_questioning != nil and travel_questioning.status != "Not Bought Yet",
         travel_question_answers <- get_travel_question_answers(travel_questioning) do
      if Map.has_key?(socket.assigns, :disabled) ||
           Enum.member?(["Done", "Skipped"], travel_questioning.status) do
        send(self(), {:show_polygon, {List.last(travel_question_answers), true}})
      end

      team = TeamContext.get_team!(team_id)
      progression_allowed? = EditionContext.is_progression_allowed_for_edition?(team.edition_id)

      socket
      |> assign(
        travel_question: travel_question,
        travel_questioning: travel_questioning,
        travel_question_answers: travel_question_answers,
        team_id: team_id,
        edition_id: team.edition_id,
        progression_allowed?: progression_allowed?
      )
      |> assign_based_on_skippable()
    else
      _ -> socket
    end
  end

  defp get_travel_question_answers(travel_questioning) do
    travel_question_answers_query_result =
      TravelQuestionAnswerContext.get_answers_for_travel_questioning(travel_questioning.id)

    case travel_question_answers_query_result do
      nil -> []
      result -> result
    end
  end

  defp mount_initial_assigns(socket) do
    socket
    |> assign(
      coords: %{
        latitude: nil,
        longitude: nil
      },
      changeset:
        TravelQuestionAnswerContext.change_travel_question_answer(%TravelQuestionAnswer{})
    )
  end

  defp active_edition_check(socket) do
    case(OutdoorDwa.EditionContext.get_active_edition()) do
      nil ->
        socket
        |> put_flash(:error, "The edition has ended, submissions are no longer accepted.")
        |> assign(disabled: true)

      _ ->
        socket
    end
  end

  defp assign_based_on_skippable(socket) do
    case check_if_skippable(socket) do
      true ->
        socket
        |> assign(skippable: true)

      {false, team} ->
        socket
        |> assign(skip_countdown: team.next_broom_sweeper_datetime)
    end
  end

  defp check_if_skippable(
         %{
           assigns: %{
             team_id: team_id
           }
         } = socket
       ) do
    team = TeamContext.get_team!(team_id)

    case Timex.diff(Timex.now(), team.next_broom_sweeper_datetime, :seconds) >= 0 do
      true -> true
      false -> {false, team}
    end
  end

  def get_cooldown_end(travel_question_answers) do
    last_given_answer = List.last(travel_question_answers)

    Timex.shift(
      last_given_answer.timestamp,
      minutes: Application.fetch_env!(:outdoor_dwa_web, :travel_question_cooldown)
    )
  end

  defp show_flash_on_edition_ended(socket) do
    socket =
      put_flash(socket, :error, "The edition has ended, you cant answer location tasks anymore.")

    {:noreply,
     redirect(socket, to: Routes.location_task_path(socket, :index, socket.assigns.task_id))}
  end

  def get_correct_given_answer(travel_question_answer) do
    case travel_question_answer do
      nil -> nil
      value -> %{lat: travel_question_answer.latitude, lng: travel_question_answer.longitude}
    end
  end
end
