defmodule UniqueIdsEncyclopediaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :unique_ids_encyclopedia_ex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_multihash, "~> 2.0.0"},
      {:cid, "~> 0.0.1", app: true},
      {:b3, "~> 0.1"},
      {:cuid, "~> 0.1.0"},
      {:mock, "~> 0.3.9", only: :test},
      {:base62, "~> 1.2"},
      {:mox, "~> 1.2.0"},
      {:elixir_uuid, "~> 1.2"},
      {:mac_address, "~> 0.0.1"},
      {:meck, "~> 0.9", only: :test},
      {:benchee, "~> 1.4", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
