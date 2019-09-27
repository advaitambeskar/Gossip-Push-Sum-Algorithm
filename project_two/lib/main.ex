defmodule Proj2.CLI do
    def main(args \\ []) do
      args
      |> parse_args
      |> execute
    end
  
    defp parse_args(args) do
        [numNodes, topology, algorithm] = args
        numNodes = String.to_integer(numNodes)
        [numNodes, topology, algorithm]
    end
  
    defp execute([numNodes, topology, algorithm]) do
        start_t = System.monotonic_time(:microsecond)
        case algorithm do
            "gossip" ->
                {:ok, pid} = GossipMaster.start_link(topology, numNodes, "some rumor")

            "push-sum" ->
                {:ok, pid} = PushSumMaster.start_link(topology, numNodes)
        end
        end_t = System.monotonic_time(:microsecond)
        IO.inspect(["running time:", end_t - start_t])
    end
end