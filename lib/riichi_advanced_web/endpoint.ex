defmodule RiichiAdvancedWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :riichi_advanced

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_riichi_advanced_key",
    # TODO store signing_salt as a secret
    # not a big deal though, it's not like we care about impersonation rn
    signing_salt: "sHBZn5OF",
    same_site: "Lax",
    max_age: 2592000 # 30 days
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :riichi_advanced,
    gzip: false,
    only: RiichiAdvancedWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    # plug :clear_mod_cache
    # plug Phoenix.Ecto.CheckRepoStatus, otp_app: :riichi_advanced
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: {__MODULE__, :no_health_log, []}
  # Disables log for / and /health routes
  def no_health_log(%{path_info: []}), do: false
  def no_health_log(%{path_info: ["health" | _]}), do: false
  def no_health_log(_), do: :info

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  # plug :introspect
  plug RiichiAdvancedWeb.Router

  # def introspect(conn, _opts) do
  #   IO.puts """
  #   Verb: #{inspect(conn.method)}
  #   Host: #{inspect(conn.host)}
  #   Headers: #{inspect(conn.req_headers)}
  #   """

  #   conn
  # end

  def clear_mod_cache(conn, _opts) do
    :ets.delete_all_objects(:cache_mods)
    conn
  end
end
