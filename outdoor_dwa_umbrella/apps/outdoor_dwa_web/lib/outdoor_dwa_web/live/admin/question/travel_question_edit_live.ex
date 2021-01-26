defmodule OutdoorDwaWeb.Admin.TravelQuestionEditLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}
  alias OutdoorDwa.EditionContext
  alias OutdoorDwa.{TravelQuestionContext, TrackContext}
  alias OutdoorDwa.TravelQuestionContext.TravelQuestion

  @impl true
  def on_mount(params, _session, socket) do
    travel_question_id = Map.get(params, "travel_question_id", nil)
    is_create = travel_question_id == nil

    {
      :ok,
      socket
      |> assign(changeset: TravelQuestionContext.get_or_create_changeset())
      |> assign(:tracks, [])
      |> assign(:is_create, is_create)
      |> assign(:travel_question_id, travel_question_id)
    }
  end

  @impl true
  def on_authorized(socket) do
    active_edition = EditionContext.get_soonest_upcoming_edition()
    tracks = TrackContext.list_track_for_edition(active_edition.id)

    changeset = TravelQuestionContext.get_or_create_changeset(socket.assigns.travel_question_id)

    socket
    |> assign(changeset: changeset)
    |> assign(:tracks, tracks)
    |> assign(area: Jason.encode!(changeset.data.area))
  end

  def handle_event("validate", %{"travel_question" => travel_question} = _params, socket) do
    changeset =
      %TravelQuestion{}
      |> TravelQuestionContext.change_travel_question(travel_question)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_event("save", %{"travel_question" => params}, socket) do
    attrs =
      %{params | "area" => Jason.decode!(params["area"])}
      |> Map.put("id", socket.assigns.travel_question_id)
      |> update_seq_no_if_changed(socket)

    numbers_of_markers = length(attrs["area"])

    case numbers_of_markers >= 3 do
      true ->
        action_result = TravelQuestionContext.upsert_travel_question(attrs)

        case action_result do
          {:ok, _task} ->
            {
              :noreply,
              push_redirect(socket, to: Routes.admin_travel_question_overview_path(socket, :index))
            }

          {:error, %Ecto.Changeset{} = changeset} ->
            {
              :noreply,
              socket
              |> assign(changeset: changeset)
            }
        end

      false ->
        {
          :noreply,
          socket
          |> put_flash(
            :error,
            "You have to add at least 3 markers! You added #{numbers_of_markers} markers."
          )
        }
    end
  end

  defp update_seq_no_if_changed(%{"track_id" => track_id} = params, socket) do
    case is_travel_question_track_new_or_updated(String.to_integer(track_id), socket) do
      true ->
        Map.put(params, "track_seq_no", get_next_seq_no(String.to_integer(track_id)))

      false ->
        params
    end
  end

  defp is_travel_question_track_new_or_updated(
         track_id,
         %{
           assigns: %{
             is_create: is_create,
             travel_question_id: travel_question_id
           }
         }
       ) do
    case is_create do
      true ->
        true

      false ->
        current_question = TravelQuestionContext.get_travel_question(travel_question_id)
        current_question.track_id != track_id
    end
  end

  defp get_next_seq_no(track_id) do
    case TravelQuestionContext.get_last_track_question(track_id) do
      nil ->
        Integer.to_string(1)

      question ->
        Integer.to_string(question.track_seq_no + 1)
    end
  end

  def handle_info({:validate, area}, socket) do
    changeset = TravelQuestionContext.set_area(socket.assigns.changeset, area)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
    }
  end

  def handle_event(
        "new_coords",
        params,
        socket
      ) do
    send(self(), {:validate, params})
    socket_with_area = assign(socket, :area, Jason.encode!(params))

    {
      :noreply,
      socket_with_area
    }
  end
end
