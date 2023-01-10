defmodule NostrTools.MixProject do
  use Mix.Project

  @source_url "https://github.com/neoamos/nostr_tools_ex"

  def project do
    [
      app: :nostr_tools,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      name: "NostrTools",
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

  defp description() do
    """
    Core Nostr primitives and related functions.
    """
  end

  defp package() do
    [
      maintainers: ["Amos Newswanger"],
      licenses: ["WTFPL"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      main: "NostrTools", # The main page in the docs
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:secp256k1, git: "https://git.sr.ht/~sgiath/secp256k1", ref: "04d2d87a8a5009f2a6bc22b90c4c05401c57b7c7"},
      {:jason, "~> 1.3"},

      # Dev
      {:ex_doc, "~> 0.28", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false}
    ]
  end
end
