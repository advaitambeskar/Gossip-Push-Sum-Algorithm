defmodule PushSumProtocol do
  def main(totalNodes, topology) do
    IO.puts("Total nodes are #{Integer.to_string(totalNodes)}");
    # IO.puts("The required topology is #{topology}");

    # Selecting the topology and then re-directing to the required function.
    # We are also initializing the actors as requested by the user.

    case topology do
      "full" ->
        IO.puts("You have selected the full topology for actor connections in Push-Sum Protocol")
      "line" ->
        IO.puts("You have selected the line topology for actor connections in Push-Sum Protocol")
      "rand2D" ->
        IO.puts("You have selected the random2D topology for actor connections in Push-Sum Protocol")
      "3Dtorus" ->
        IO.puts("You have selected the 3DTorus topology for actor connections in Push-Sum Protocol")
      "honeycomb" ->
        IO.puts("You have selected the honeycomb topology for actor connections in Push-Sum Protocol")
      "randhoneycomb" ->
        IO.puts("You have selected the random honeycomb topology for actor connections in Push-Sum Protocol")
      _ ->
        IO.puts("You have selected an incorrect topology for actor connections in Push-Sum Protocol")
        System.halt(0);
    end
  end
end
