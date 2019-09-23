# create all the nodes
defmodule PushSumProtocol do
  use GenServer

  def start_link(topology, node_num) do
    GenServer.start_link(__MODULE__, [topology, node_num])
  end

  defp round_up(topology, node_num) do
    new_num = case topology do
      "3Dtorus" ->
        fac = :math.pow(node_num, 1/3) |> round
        if :math.pow(fac, 3) != node_num do
          temp = :math.pow(node_num, 1/3) |> ceil |> :math.pow(3) |> floor
          IO.puts("topology: #{topology}, number of nodes rounds up to #{temp}")
          temp
        else
          node_num
        end

      "honeycomb" -> 
        if rem(node_num, 6) != 0 or node_num |> div(6) |> :math.sqrt() |> round |> :math.pow(2) |> Kernel.*(6) |> round != node_num do 
          temp = :math.sqrt(node_num/6) |> ceil |> :math.pow(2) |> Kernel.*(6) |> floor
          IO.puts("topology: #{topology}, number of nodes rounds up to #{temp}")
          temp
        else
          node_num
        end
      
      "randhoneycomb" ->
        if rem(node_num, 6) != 0 or node_num |> div(6) |> :math.sqrt() |> round |> :math.pow(2) |> Kernel.*(6) |> round != node_num do
          temp = :math.sqrt(node_num/6) |> ceil |> :math.pow(2) |> Kernel.*(6) |> floor
          IO.puts("topology: #{topology}, number of nodes rounds up to #{temp}")
          temp
        else
          node_num
        end

      true -> node_num
    end
  end

  def init(args) do
    [topology, node_num] = args
    node_num = round_up(topology, node_num)
    IO.puts(node_num)
    ppid = self()
    pid_list = Enum.map(1..node_num, fn node_id -> 
      {:ok, pid} = Actor.start_link(node_id, 1.0, ppid)
      pid end)

    {:ok, neighbor_pid} = Neighbor.start_link(pid_list, topology)
    for pid <- pid_list do
      nbs = Neighbor.get_neighbors(neighbor_pid, pid)
      Actor.set_neighbors(pid, nbs)
      IO.inspect(pid)
      IO.inspect(length(nbs))
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
    # IO.inspect(node_pid)
    Actor.recieve(node_pid, 0, 0)
    receive do
      :finish -> :ok
    end  

    {:reply, [], state}
  end


end
