defmodule PushSumMaster do
    def start_link(topology, node_num) do
        GenServer.start_link(__MODULE__, [topology, node_num])
    end

    def init(args) do
        [topology, node_num] = args
        node_num = Util.round_up(topology, node_num)
        IO.puts(node_num)
        ppid = self()
        pid_list = Enum.map(1..node_num, fn node_id -> 
            {:ok, pid} = PushSumNode.start_link(node_id, 1.0, self())
            pid end)
        {:ok, neighbor_pid} = Neighbor.start_link(pid_list, topology)
        for pid <- pid_list do
            nbs = Neighbor.get_neighbors(neighbor_pid, pid)
            PushSumNode.set_neighbors(pid, nbs)
        end
        {:ok, [topology, pid_list]}
    end

    def start(pid) do
        GenServer.call(pid, :start, :infinity)
    end

    def handle_call(:start, _from, state) do
        [_, pid_list] = state
        
        # start a random node
        node_pid = Enum.random(pid_list)
        PushSumNode.receive(node_pid, 0, 0)

        pid_rest = receive do
            {:finish, pid} -> 
                IO.puts("first one finished")
                List.delete(pid_list, pid)
        end
        
        Enum.map(pid_rest, fn pid -> 
            receive do
                {:finish, in_pid} when pid == in_pid -> IO.inspect([in_pid, "finished"])
            end
        end)

        {:reply, [], state}
    end

end