defmodule Project_TwoTest do
  use ExUnit.Case
  doctest Project_Two

  test "greets the world" do
    assert Project_Two.hello() == :world
  end
end
