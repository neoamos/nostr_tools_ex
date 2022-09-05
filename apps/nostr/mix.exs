defmodule Nostr.MixProject do
  use Mix.Project

  def project do
    [
      app: :nostr,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:secp256k1, in_umbrella: true},
      {:jason, "~> 1.3"}
    ]
  end
end
