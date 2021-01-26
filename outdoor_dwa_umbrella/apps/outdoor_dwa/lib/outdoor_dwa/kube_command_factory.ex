defmodule OutdoorDwa.KubeCommandFactory do
  def new(base \\ nil, pipe_operation \\ "") do
    if base == nil do
      %{
        program: "kubectl",
        args: [],
        pipe_operation: pipe_operation,
        prev: nil
      }
    end

    %{
      program: "kubectl",
      args: [],
      pipe_operation: pipe_operation,
      prev: base
    }
  end

  def get_pods(command) do
    add_arg(command, get("pods"))
  end

  def get_services(command) do
    add_arg(command, get("services"))
  end

  def get_endpoints(command, name) do
    add_arg(command, get("endpoints " <> name))
  end

  def get_endpoints(command) do
    add_arg(command, get("endpoints"))
  end

  def namespace(command, namespace) do
    add_arg(command, "-n " <> namespace)
  end

  def output(command, output) do
    add_arg(command, "-o=" <> output)
  end

  def field_selector(command, field_selector) do
    add_arg(command, "--field-selector=" <> field_selector)
  end

  def pipe(command, pipe_operation \\ "xargs -I % ") do
    new(command, pipe_operation)
  end

  def build(command, suffix \\ "") do
    formatted_cmd = command.program <> " " <> (command.args |> Enum.join(" ")) <> suffix

    case command.prev do
      nil -> formatted_cmd
      prev -> build(prev, " | " <> command.pipe_operation <> formatted_cmd)
    end
  end

  defp add_arg(command, new_arg) do
    Map.put(command, :args, command[:args] ++ [new_arg])
  end

  defp get(type) do
    "get " <> type
  end
end
