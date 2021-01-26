defmodule OutdoorDwa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias OutdoorDwa.KubeCommandFactory, as: KubeCmd

  def start(_type, _args) do
    if(System.get_env("CONNECT_TO_SERVER") != nil) do
      connect_to_cluster()
    end

    children = [
      # Start the Ecto repository
      OutdoorDwa.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OutdoorDwa.PubSub},
      # Start a worker by calling: OutdoorDwa.Worker.start_link(arg)
      # {OutdoorDwa.Worker, arg}
      {Oban, oban_config()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OutdoorDwa.Supervisor)
  end

  # Conditionally disable crontab, queues, or plugins here.
  defp oban_config do
    Application.get_env(:outdoor_dwa, Oban)
  end

  defp connect_to_cluster do
    # DNS lookup
    IO.puts("Node name: #{node()}")
    node_ips = get_related_nodes()
    IO.puts("Received ips: " <> node_ips)

    # Parse IP out of nslookup result
    Regex.scan(~r/\d+\.\d+\.\d+\.\d+/, node_ips)
    |> List.flatten()
    # Filter out this container
    |> Enum.reject(fn x ->
      {own_ip, 0} = System.cmd("hostname", ["-i"])
      x == own_ip
    end)
    # Connect to other node
    |> Enum.map(fn ip ->
      Node.connect(:"phoenix@#{ip}")
    end)

    IO.puts("Connected to: ")
    IO.inspect(Node.list())
  end

  defp get_related_nodes() do
    case System.get_env("USE_KUBECTL_DISCOVERY") != nil do
      true -> get_by_kubectl_discovery()
      false -> get_by_dns()
    end
  end

  defp get_by_kubectl_discovery() do
    kubectl_pods_query =
      KubeCmd.new()
      |> KubeCmd.get_endpoints("outdoor-dwa-svc")
      |> KubeCmd.namespace("outdoor-dwa")
      |> KubeCmd.output("jsonpath='{.subsets[*].addresses[*].ip}'")
      |> KubeCmd.pipe("tr ' ' '\\n' | xargs -I % ")
      |> KubeCmd.get_pods()
      |> KubeCmd.output("jsonpath='{.items[*].status.podIP} '")
      |> KubeCmd.field_selector("status.podIP=%")
      |> KubeCmd.namespace("outdoor-dwa")
      |> KubeCmd.build()

    to_string(:os.cmd(String.to_atom(kubectl_pods_query)))
  end

  defp get_by_dns() do
    {node_ips, _} = System.cmd("nslookup", ["phoenix"])

    node_ips
  end
end
