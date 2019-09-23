# create all the nodes
defmodule PushSumProtocol do
  use GenServer

  def start_link(topology, node_num) do
    GenServer.start_link(__MODULE__, [topology, node_num])
  end

  def init(args) do
    [topology, node_num] = args
    ppid = self()
    pid_list = Enum.map(1..node_num, fn node_id -> 
      {:ok, pid} = Actor.start_link(node_id, 1.0, ppid)
      pid end)

    {:ok, neighbor_pid} = Neighbor.start_link(pid_list, topology)
    for pid <- pid_list do
      nbs = Neighbor.get_neighbors(neighbor_pid, pid)
      Actor.set_neighbors(pid, nbs)
    end
    {:ok, [topology, pid_list]}
  end

  def start(pid) do
    GenServer.call(pid, :start, :infinity)
  end

  def handle_call(:start, _from, state) do
    [_, pid_list] = state
    
    # start gossip
    node_pid = Enum.random(pid_list)
    IO.inspect(node_pid)
    Actor.recieve(node_pid, 0, 0)
    receive do
      :finish -> :ok
    end  

    {:reply, [], state}
  end


end
