# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :riichi_advanced,
  # ecto_repos: [RiichiAdvanced.Repo],
  ecto_repos: [],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :riichi_advanced, RiichiAdvancedWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RiichiAdvancedWeb.ErrorHTML, json: RiichiAdvancedWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: RiichiAdvanced.PubSub,
  # riichiadvanced.com uses a different salt
  live_view: [signing_salt: "WXi0HtMH"]

# # Configures the mailer
# #
# # By default it uses the "Local" adapter which stores the emails
# # locally. You can see the emails in your browser, at "/dev/mailbox".
# #
# # For production it's recommended to configure a different adapter
# # at the `config/runtime.exs`.
# config :riichi_advanced, RiichiAdvanced.Mailer, adapter: Swoosh.Adapters.Local

# Don't use emails
config :riichi_advanced, RiichiAdvanced.Mailer, adapter: Swoosh.Adapters.Test
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  riichi_advanced: [
    args:
      ~w(js/app.js js/safe_diff_worker.js css/app.css --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :porcelain, goon_warn_if_missing: false
config :porcelain, driver: Porcelain.Driver.Basic

config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}]

config :logger, :error_log,
  path: "log/error.log",
  level: :error,
  truncate: :infinity # don't set this in prod

# cache
config :riichi_advanced, RiichiAdvanced.Cache,
  limit: 1_000_000,
  stats: true