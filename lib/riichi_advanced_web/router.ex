defmodule RiichiAdvancedWeb.Router do
  use RiichiAdvancedWeb, :router

  def generate_session_id(conn, _opts) do
    put_session(conn, :session_id, get_session(conn, :session_id) || Ecto.UUID.generate())
  end

  pipeline :browser do
    plug RiichiAdvancedWeb.PlugAttack
    plug :accepts, ["html"]
    plug :fetch_session
    plug :generate_session_id
    plug :fetch_live_flash
    plug :put_root_layout, html: {RiichiAdvancedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'; script-src 'self' 'unsafe-inline'; img-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https://fonts.googleapis.com https://fonts.gstatic.com;"}
  end

  pipeline :auth do
    plug :put_user_token
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def health_check(conn, _opts) do
    send_resp(conn, 200, "OK")
  end

  scope "/", RiichiAdvancedWeb do
    pipe_through [:browser, :auth]
    get "/room/:ruleset", RedirectController, :lobby
    get "/game/:ruleset", RedirectController, :lobby
    live_session :default do
      live "/", IndexLive
      live "/lobby/:ruleset", LobbyLive
      live "/room/:ruleset/:room_code", RoomLive
      live "/game/:ruleset/:room_code", GameLive
      live "/tutorial/:ruleset", TutorialMenuLive
      live "/tutorial/:ruleset/:sequence", GameLive
      live "/tutorial_creator", TutorialCreatorLive
      live "/log", LogMenuLive
      live "/log/:log_id", LogLive
      live "/about", AboutLive
      live "/majstest", MajsTestLive
    end
    import Phoenix.LiveDashboard.Router
    live_dashboard "/dev/dashboard", metrics: RiichiAdvancedWeb.Telemetry
    get "/health", HealthCheckController, :index, log: false
    get "/*_", RedirectController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiichiAdvancedWeb do
  #   pipe_through :api
  # end

  # # Enable LiveDashboard and Swoosh mailbox preview in development
  # if Application.compile_env(:riichi_advanced, :dev_routes) do
  #   # If you want to use the LiveDashboard in production, you should put
  #   # it behind authentication and allow only admins to access it.
  #   # If your application does not have an admins-only section yet,
  #   # you can use Plug.BasicAuth to set up some basic authentication
  #   # as long as you are also using SSL (which you should anyway).
  #   import Phoenix.LiveDashboard.Router

  #   scope "/dev" do
  #     pipe_through :browser

  #     live_dashboard "/dashboard", metrics: RiichiAdvancedWeb.Telemetry
  #     forward "/mailbox", Plug.Swoosh.MailboxPreview
  #   end
  # end
  
end
