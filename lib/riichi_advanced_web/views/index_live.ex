defmodule RiichiAdvancedWeb.IndexLive do
  use RiichiAdvancedWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :session_id, "asdf")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="main-page">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <.link href={~p"/game/#{@session_id}"} class="enter-button">Enter</.link>
    </div>
    """
  end
end
