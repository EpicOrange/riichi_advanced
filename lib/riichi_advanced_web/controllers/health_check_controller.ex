defmodule RiichiAdvancedWeb.HealthCheckController do
  use RiichiAdvancedWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "OK")
  end
end