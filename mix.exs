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
      # {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:debounce, "~> 1.0.0"},
      {:mutex, "~> 2.0.0"},
      {:hackney, "~> 1.9"},
      {:decimal, "~> 2.0"},
      {:nimble_parsec, "~> 1.4.0"},
      {:porcelain, github: "walkr/porcelain"},
      {:temp, "~> 0.4"},
      {:diff_match_patch, github: "pzingg/diff_match_patch"},
      {:diffy, "~> 1.1"},
      {:logger_file_backend, "~> 0.0.10"},
      {:nebulex, "~> 2.6"},
      {:decorator, "~> 1.4"},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
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
