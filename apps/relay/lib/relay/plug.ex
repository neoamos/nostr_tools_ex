defmodule Nostr.Relay.Plug do
  @moduledoc """
  Nostr Plug
  """

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/nostr+json")
    |> send_resp(200, Jason.encode!(%{}))
  end
end
