defmodule Nostr.RelayTest do
  use ExUnit.Case

  doctest Nostr.Relay

  test "greets the world" do
    assert Nostr.Relay.hello() == :world
  end
end
