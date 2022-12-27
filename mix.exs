defmodule Nostr.MixProject do
  use Mix.Project

  def project do
    [
      app: :nostr,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:secp256k1, git: "https://git.sr.ht/~sgiath/secp256k1"},
      {:jason, "~> 1.3"},
      {:ex_json_schema, "~> 0.9.2"},

      # Dev
      {:ex_doc, "~> 0.28", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false}
    ]
  end
end
