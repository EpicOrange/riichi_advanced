defmodule RiichiAdvancedWeb.GameController do
  use RiichiAdvancedWeb, :controller

  def game(conn, _params) do
    render(conn, :game)
  end
end
