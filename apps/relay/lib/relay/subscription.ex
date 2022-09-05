defmodule Nostr.Relay.Subscription do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(%{id: id} = opts) do
    GenServer.start_link(__MODULE__, opts, name: {:global, id})
  end

  def close(sub_id) do
    Logger.debug("Stopping subscription #{sub_id}")
    GenServer.stop({:global, sub_id})
  end

  @impl GenServer
  def init(state) do
    Logger.debug("Starting subscription")
    IO.inspect(state, label: "State")
    {:ok, state}
  end

  @impl GenServer
  def handle_call(msg, _from, state) do
    {:reply, msg, state}
  end

  @impl GenServer
  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
