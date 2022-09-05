defmodule Nostr.Relay.Sock do
  @moduledoc """
  Nostr Sock implementation
  """

  import Sock.Socket

  require Logger

  @behaviour Sock

  @impl Sock
  def init(_opts) do
    %{}
  end

  @impl Sock
  def negotiate(conn, state) do
    {:accept, conn, state}
  end

  @impl Sock
  def handle_connection(sock, state) do
    {:continue, state}
  end

  @impl Sock
  def handle_ping_frame(data, _sock, state) do
    Logger.debug("Received ping frame - #{data}")
    {:continue, state}
  end

  @impl Sock
  def handle_pong_frame(data, _sock, state) do
    Logger.debug("Received pong frame - #{data}")
    {:continue, state}
  end

  @impl Sock
  def handle_text_frame(data, sock, state) do
    case Jason.decode(data) do
      {:ok, ["EVENT", event]} ->
        Logger.debug("Received event")
        {:continue, state}

      {:ok, ["REQ", sub_id, filters]} ->
        Logger.debug("Received request to start subscription")
        Nostr.Relay.Subscription.start_link(%{id: sub_id, filters: filters})
        {:continue, Map.update(state, :subscriptions, [sub_id], fn subs -> [sub_id | subs] end)}

      {:ok, ["CLOSE", sub_id]} ->
        Logger.debug("Received request to close subscription")
        Nostr.Relay.Subscription.close(sub_id)
    end

    {:continue, state}
  end

  @impl Sock
  def handle_binary_frame(_data, _sock, state) do
    {:continue, state}
  end

  @impl Sock
  def handle_error(_error, _sock, _state) do
    :ignored
  end

  @impl Sock
  def handle_timeout(_conn, _state) do
    :ignored
  end

  @impl Sock
  def handle_close(_status_code, _conn, _state) do
    :ignored
  end
end
