defmodule Nostr.Relay.MixProject do
  use Mix.Project

  def project do
    [
      # app config
      app: :relay,
      version: "0.1.0",

      # Elixir config
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # umbrella paths
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock"
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Nostr.Relay.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, github: "mtrudel/bandit", branch: "0.5"},
      {:jason, "~> 1.3"}
    ]
  end
end
