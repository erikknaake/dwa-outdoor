defmodule OutdoorDwaWeb.ReviewOverviewSubmissionComponent do
  use OutdoorDwaWeb, :live_component
  use Timex

  @minute_in_seconds 60
  @hour_in_seconds 3600
  @day_in_seconds 86400

  def mount(socket) do
    {:ok, socket}
  end

  defp time_since_submission(submitted_at) do
    interval = Interval.new(from: submitted_at, until: Timex.now())
    seconds = Interval.duration(interval, :seconds)

    cond do
      seconds < @minute_in_seconds ->
        generate_time_since_submission_string(seconds, "Second")

      seconds < @hour_in_seconds ->
        generate_time_since_submission_string(trunc(seconds / @minute_in_seconds), "Minute")

      seconds < @day_in_seconds ->
        generate_time_since_submission_string(trunc(seconds / @hour_in_seconds), "Hour")

      true ->
        generate_time_since_submission_string(trunc(seconds / @day_in_seconds), "Day")
    end
  end

  defp generate_time_since_submission_string(amount, singular_unit) do
    if(amount > 1) do
      "#{amount} #{singular_unit}s ago"
    else
      "#{amount} #{singular_unit} ago"
    end
  end

  defp generate_visibility_class(status) do
    case status do
      "Pending" -> ""
      _ -> "hidden"
    end
  end
end
