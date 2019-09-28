# [args1, args2, args3] = System.argv();
# args1 = String.to_integer(args1);
# Project_Two.main(args1, args2, args3);

# start_t = System.monotonic_time(:second)
# {:ok, pid} = PushSumProtocol.start_link("line", 30)
# PushSumProtocol.start(pid)
# end_t = System.monotonic_time(:second)
# IO.inspect(["running time:", end_t - start_t])


# test gossip
# start_t = System.monotonic_time(:microsecond)
# {:ok, pid} = GossipMaster.start_link("3Dtorus", 1000, "some rumor")
# GossipMaster.start(pid, 0.1)
# end_t = System.monotonic_time(:microsecond)
# IO.inspect(["running time:", end_t - start_t])



# # test pushsum
start_t = System.monotonic_time(:microsecond)
{:ok, pid} = PushSumMaster.start_link("3Dtorus", 1000)
pid_list = PushSumMaster.get_pid_list(pid)
PushSumMaster.start(pid, 0.2)
end_t = System.monotonic_time(:microsecond)
IO.inspect(["running time:", end_t - start_t])
