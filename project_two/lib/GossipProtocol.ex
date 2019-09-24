defmodule GossipProtocol do

  @moduledoc """
    The Gossip Protocol module defines the functionality required to successfully run the gossip protocol.

    init - initialize the actor for
  """

  use GenServer


  #HandleCall Functions

  def handle_call({:read}, _from, list) do
    {:reply, list, list}
  end

  def handle_call({:add_to_rumor}, _from, list) do
    [id, rumor_number, state, neighbor_list] = list;
    rumor_number = rumor_number + 1;
    list = [id, rumor_number, state, neighbor_list]
    {:reply, list, list}
  end

  def handle_call({:add_to_neighborList, neighborHoodList}, _from, list) do
    [id, rumor_number, state, neighbor_list] = list;
    neighbor_list = neighborHoodList;
    # IO.inspect(neighbor_list)
    list = [id, rumor_number, state, neighbor_list];
    {:reply, list,list}
  end

  def handle_call({:remove_neighbor, pid_remove}, _from, list) do
    [id, rumor_number, state, neighbor_list] = list;
    neighbor_list = neighbor_list -- [pid_remove]
    list = [id, rumor_number, state, neighbor_list];
    {:reply, list, list}
  end

  def handle_call({:change_state, final_state}, _from, list) do
    [id, rumor_number, state, neighbor_list] = list;
    state = final_state;
    list = [id, rumor_number, state, neighbor_list];

    {:reply, list, list}
  end

  def handle_call({:rumor_count}, _from, list) do
    [id, rumor_number, state, neighbor_list] = list
    #IO.inspect rumor_number
    {:reply, list, list}
  end

  # we need handle calls for "adding" a count to the rumor_count in the stack.
  # we need handle calls for sending rumors to the neighbors with the neighbor_pids
  #

  def start_link(id) do
    GenServer.start_link(__MODULE__, :ok, [id])
  end


  # functions for running the code and such

  def add_rumor(pid) do
    # IO.puts Enum.at(GossipProtocol.read(pid),1)
    GossipProtocol.add_to_rumor(pid)
  end

  def add_neighborList_pid(pid, neighborList) do
    GossipProtocol.add_to_neighborList(pid, neighborList)
  end

  def addingNeighbors(topology, pidList, pid) do
    #IO.inspect "This is"
    neighbor_list = []
    # The hope is that the neighbor_list shall hold all the required pid's in form of [#PID<0.180.0>, #PID<0.179.0>, etc]


    case topology do
      "full" ->
        # IO.puts("You have selected the full topology for actor connections in Gossip Protocol")
        neighbor_list = neighbor_list ++  Enum.map(pidList, fn(x) ->
          if(x != pid) do
            {:ok, process} = x
            process
          else
            []
          end
        end)
        GossipProtocol.add_neighborList_pid(pid, neighbor_list)
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
  end

  def remove_neighbor_from_list(pid_source, pid_remove) do
    GossipProtocol.remove_neighbor(pid_source, pid_remove);
  end

  def change_state(pid, final_state) do
    GossipProtocol.change_current_state(pid, final_state);
  end

  def rumor_count(pid) do
    GossipProtocol.rumor_count_reply(pid)
  end

  def init(id) do
    {:ok, [id, 0, :begin, []]}
  end

  def add_initial(pid, item) do
    GenServer.cast(pid, {:add_initial, item});
  end

  def read(pid) do
    GenServer.call(pid, {:read})
  end

  def add_to_rumor(pid) do
    GenServer.call(pid, {:add_to_rumor})
  end

  def add_to_neighborList(pid, neighborhoodList) do
    GenServer.call(pid, {:add_to_neighborList, neighborhoodList});
  end
  def remove_neighbor(pid_source, pid_remove) do
    GenServer.call(pid_source, {:remove_neighbor, pid_remove})
  end

  def change_current_state(pid, final_state) do
    GenServer.call(pid, {:change_state, final_state});
  end

  def rumor_count_reply(pid) do
    GenServer.call(pid, {:rumor_count});
  end



  def main(totalNodes, topology) do
    IO.puts("Total nodes are #{Integer.to_string(totalNodes)}");

    # Selecting the topology and then re-directing to the required function.
    # We are also initializing the actors as requested by the user.

    # Generate the nodes
    # Generate the nodes and save their pid to allow neighborhood assignment.
    # pidList stores the pid in form of

    pidList = for id <- 0..totalNodes-1 do
      GossipProtocol.start_link(id);
    end
    # IO.inspect pidList;
    # Start Timing.

    startTime = :os.system_time(:millisecond);


    # add_rumor(pid) is the function that allows the rumor count to be increased by 1

    # add_neighborList_pid(pid, [listOfNeighbor]) is the function that allows the neighbor list
    # to be added to the state of the pid.

    # Have a general module which is responsible only for generating neighbor connections
    # I have no idea how to make the neighbor connections though. :(
    for {:ok, source} <- pidList do
      addingNeighbors(topology, pidList, source)
    end
    pidListWithoutAtom = []
    pidListWithoutAtom = pidListWithoutAtom ++ Enum.map(pidList, fn(x) ->
      # IO.inspect x
      {:ok, pid} = x
      if(pid != :ok) do
        pid
      end
    end)

    GossipProtocol.start(pidListWithoutAtom);
    endTime = :os.system_time(:millisecond);
    IO.puts(endTime - startTime)
  end

  def start(pidList) do
    total_completion_count = 0
    termination_rumor_count = 10
    total_nodes = Enum.count(pidList)
    sender_node = Enum.random(pidList)
    recieving_neighbors = GossipProtocol.neighborList(sender_node)
    status = start_rumor(total_completion_count, termination_rumor_count, sender_node, recieving_neighbors, total_nodes)
    status
  end

  def start_rumor(total_completed_nodes, termination_count, sending_node, pidList, total_nodes) do
    # IO.inspect "Reaching here"
    receiver_node = Enum.random(pidList)  # randomly selected neighbor
    percent = 100
    # IO.inspect receiver_node
    #IO.inspect GossipProtocol.rumor_counter(receiver_node)
    current_percent = total_completed_nodes*100/total_nodes # percentage of completion of transfer
    if(current_percent < percent) do
      cond do
        GossipProtocol.state_atom(receiver_node) == :begin ->
          GossipProtocol.change_current_state(receiver_node, :transmitting)
          GossipProtocol.add_rumor(receiver_node)
          GossipProtocol.start_rumor(total_completed_nodes, termination_count, receiver_node, GossipProtocol.neighborList(receiver_node), total_nodes)
        GossipProtocol.state_atom(receiver_node) == :transmitting ->
          if(GossipProtocol.rumor_counter(receiver_node) == termination_count) do
            total_completed_nodes = total_completed_nodes + 1
            GossipProtocol.change_current_state(receiver_node, :completion)
            new_receiver = select_randomNode(pidList, termination_count, {:with_previous_rumor})
            IO.inspect "Total completed nodes is #{total_completed_nodes}"
            GossipProtocol.start_rumor(total_completed_nodes, termination_count, new_receiver, GossipProtocol.neighborList(new_receiver), total_nodes)
          else
            GossipProtocol.add_rumor(receiver_node)
            GossipProtocol.start_rumor(total_completed_nodes, termination_count, receiver_node, GossipProtocol.neighborList(receiver_node), total_nodes)
          end
        GossipProtocol.state_atom(receiver_node) == :completion ->
          new_random_node = select_randomNode(GossipProtocol.neighborList(sending_node), termination_count, {:with_previous_rumor})
          # IO.inspect(new_random_node)
          GossipProtocol.start_rumor(total_completed_nodes, termination_count, new_random_node, GossipProtocol.neighborList(new_random_node), total_nodes)

      end
    else
      IO.puts "Atleast #{percent}% reached"
      IO.puts "Total completed nodes is #{total_completed_nodes}"
      :finished
    end
  end

  def select_randomNode(pidList, termination_count, atom) do
    selected_randomNode = Enum.random(pidList)
    if(atom == {:with_previous_rumor}) do
      cond do
        GossipProtocol.rumor_counter(selected_randomNode) >= 1 && GossipProtocol.rumor_counter(selected_randomNode) < termination_count  ->
          selected_randomNode
        GossipProtocol.rumor_counter(selected_randomNode) < 1 ->
          select_randomNode(pidList, termination_count, {:with_previous_rumor})
        true ->
          selected_randomNode
      end
    else
      # IO.inspect "here too"
      cond do
        GossipProtocol.rumor_counter(selected_randomNode) == 0 ->
          # IO.inspect "here three"
          select_randomNode(pidList, termination_count, {:new})
        GossipProtocol.rumor_counter(selected_randomNode) == termination_count ->
          # IO.inspect "here four"
          select_randomNode(pidList, termination_count, {:new})
        true ->
          selected_randomNode
      end
    end
  end


  def neighborList(pid) do
    Enum.at(GossipProtocol.read(pid), 3)
  end
  def state_atom(pid) do
    Enum.at(GossipProtocol.read(pid), 2)
  end
  def rumor_counter(pid) do
    Enum.at(GossipProtocol.read(pid), 1)
  end
end
