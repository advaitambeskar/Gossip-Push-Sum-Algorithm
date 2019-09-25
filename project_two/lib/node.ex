defmodule Actor do
    use GenServer

    def start_link(n, w, ppid) do
        GenServer.start_link(__MODULE__, [n: n, w: w, nbs: [], cnt: 0, ppid: ppid]) # nbs is the list of neighbors' pids
    end

    def init(args) do
        {:ok, args} 
    end

    def set_neighbors(pid, nbs) do
        GenServer.cast(pid, {:neighbor, nbs})
    end

    def recieve(pid, in_n, in_w) do
        GenServer.cast(pid, {:recieve, in_n, in_w}) 
    end

    def delete_neighbor(pid, dead_pid) do
        GenServer.call(pid, {:delete_nb, dead_pid})
    end

    def handle_call({:delete_nb, dead_pid}, _from, state) do
        [n: n, w: w, nbs: nbs, cnt: cnt, ppid: ppid] = state
        if (cnt < 3) do
            new_nbs = if Enum.member?(nbs, dead_pid), do: List.delete(nbs, dead_pid), else: nbs
            if (length(new_nbs) == 0) do
                IO.puts("exit because no neighbor is alive")
                send(ppid, {:finish, self()})
                Process.exit(self(), :normal)
            end
            {:reply, [], [n: n, w: w, nbs: new_nbs, cnt: cnt, ppid: ppid]}
        else
            {:reply, [], [n: n, w: w, nbs: [], cnt: cnt, ppid: ppid]}
        end
    end

    def handle_cast({:neighbor, nb_list}, state) do
        [n: n, w: w, nbs: nbs, cnt: cnt, ppid: ppid] = state
        {:noreply, [n: n, w: w, nbs: nb_list, cnt: cnt, ppid: ppid]}
    end


    def handle_cast({:recieve, in_n, in_w}, state) do
        # IO.inspect(["in", self()])
        [n: n, w: w, nbs: nbs, cnt: cnt, ppid: ppid] = state
        alive_nbs = Enum.filter(nbs, fn pid -> Process.alive?(pid) end)
        if length(alive_nbs) == 0 do
            send(ppid, {:finish, self()})
            Process.exit(self(), :normal)
        end
            
        # IO.inspect([n, w, n/w])
        if (cnt == 3) do
            IO.puts(n/w)
            # IO.puts("The ratio #{n/w} hasn't been changed for 3 iterations")
            # IO.inspect(self())
            send(ppid, {:finish, self()})
            for nb <- nbs do
                if Process.alive?(nb), do: Actor.recieve(nb, n, w) 
            end
            Process.exit(self(), :normal)

            
            # {:noreply, [n: n, w: w, nbs: alive_nbs, cnt: cnt+1, ppid: ppid]}
        else
            old_ratio = n/w
            [new_n, new_w] = [n + in_n, w + in_w]
            new_ratio = new_n / new_w
            cnt = if abs(new_ratio - old_ratio) < 1.0e-10, do: cnt + 1, else: 0
            # :timer.sleep(Enum.random(0..3)); #TODO==================
            nb = Enum.random(alive_nbs) 
            # :timer.sleep(Enum.random(0..3))
            Actor.recieve(nb, new_n/2, new_w/2)
                 
            {:noreply, [n: new_n/2, w: new_w/2, nbs: alive_nbs, cnt: cnt, ppid: ppid]}
        end
        # IO.inspect(state)      
        
    end


end