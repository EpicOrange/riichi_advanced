defmodule RiichiAdvanced.MixProject do
  use Mix.Project

  def project do
    [
      app: :riichi_advanced,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {RiichiAdvanced.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.18"},
      # even though we don't use the actual database,
      # we still use Ecto.UUID.generate() some places
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.1"},
      # {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2"},
      {:bandit, "~> 1.5"},

      # riichi-advanced-specific
      {:debounce, "~> 1.0.0"},
      {:decimal, "~> 3.0"},
      {:decorator, "~> 1.4"},
      {:ex_cmd, "~> 0.18.0"},
      {:gettext, "~> 1.0"},
      {:logger_backends, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:mutex, "~> 4.0"},
      {:nebulex, "~> 3.0"},
      {:nebulex_local, "~> 3.0"},
      {:plug_attack, "~> 0.4.2"},
      {:rustler, "~> 0.38.0", runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      
      # deps for ex_jq (vendored)
      {:temp, "~> 0.4"},
      # deps for ex_smt (vendored)
      {:nimble_parsec, "~> 1.4.0"}, # ex_smt dep
      # deps for delta (vendored)
      {:diffy, "~> 1.1"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      # "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # "ecto.reset": ["ecto.drop", "ecto.setup"],
      # setup: ["deps.get", "assets.setup", "assets.build"],
      # test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      # "assets.setup": ["esbuild.install --if-missing"],
      # "assets.build": ["esbuild riichi_advanced"],
      # "assets.deploy": [
      #   "esbuild riichi_advanced --minify",
      #   "phx.digest"
      # ]
    ]
  end
end
