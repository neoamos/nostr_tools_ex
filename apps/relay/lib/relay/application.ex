defmodule Nostr.Relay.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit,
       plug: Nostr.Relay.Plug, sock: Nostr.Relay.Sock, scheme: :http, options: [port: 4000]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Nostr.Relay.Supervisor)
  end
end
