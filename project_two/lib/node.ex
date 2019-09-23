defmodule Actor do
    use GenServer

    def start_link(n, w, ppid) do
        GenServer.start_link(__MODULE__, [n: n, w: w, nbs: [], cnt: 0, ppid: ppid]) # nbs is the list of neighbors' pids
    end

    def init(args) do
        {:ok, args} 
    end

    def set_neighbors(pid, nbs) do
        # IO.inspect(pid)
        # IO.inspect(nbs)
        GenServer.cast(pid, {:neighbor, nbs})
    end

    def recieve(pid, in_n, in_w) do
        # IO.puts ("recieved #{in_n}, #{in_w}")
        # IO.inspect(pid)
        :ok = GenServer.cast(pid, {:recieve, in_n, in_w}) 
        # IO.puts("ok")
    end

    def handle_cast({:neighbor, nb_list}, state) do
        [n: n, w: w, nbs: nbs, cnt: cnt, ppid: ppid] = state
        {:noreply, [n: n, w: w, nbs: nb_list, cnt: cnt, ppid: ppid]}
    end

    def handle_cast({:recieve, in_n, in_w}, state) do
        # IO.inspect(state)
        [n: n, w: w, nbs: nbs, cnt: cnt, ppid: ppid] = state
        IO.inspect([n, w, n/w])
        old_ratio = n/w
        [new_n, new_w] = [n + in_n, w + in_w]
        new_ratio = new_n / new_w
        cnt = if abs(new_ratio - old_ratio) < 1.0e-10, do: cnt + 1, else: 0
        if (cnt >= 3) do
            IO.puts("The ratio #{new_ratio} hasn't been changed for 3 iterations")
            send(ppid, :finish)
            {:noreply, []}
        else
            # IO.inspect(state)
            nb = Enum.random(nbs)
            :timer.sleep(Enum.random(0..10)); #TODO==================
            Actor.recieve(nb, new_n/2, new_w/2)     

            {:noreply, [n: new_n/2, w: new_w/2, nbs: nbs, cnt: cnt, ppid: ppid]}
        end
    end




end