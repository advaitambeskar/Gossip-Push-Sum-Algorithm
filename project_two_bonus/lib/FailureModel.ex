defmodule FailureModel do

    def run(pid_list, fail_percentage, algorithm) do
        shutdown_num = length(pid_list) * fail_percentage |> round
        chosen_nodes = Enum.take_random(pid_list, shutdown_num)
        task_list = for pid <- chosen_nodes do      
            wait_rand = Enum.random(100..2000)
            Task.start(fn -> 
                :timer.sleep(wait_rand)
                if algorithm == "push-sum", do: PushSumNode.shutdown(pid), else: GossipNode.shutdown(pid)
            end)
        end
    end

end