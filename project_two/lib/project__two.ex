defmodule Project_Two do
  @moduledoc """
  Documentation for Project_Two.
  Implementatin of Gossip algorithm for information propogation and push-sum algorithm for sum computation.
  The idea is to implement multiple topologies for the various actors used in the network.

  """

  @doc """


  ## Examples

      iex> GossipProtocol.main(10000, full, gossip)

  """
  def main(args1, args2, args3) do
    # IO.puts(args1);
    # IO.puts(args2);
    # IO.puts(args3);
    totalNodes = args1;
    topology = args2;
    algorithm = args3;
    case algorithm do
      "gossip" ->
        IO.puts("You have selected the gossip algorithm for information traversal");
        GossipProtocol.main(totalNodes, topology);
      "push-sum" ->
        IO.puts("You have selected push-sum algorithm for sum computation")
        PushSumProtocol.main(totalNodes, topology);
      _ ->
        IO.puts("You have to select either 'gossip' or 'push-sum'. Please try again.")
        System.halt(0);
    end
  end
end
