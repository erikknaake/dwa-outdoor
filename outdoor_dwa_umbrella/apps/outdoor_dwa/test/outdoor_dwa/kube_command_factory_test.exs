defmodule OutdoorDwa.KubeCommandFactoryTest do
  use OutdoorDwa.DataCase
  alias OutdoorDwa.KubeCommandFactory, as: KubeCmd

  describe "commands" do
    test "should build basic command" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_pods()
        |> KubeCmd.output("wide")
        |> KubeCmd.build()

      assert cmd == "kubectl get pods -o=wide"
    end

    test "should support jsonpath output" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_endpoints()
        |> KubeCmd.output("jsonpath='{.subsets[*].addresses[*].ip}'")
        |> KubeCmd.build()

      assert cmd == "kubectl get endpoints -o=jsonpath='{.subsets[*].addresses[*].ip}'"
    end

    test "should support field selector option" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_endpoints()
        |> KubeCmd.field_selector("status.podIP=%'")
        |> KubeCmd.build()

      assert cmd == "kubectl get endpoints --field-selector=status.podIP=%'"
    end

    test "should support namespace option" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_endpoints()
        |> KubeCmd.output("jsonpath='{.subsets[*].addresses[*].ip}'")
        |> KubeCmd.namespace("outdoor-dwa")
        |> KubeCmd.build()

      assert cmd ==
               "kubectl get endpoints -o=jsonpath='{.subsets[*].addresses[*].ip}' -n outdoor-dwa"
    end
  end

  describe "nested commands" do
    test "should allow piping multiple commands" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_endpoints("outdoor-dwa-svc")
        |> KubeCmd.namespace("outdoor-dwa")
        |> KubeCmd.pipe()
        |> KubeCmd.get_pods()
        |> KubeCmd.field_selector("status.podIP=%")
        |> KubeCmd.namespace("outdoor-dwa")
        |> KubeCmd.build()

      assert cmd ==
               "kubectl get endpoints outdoor-dwa-svc -n outdoor-dwa | xargs -I % kubectl get pods --field-selector=status.podIP=% -n outdoor-dwa"
    end

    test "should support custom pipe" do
      cmd =
        KubeCmd.new()
        |> KubeCmd.get_endpoints("outdoor-dwa-svc")
        |> KubeCmd.namespace("outdoor-dwa")
        |> KubeCmd.output("jsonpath='{.subsets[*].addresses[*].ip}'")
        |> KubeCmd.pipe("tr ' ' '\n' | xargs -I % ")
        |> KubeCmd.get_pods()
        |> KubeCmd.output("jsonpath='{.items[*].status.podIP}'")
        |> KubeCmd.field_selector("status.podIP=%")
        |> KubeCmd.namespace("outdoor-dwa")
        |> KubeCmd.build()

      assert cmd ==
               "kubectl get endpoints outdoor-dwa-svc -n outdoor-dwa -o=jsonpath='{.subsets[*].addresses[*].ip}' | tr ' ' '\n' | xargs -I % kubectl get pods -o=jsonpath='{.items[*].status.podIP}' --field-selector=status.podIP=% -n outdoor-dwa"
    end
  end
end
