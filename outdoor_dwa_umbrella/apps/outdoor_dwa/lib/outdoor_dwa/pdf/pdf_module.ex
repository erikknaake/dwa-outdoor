defmodule OutdoorDwa.PdfModule do
  alias OutdoorDwa.PracticalTaskContext
  alias OutdoorDwa.EditionContext

  @a4_width 595
  @x_margin 50
  @page_starting_height 780
  @line_width 20
  @font_size 10
  @page_number_coord {@a4_width - @x_margin, 20}

  def generate_pdf?(edition_id, most_recent_update_date) do
    pdf_folder_path = get_pdf_folder_path()
    file_name = "Edition_#{edition_id}_tasks.pdf"
    file_path = Path.join(pdf_folder_path, "Edition_#{edition_id}_tasks.pdf")
    exists = File.exists?(file_path)

    if(!exists) do
      edition = EditionContext.get_edition(edition_id)
      tasks = PracticalTaskContext.list_practical_task_of_edition(edition_id)
      create_edition_pdf(edition, tasks, file_path)
    else
      {:ok, info} = File.stat(file_path)

      if Timex.before?(info.mtime, most_recent_update_date) do
        tasks = PracticalTaskContext.list_practical_task_of_edition(edition_id)
        edition = EditionContext.get_edition(edition_id)
        create_edition_pdf(edition, tasks, file_path)
      end
    end

    file_name
  end

  defp create_edition_pdf(edition, tasks, path) do
    {:ok, pdf} = Pdf.new(size: :a4)

    pdf
    |> Pdf.set_info(title: "Edition #{edition.id} practical tasks")
    |> set_new_page_options()
    |> add_title_page(edition)
    |> add_tasks(tasks)
    |> Pdf.write_to(path)
    |> Pdf.cleanup()
  end

  defp set_new_page_options(pid) do
    pid
    |> Pdf.set_font("Helvetica", @font_size)
    |> Pdf.set_line_width(@line_width)
    |> set_page_number
    |> Pdf.set_cursor(@page_starting_height)
  end

  defp add_title_page(pid, edition) do
    {:ok, start_date} = Timex.format(edition.start_datetime, "%Y-%m-%d", :strftime)
    {:ok, end_date} = Timex.format(edition.end_datetime, "%Y-%m-%d", :strftime)

    pid
    |> Pdf.text_at({150, 600}, "Doe Opdrachten", font_size: 40)
    |> Pdf.text_at({250, 230}, "Editie #{edition.id}", font_size: 20)
    |> Pdf.text_at({170, 200}, "#{start_date}   -   #{end_date}", font_size: 20)
    |> Pdf.add_page(:a4)
    |> set_new_page_options()
  end

  defp add_tasks(pid, tasks) do
    pid
    |> add_task_from_list(tasks)
  end

  defp add_task_from_list(pid, [task | remaining_tasks]) do
    new_page?(pid)
    cursor = Pdf.cursor(pid)

    pid
    |> Pdf.text_at({@x_margin, cursor}, task.title, bold: true, font_size: 16)
    |> Pdf.move_down(0)
    |> add_text(HtmlSanitizeEx.strip_tags(task.description))
    |> add_task_from_list(remaining_tasks)
  end

  defp add_task_from_list(pid, []), do: pid

  defp add_text(pid, text) do
    new_page?(pid)
    cursor = Pdf.cursor(pid)

    case Pdf.text_wrap(pid, {@x_margin, cursor}, {400, 10}, text) do
      {pid, :complete} ->
        pid
        # TODO: Make this customizable per task
        |> Pdf.text_at({@x_margin, cursor - 30}, "Je moet een foto inleveren", font_size: 8)
        |> Pdf.line({0, cursor - 40}, {@a4_width, cursor - 40})
        |> Pdf.fill()
        |> Pdf.move_down(30)

      {pid, remaining} ->
        add_text(pid, remaining)
    end
  end

  defp new_page?(pid) do
    cursor = Pdf.cursor(pid)

    cond do
      cursor < 150 ->
        Pdf.add_page(pid, :a4)
        |> set_new_page_options()

      true ->
        pid
    end
  end

  defp set_page_number(pid) do
    page_number = Pdf.page_number(pid)
    Pdf.text_at(pid, @page_number_coord, "#{page_number}")
  end

  # If user gets redirected to taskboard from login, the path is different from refreshing the page.
  defp get_pdf_folder_path do
    path =
      Path.absname("./")
      |> Path.split()

    filtered_path = Enum.filter(path, fn x -> x != "apps" && x != "outdoor_dwa" end)

    new_path =
      filtered_path ++ ["apps", "outdoor_dwa_web", "priv", "static", "practical_task_pdf"]

    Path.join(new_path)
  end
end
