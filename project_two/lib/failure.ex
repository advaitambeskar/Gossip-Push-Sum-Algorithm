defmodule FailureNode do
  def failure(pid) do
    # The function failure selects a given pid, then generates a randomnumber to check if the given pid
    # is to be kepy alive or dead.
    # The given process is permanantly dead, if the random number generated from between
    # 0 and 1000 is greater than 950.

    # The given process is temporarily dead, if the random number generated from between
    # 0 and 1000 is under 50.

    n = 1000
    random_number = :rand.uniform(n)
    cond do
      random_number > 950 ->
        :permanant_death
      random_number < 50 ->
        :temporary_death
      true ->
        :alive
    end
  end
end
