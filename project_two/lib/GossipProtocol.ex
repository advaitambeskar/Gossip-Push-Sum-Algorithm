defmodule GossipProtocol do
  @moduledoc """
    The Gossip Protocol module defines the functionality required to successfully run the gossip protocol.
  """

  use GenServer

  def main(totalNodes, topology) do
    IO.puts("Total nodes are #{Integer.to_string(totalNodes)}");
    # IO.puts("The required topology is #{topology}");

    # Selecting the topology and then re-directing to the required function.
    # We are also initializing the actors as requested by the user.

    # Generate the nodes
    # Generate the nodes and save their pid to allow neighborhood assignment.
    # pidList stores the pid in form of
    pidList = for id <- 0..totalNodes-1 do
      # Initialize the nodes using a GenServer.
      # Have the few variables that maintain the states
      # like 'numberOfRumorsHeard', 'neighbors' and current 'process-id'
      start_link(id, 0, :begin, []);
    end
    # Start Timing.
    startTime = :os.system_time(:millisecond);


    IO.puts startTime;
    IO.inspect pidList;

    random_source = Enum.random(pidList);

    IO.inspect random_source;
    # Generate the neighbour fields.

    # From the available pids, select a random node to become the source of the gossip.

    # Have a general module which is responsible only for generating neighbor connections
    # I have no idea how to make the neighbor connections though. :(
    case topology do
      "full" ->
        IO.puts("You have selected the full topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the full topology.
      "line" ->
        IO.puts("You have selected the line topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the line topology.
      "rand2D" ->
        IO.puts("You have selected the random2D topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the rand2D topology.
      "3Dtorus" ->
        IO.puts("You have selected the 3DTorus topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the 3DTorus topology.
      "honeycomb" ->
        IO.puts("You have selected the honeycomb topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the honeycomb topology.
      "randhoneycomb" ->
        IO.puts("You have selected the random honeycomb topology for actor connections in Gossip Protocol")
        # This is the place where we will call the function responsible for the random-honeycome topology.
      _ ->
        IO.puts("You have selected an incorrect topology for actor connections in Gossip Protocol")
        # This is the default condition which arises due to incorrect inputs.
        System.halt(0);
    end

    # Once the neighbour list is generated, we have to start sending
    # the rumor from the source to the other nodes in the list.
    #

    endTime = :os.system_time(:millisecond);
    IO.puts(endTime - startTime)
  end
  def start_link(id, rumor_count, state, neighbor_pid) do
    GenServer.start_link(__MODULE__, [id: id, rumor_count: rumor_count, state: state, neighbor_pid: neighbor_pid])
  end
end


defmodule Gossip do
  @moduledoc """
  This module holds all the functions that are responsible for all implementation of the required functionality.
  """

end
