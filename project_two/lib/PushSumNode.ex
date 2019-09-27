defmodule PushSumNode do
    use GenServer

    def start_link(n, w, ppid) do
        GenServer.start_link(__MODULE__, [n: n, w: w, cnt: 0, nbs: [], ppid: ppid, started: false, finished: false])
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
        :timer.sleep(Enum.random(1..100))
        :timer.send_interval(20, :send)
    end

    def handle_cast({:neighbor, nb_list}, state) do
        new_state = Keyword.update!(state, :nbs, fn _ -> nb_list end)
        {:noreply, new_state}
    end


    def handle_info(:start, state) do
        new_state = Keyword.update!(state, :started, fn _ -> true end)
        {:noreply, new_state}
    end

    def receive(pid, n, w) do
        GenServer.cast(pid, {:receive, n, w})
    end

    def delete_nb(pid, done_pid) do
        GenServer.cast(pid, {:delete_nb, done_pid})
    end

    def handle_info(:send, state) do
        if (!state[:finished]) do
            # if (length(state[:nbs]) == 1), do: IO.inspect([self(), state[:nbs]])
            nbs = state[:nbs]
            ppid = state[:ppid]
            # IO.inspect([self(), nbs])
            if (length(nbs) == 0) do
                # IO.inspect([self(), "exit because no neighbor is alive"])
                new_state = Keyword.update!(state, :finished, fn _ -> true end)
                send(ppid, {:finish, self()})
                # Process.exit(self(), :normal)
                {:noreply, new_state}
            else
                new_state = Keyword.update!(state, :w, fn w -> w/2 end)
                new_state = Keyword.update!(new_state, :n, fn n -> n/2 end)
                nb = Enum.random(nbs)
                PushSumNode.receive(nb, state[:n]/2, state[:w]/2)
                {:noreply, new_state}
            end
        else
            {:noreply, state}
        end
    end

    def handle_cast({:delete_nb, done_pid}, state) do
        # IO.inspect([self(), "deleting neighbor ", done_pid])
        if !state[:started], do: start()
        nbs = state[:nbs]
        new_nbs = if Enum.member?(nbs, done_pid), do: List.delete(nbs, done_pid), else: nbs
        new_state = Keyword.update!(state, :nbs, fn _ -> new_nbs end)
        {:noreply, new_state}
    end

    def handle_cast({:receive, in_n, in_w}, state) do
        if (!state[:started]), do: start()
        # IO.inspect([self(), state[:cnt]])
        if (!state[:finished]) do
            if (state[:cnt] == 3) do
                if (state[:cnt] == 3) do
                    IO.puts("The ratio #{state[:n]/state[:w]} hasn't been changed for 3 iterations")
                else 
                    IO.puts("w too small")
                end
                new_state = Keyword.update!(state, :finished, fn _ -> true end)
                ppid = state[:ppid]
                send(ppid, {:finish, self()})
                send(self(), :notify_exit)
                {:noreply, new_state}
                # {:noreply, [n: n, w: w, nbs: alive_nbs, cnt: cnt+1, ppid: ppid]}
            else
                # IO.inspect([state[:n], state[:w], state[:n]/state[:w], state[:cnt]])
                old_ratio = state[:n]/ state[:w]
                [new_n, new_w] = [state[:n] + in_n, state[:w] + in_w]
                new_ratio = new_n / new_w
                cnt = if abs(new_ratio - old_ratio) < 1.0e-10, do: state[:cnt] + 1, else: 0
                new_state = Keyword.update!(state, :n, fn n -> new_n end)
                new_state = Keyword.update!(new_state, :w, fn w -> new_w end)
                new_state = Keyword.update!(new_state, :cnt, fn _ -> cnt end)
                    
                {:noreply, new_state}
            end
        else
            {:noreply, state}
        end
    end


    def handle_info(:notify_exit, state) do
        # IO.inspect([self, "notifying exit"])
        nbs = state[:nbs]
        for nb <- nbs do
            delete_nb(nb, self())
        end
        {:noreply, state} 
    end
end