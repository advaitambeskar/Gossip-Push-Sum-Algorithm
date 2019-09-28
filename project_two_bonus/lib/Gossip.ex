defmodule GossipMaster do
    def start_link(topology, node_num, rumor) do
        GenServer.start_link(__MODULE__, [topology, node_num, rumor])
    end

    def init(args) do
        [topology, node_num, rumor] = args
        node_num = Util.round_up(topology, node_num)
        IO.puts(node_num)
        ppid = self()
        pid_list = Enum.map(1..node_num, fn node_id -> 
            {:ok, pid} = GossipNode.start_link(rumor, self())
            pid end)

        {:ok, neighbor_pid} = Neighbor.start_link(pid_list, topology)
        for pid <- pid_list do
            nbs = Neighbor.get_neighbors(neighbor_pid, pid)
            GossipNode.set_neighbors(pid, nbs)
        end
        {:ok, [topology, pid_list, rumor]}
    end

    def start(pid, failure_percentage) do
        GenServer.call(pid, {:start, failure_percentage}, :infinity)
    end

    def get_pid_list(pid) do
        GenServer.call(pid, :get_pid_list)
    end

    def handle_call(:get_pid_list, _from, state) do
        [_, pid_list] = state
        {:reply, pid_list, state}
    end

    def handle_call({:start, failure_percentage}, _from, state) do
        [_, pid_list, rumor] = state
        
        # start a random node
        node_pid = Enum.random(pid_list)
        GossipNode.receive(node_pid, rumor)
        FailureModel.run(pid_list, failure_percentage, "gossip")

        pid_rest = receive do
            {:finish, pid} -> 
                List.delete(pid_list, pid)
        end
        
        Enum.map(pid_rest, fn pid -> 
            receive do
                {:finish, in_pid} when pid == in_pid -> :done#IO.inspect([in_pid, "finished"])
            end
        end)

        {:reply, [], state}
    end

end