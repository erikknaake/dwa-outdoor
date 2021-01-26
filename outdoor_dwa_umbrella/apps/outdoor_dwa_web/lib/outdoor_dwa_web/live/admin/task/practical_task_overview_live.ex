defmodule OutdoorDwaWeb.Admin.PracticalTaskOverviewLive do
  use OutdoorDwaWeb, {:live_view_auth, :is_co_organisator}
  alias OutdoorDwa.{PracticalTaskContext, EditionContext}

  @impl true
  def on_mount(_params, _session, socket) do
    socket
    |> assign(practical_tasks: [])
    |> assign(:active_edition, nil)
    |> assign(:is_publication_valid, false)
    |> assign(:initial_publications, [])
  end

  @impl true
  def on_authorized(socket) do
    if connected?(socket) do
      PracticalTaskContext.subscribe_as_staff()
    end

    active_edition = EditionContext.get_active_or_upcoming_edition()

    practical_tasks =
      case active_edition do
        nil -> []
        _ -> PracticalTaskContext.list_practical_task_of_edition(active_edition.id)
      end

    socket
    |> assign(practical_tasks: practical_tasks)
    |> assign(
      initial_publications:
        practical_tasks
        |> Enum.filter(fn task -> can_be_edited(task, active_edition) end)
        |> Enum.reduce(
          %{},
          fn task, acc ->
            Map.merge(acc, %{"#{task.id}" => task.is_published})
          end
        )
    )
    |> assign(:active_edition, active_edition)
  end

  defp can_be_edited(practical_task, edition) do
    !(practical_task.is_published && EditionContext.is_edition_in_progress?(edition))
  end

  @success_message "Successfully updated publications."
  @error_message "Something went wrong while updating the publications."

  def handle_event("change_publications", %{"publications" => publications}, socket) do
    authorized socket do
      {
        :noreply,
        case validate_publications(publications, socket) do
          true ->
            bool_keyed = string_keyed_to_bool_keyed(publications)

            case PracticalTaskContext.update_publications(bool_keyed) do
              :ok ->
                socket
                |> put_flash(:info, @success_message)

              {:error, _} ->
                put_flash(socket, :error, @error_message)
            end

          false ->
            socket
            |> put_flash(:error, @error_message)
        end
      }
    end
  end

  def handle_event("validate", params, socket) do
    authorized socket do
      validate(params, socket)
    end
  end

  defp validate(%{"publications" => publications}, socket) do
    {
      :noreply,
      socket
      |> assign(:is_publication_valid, validate_publications(publications, socket))
    }
  end

  defp validate(_, socket) do
    {
      :noreply,
      socket
      |> assign(:is_publication_valid, false)
    }
  end

  def submit_text(edition_started) do
    if(edition_started == nil) do
      "Change publication"
    else
      "Publish"
    end
  end

  def handle_info({:practical_task_created, practical_task}, socket) do
    socket =
      update(
        socket,
        :practical_tasks,
        fn practical_tasks -> [practical_task | practical_tasks] end
      )

    socket =
      update(
        socket,
        :initial_publications,
        fn initial_publications ->
          Map.put(initial_publications, "#{practical_task.id}", practical_task.is_published)
        end
      )

    {:noreply, socket}
  end

  @spec validate_publications([String.t()], Phoenix.Socket.t()) :: boolean
  defp validate_publications(publications, socket) do
    string_keyed_to_bool_keyed(publications) != socket.assigns.initial_publications
  end

  defp to_bool("true"), do: true
  defp to_bool("false"), do: false

  defp string_keyed_to_bool_keyed(publications) do
    publications
    |> Map.keys()
    |> Enum.map(fn key -> %{key => to_bool(publications[key])} end)
    |> Enum.reduce(&Map.merge/2)
  end

  def submit_publications_css_classes(is_publication_valid) do
    "button button--secondary mt-2 " <>
      case is_publication_valid do
        true -> ""
        false -> "button--disabled"
      end
  end
end
