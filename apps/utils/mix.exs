defmodule Nostr.Utils.MixProject do
  use Mix.Project

  def project do
    [
      # app config
      app: :utils,
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
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
