defmodule GossipMaster do
    def start_link(topology, node_num, rumor) do
        GenServer.start_link(__MODULE__, [topology, node_num, rumor], name: {:global, :gossip_boss})
    end

    defp round_up(topology, node_num) do
        case topology do
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
            # IO.inspect(pid)
            # IO.inspect(length(nbs))
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

        pid_rest = receive do
            {:finish, pid} -> 
                IO.puts("first one finished")
                List.delete(pid_list, pid)
        end
        
        # Enum.reduce_while(pid_rest, 0, fn pid,ret ->
        #     receive do
        #         {:finish, pid} -> 
        #             IO.inspect([pid, "finished"])
        #             {:cont, ret}
        #         after 5000 -> 
        #             IO.puts("timeout")
        #             {:halt, ret}
        #     end
        # end)
        Enum.map(pid_rest, fn pid -> 
            # IO.inspect(pid)
            receive do
                # when pid == in_pid
                {:finish, in_pid} when pid == in_pid -> IO.inspect([in_pid, "finished"])
            end
        end)

        {:reply, [], state}
    end

    # def handle_call(:worker_finish)

end