defmodule GossipNode do
    use GenServer

    def start_link(rumor, ppid) do
        GenServer.start_link(__MODULE__, [rumor: rumor, cnt: 0, nbs: [], ppid: ppid, started: false])
    end

    def init(state) do
        {:ok, state}
    end

    def set_neighbors(pid, nbs) do
        GenServer.cast(pid, {:neighbor, nbs})
    end

    # invoke sending periodically
    def start() do
        send(self(), :start)
        :timer.sleep(Enum.random(1..3))
        :timer.send_interval(10, :send)
    end

    def handle_cast({:neighbor, nb_list}, state) do
        new_state = Keyword.update!(state, :nbs, fn _ -> nb_list end)
        {:noreply, new_state}
    end


    def handle_info(:start, state) do
        new_state = Keyword.update!(state, :started, fn _ -> true end)
        {:noreply, new_state}
    end

    def receive(pid, rumor) do
        GenServer.cast(pid, {:receive, rumor})
    end

    def delete_nb(pid, done_pid) do
        GenServer.call(pid, {:delete_nb, done_pid}, :infinity)
    end

    def handle_info(:send, state) do
        nbs = state[:nbs]
        ppid = state[:ppid]
        if (length(nbs) == 0) do
            IO.inspect([self(), "exit because no neighbor is alive"])
            send(ppid, :finish)
            Process.exit(self(), :normal)
        else
            nb = Enum.random(nbs)
            GossipNode.receive(nb, state[:rumor])
            {:noreply, state}
        end
    end

    def handle_call({:delete_nb, done_pid}, _from, state) do
        nbs = state[:nbs]
        new_nbs = if Enum.member?(nbs, done_pid), do: List.delete(nbs, done_pid), else: nbs
        new_state = Keyword.update!(state, :nbs, fn _ -> new_nbs end)
        {:reply, :done, new_state}
    end

    def handle_cast({:receive, rumor}, state) do
        if (!state[:started]), do: start()
        # IO.inspect([self(), state])
        new_state = Keyword.update!(state, :cnt, fn cnt -> cnt+1 end)
        if (new_state[:cnt] == 10) do
            IO.puts("received #{rumor} 10 times")
            IO.inspect(self())
            ppid = state[:ppid]
            send(ppid, :finish)
            send(self(), :notify_exit)
            # Process.exit(self(), :normal)
        end
        {:noreply, new_state}
    end

    def handle_info(:notify_exit, state) do
        nbs = state[:nbs]
        for nb <- nbs do
            :done = delete_nb(nb, self())
        end
        {:noreply, state} 
    end
end


defmodule GossipBoss do
    def start_link(topology, node_num, rumor) do
        GenServer.start_link(__MODULE__, [topology, node_num, rumor])
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
    
          _ -> node_num
        end
    end


    def init(args) do
        [topology, node_num, rumor] = args
        node_num = round_up(topology, node_num)
        IO.puts(node_num)
        ppid = self()
        pid_list = Enum.map(1..node_num, fn node_id -> 
            {:ok, pid} = GossipNode.start_link(rumor, self())
            pid end)

        {:ok, neighbor_pid} = Neighbor.start_link(pid_list, topology)
        for pid <- pid_list do
            nbs = Neighbor.get_neighbors(neighbor_pid, pid)
            GossipNode.set_neighbors(pid, nbs)
            IO.inspect(pid)
            IO.inspect(length(nbs))
        end
        {:ok, [topology, pid_list, rumor]}
    end

    def start(pid) do
        GenServer.call(pid, :start, :infinity)
    end

    def handle_call(:start, _from, state) do
        [_, pid_list, rumor] = state
        
        # start gossip
        node_pid = Enum.random(pid_list)
        # IO.inspect(node_pid)
        GossipNode.receive(node_pid, rumor)

        receive do
            :finish -> :first_converged
        end
        
        Enum.reduce_while(1..length(pid_list)-1, 0, fn i,ret ->
            receive do
                :finish -> {:cont, ret}
                after 1000 -> {:halt, ret}
            end
        end)

        {:reply, [], state}

        
    end

end