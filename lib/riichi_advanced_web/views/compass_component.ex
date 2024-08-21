defmodule RiichiAdvancedWeb.CompassComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["compass", Riichi.get_seat_wind(@kyoku, @seat)]} phx-click="notify_ai" phx-target={@myself}>
      <div class="centerpiece">
        <div class="tiles-left"><%= @tiles_left %></div>
        <div class="riichi-stick-counter"><%= @riichi_sticks %></div>
        <div class="honba-counter"><%= @honba %></div>
      </div>
      <%= for {dir, symbol} <- [{:east, "東"}, {:south, "南"}, {:west, "西"}, {:north, "北"}] do %>
        <div class="score-box"></div>
        <div class={["direction", dir]}>
          <div class={["riichi-tray", Riichi.get_seat_wind(@kyoku, @turn) == dir && "highlighted", @riichi[dir] && "riichi"]}></div>
          <div class={["wind-marker", Riichi.get_seat_wind(@kyoku, @turn) == dir && "highlighted", @is_bot[dir] && "bot"]}><%= symbol %></div>
          <div class="score-counter"><%= @score[Riichi.get_player_from_seat_wind(@kyoku, dir)] %></div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("notify_ai", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, :notify_ai)
    {:noreply, socket}
  end
end
