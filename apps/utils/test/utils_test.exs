defmodule Nostr.UtilsTest do
  use ExUnit.Case

  doctest Nostr.Utils

  test "greets the world" do
    assert Nostr.Utils.hello() == :world
  end
end
