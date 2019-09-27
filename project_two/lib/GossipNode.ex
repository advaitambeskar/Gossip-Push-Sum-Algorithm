defmodule GossipNode do
    use GenServer

    def start_link(rumor, ppid) do
        GenServer.start_link(__MODULE__, [rumor: rumor, cnt: 0, nbs: [], ppid: ppid, started: false, finished: false])
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
        :timer.send_interval(100, :send)
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
                nb = Enum.random(nbs)
                GossipNode.receive(nb, state[:rumor])
                {:noreply, state}
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

    def handle_cast({:receive, rumor}, state) do
        if (!state[:started]), do: start()
        # IO.inspect([self(), state[:cnt]])
        new_state = Keyword.update!(state, :cnt, fn cnt -> cnt+1 end)
        if (!state[:finished]) do
            if (new_state[:cnt] == 10) do
                # IO.puts("received #{rumor} 10 times")
                # IO.inspect(self())
                new_state = Keyword.update!(new_state, :finished, fn _ -> true end)
                ppid = state[:ppid]
                send(ppid, {:finish, self()})
                send(self(), :notify_exit)
                # Process.exit(self(), :normal)
                {:noreply, new_state}
            else
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