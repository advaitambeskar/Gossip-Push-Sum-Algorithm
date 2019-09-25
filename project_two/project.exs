# [args1, args2, args3] = System.argv();
# args1 = String.to_integer(args1);
# Project_Two.main(args1, args2, args3);

start_t = System.monotonic_time(:second)
{:ok, pid} = PushSumProtocol.start_link("line", 30)
PushSumProtocol.start(pid)
end_t = System.monotonic_time(:second)
IO.inspect(["running time:", end_t - start_t])

