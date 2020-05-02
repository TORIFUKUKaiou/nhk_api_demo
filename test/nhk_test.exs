defmodule NhkTest do
  use ExUnit.Case
  doctest Nhk

  test "greets the world" do
    assert Nhk.hello() == :world
  end
end
