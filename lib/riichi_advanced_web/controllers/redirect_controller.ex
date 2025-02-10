defmodule RiichiAdvancedWeb.RedirectController do
  use RiichiAdvancedWeb, :controller
  def home(conn, _params), do: redirect(conn, to: "/")
  def lobby(conn, params), do: redirect(conn, to: "/lobby/#{params["ruleset"]}")
end
