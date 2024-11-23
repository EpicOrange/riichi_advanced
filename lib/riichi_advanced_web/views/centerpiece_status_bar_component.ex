defmodule RiichiAdvancedWeb.CenterpieceStatusBarComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <div class="tiles-left"><%= @tiles_left %></div>
      <div class="riichi-stick-counter" :if={@display_riichi_sticks}><%= @riichi_sticks %></div>
      <div class="honba-counter" :if={@display_honba}><%= @honba %></div>
    </div>
    """
  end

  def handle_event("notify_ai", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, :notify_ai)
    {:noreply, socket}
  end
end
