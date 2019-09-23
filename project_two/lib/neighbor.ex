# store list of pids
# find the list of neighbor pids for a query pid
# taking care of different topologies
defmodule Neighbor do
    use GenServer

    def start_link(pid_list, topology) do
        GenServer.start_link(__MODULE__, [pid_list, topology])
    end

    def init([pid_list, topology]) do 
        pid2idx = Map.new(Enum.zip(pid_list, 0..length(pid_list)-1))
        n = length(pid_list) 
        cond do
            topology == "honeycomb"  or topology == "randhoneycomb" ->
                if rem(n, 6) != 0 or :math.pow(:math.sqrt(div(n, 6)), 2) * 6 |> round != n do
                    {:stop, "The number of nodes is not 6 * t^2"}
                else
                    t = :math.sqrt(div(n, 6)) |> round 
                    honeycomb_idxes =  get_honeycomb_indexes(t)
                    honeycomb_map = Map.new(Enum.zip(honeycomb_idxes, 0..n-1))
                    {:ok, [pid_list, pid2idx, topology, honeycomb_idxes, honeycomb_map, []]}
                end
            topology == "rand2D" ->
                rand_xs = Enum.map(1..n, fn _ -> :rand.uniform() end)
                rand_ys = Enum.map(1..n, fn _ -> :rand.uniform() end)
                rand_idxes = Enum.zip(rand_xs, rand_ys)
                {:ok, [pid_list, pid2idx, topology, [], %{}, rand_idxes]}
            true ->
                {:ok, [pid_list, pid2idx, topology, [], %{}, []]}
            
        end
    end

    defp get_honeycomb_indexes(t) do
        range = -t+1..t
        temp = for i <- range, j <- range, k <- range, do: [i,j,k]
        Enum.filter(temp, fn [x,y,z] -> x+y+z >= 1 and x+y+z <= 2 end)
    end

    def get_neighbors(pid, node_pid) do
        GenServer.call(pid, {:get, node_pid})
    end

    def handle_call({:get, node_pid}, _from, state) do
        [pid_list, pid2idx, topology, honeycomb_idxes, honeycomb_map, rand_idxes] = state
        idx = pid2idx[node_pid]
        len = length(pid_list)
        case topology do
            "full" ->
                {:reply, List.delete(pid_list, node_pid), state}
            "line" ->             
                cond do
                    idx == 0 -> {:reply, [Enum.at(pid_list, 1)], state}      
                    idx == len-1 -> {:reply, [Enum.at(pid_list, len-2)], state}  
                    true -> {:reply, [Enum.at(pid_list, idx-1), Enum.at(pid_list, idx+1)], state}
                        
                end
            "rand2D" ->
                rand_idxes
                {curr_x, curr_y} = Enum.at(rand_idxes, idx)
                
                nb_idxes = Enum.filter(0..len-1, fn i->
                        {iter_x, iter_y} = Enum.at(rand_idxes, i)
                        i != idx and (iter_x-curr_x)*(iter_x-curr_x) + (iter_y-curr_y)*(iter_y-curr_y) <= 0.01
                    end)
                nbs = Enum.map(nb_idxes, fn x-> Enum.at(pid_list, x) end)
                {:reply, nbs, state}
                
                
            "3Dtorus" ->
                idx = pid2idx[node_pid]
                len = length(pid_list)
                fac = :math.pow(len, 1/3) |> round
                if :math.pow(fac, 3) != len do
                    IO.puts("The number of nodes is not n^3")
                    {:reply, [], []}
                else
                    fac2 = fac*fac
                    fac3 = fac*fac*fac
                    [up,down,back,front,left,right] = [rem(idx - fac2 + fac3, fac3), 
                                                       rem(idx + fac2 + fac3, fac3),
                                                       div(idx, fac2) * fac2 + rem(rem(idx, fac2) - fac + fac2, fac2),
                                                       div(idx, fac2) * fac2 + rem(rem(idx, fac2) + fac + fac2, fac2),
                                                       div(idx, fac) * fac + rem(rem(idx, fac) - 1 + fac, fac),
                                                       div(idx, fac) * fac + rem(rem(idx, fac) + 1 + fac, fac)]
                    nbs = Enum.map([up,down,back,front,left,right], fn x-> Enum.at(pid_list, x) end)
                    {:reply, nbs, state}
                end

            "honeycomb" ->
                [u,v,w] = Enum.at(honeycomb_idxes, idx)
                t = :math.sqrt(div(len, 6)) |> round 
                temp = [[u+1,v,w], [u-1,v,w], [u,v+1,w], [u,v-1,w], [u,v,w+1], [u,v,w-1]]
                nbs_idxes = Enum.filter(temp, fn [x,y,z] -> -t+1<=x and x<=t and
                                                            -t+1<=y and y<=t and
                                                            -t+1<=z and z<=t and
                                                            x+y+z>=1 and x+y+z<=2 end)
                
                # IO.inspect([u,v,w])
                # IO.inspect(nbs_idxes)
                temp = Enum.map(nbs_idxes, fn x-> honeycomb_map[x] end)
                # IO.inspect(temp)
                nbs = Enum.map(temp, fn x->Enum.at(pid_list, x) end)
                # IO.inspect(nbs)
                {:reply, nbs, state}

            "randhoneycomb" ->
                [u,v,w] = Enum.at(honeycomb_idxes, idx)
                t = :math.sqrt(div(len, 6)) |> round 
                temp = [[u+1,v,w], [u-1,v,w], [u,v+1,w], [u,v-1,w], [u,v,w+1], [u,v,w-1]]
                nbs_idxes = Enum.filter(temp, fn [x,y,z] -> -t+1<=x and x<=t and
                                                            -t+1<=y and y<=t and
                                                            -t+1<=z and z<=t and
                                                            x+y+z>=1 and x+y+z<=2 end)

                temp = Enum.map(nbs_idxes, fn x-> honeycomb_map[x] end)
                nbs = Enum.map(temp, fn x->Enum.at(pid_list, x) end)
                nbs = [Enum.random(pid_list) | nbs] 
                {:reply, nbs, state}

              _ ->
                {:reply, [], state}
        end
    end


end