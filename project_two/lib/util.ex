defmodule Util do
    def round_up(topology, node_num) do
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
end