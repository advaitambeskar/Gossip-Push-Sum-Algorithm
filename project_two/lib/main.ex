defmodule Proj2.CLI do
    def main(args \\ []) do
        try do
            args
            |> parse_args
            |> execute
        rescue e in [RuntimeError, ArgumentError] ->
            IO.puts("\nPlease run with the following format:")
            IO.puts("./project_two [numNodes] [full/line/rand2D/3Dtorus/honeycomb/randhoneycomb] [gossip/push-sum]\n")
            System.halt(0)
        end
    end
  
    defp parse_args(args) do
        [numNodes, topology, algorithm] = args
        numNodes = String.to_integer(numNodes)
        if (topology not in ["full","line","rand2D","3Dtorus","honeycomb","randhoneycomb"] ||
            algorithm not in ["gossip", "push-sum"]), do: raise RuntimeError
        [numNodes, topology, algorithm]
    end
  
    defp execute([numNodes, topology, algorithm]) do
        start_t = System.monotonic_time(:microsecond)
        case algorithm do
            "gossip" ->
                {:ok, pid} = GossipMaster.start_link(topology, numNodes, "some rumor")
                GossipMaster.start(pid)

            "push-sum" ->
                {:ok, pid} = PushSumMaster.start_link(topology, numNodes)
                PushSumMaster.start(pid)
        end
        end_t = System.monotonic_time(:microsecond)
        IO.puts("running time:  #{end_t - start_t} microseconds")
    end
end