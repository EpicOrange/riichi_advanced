import Config

so_reuseport =
  case :os.type() do
    {:unix, :linux} -> {:raw, 1, 15, <<1::32-native>>}
    {:unix, :darwin} -> {:raw, 0xffff, 0x0200, <<1::32-native>>}
  end
thousand_island_options = [transport_options: [reuseport: true]]

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :riichi_advanced, RiichiAdvancedWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [
    ip: {0, 0, 0, 0},
    port: System.get_env("HTTP_PORT") || 80,
    thousand_island_options: thousand_island_options,
  ],
  https: [
    port: System.get_env("HTTPS_PORT") || 443,
    thousand_island_options: thousand_island_options,
    cipher_suite: :strong,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  # doesn't really matter what this is if you're running this locally
  # riichiadvanced.com uses a different key, obviously
  secret_key_base: "250424b3a560dca9e9700e4adc1d166ca6bffb9b9910cbef270293751f0250a2",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:riichi_advanced, ~w(--sourcemap=inline --watch)]},
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :riichi_advanced, RiichiAdvancedWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/riichi_advanced_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"priv/svgs/.*(svg)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :riichi_advanced, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
