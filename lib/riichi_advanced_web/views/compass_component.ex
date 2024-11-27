defmodule RiichiAdvancedWeb.CompassComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["compass", @seat]} phx-click="notify_ai" phx-target={@myself}>
      <div class="centerpiece">
        <div class="tiles-left"><%= @tiles_left %></div>
        <div class="riichi-stick-counter" :if={@display_riichi_sticks}><%= @riichi_sticks %></div>
        <div class="honba-counter" :if={@display_honba}><%= @honba %></div>
      </div>
      <%= for {dir, symbol} <- prepare_compass(@kyoku, @available_seats) do %>
        <div class="score-box"></div>
        <div class={["direction", dir]}>
          <div class={["riichi-tray", @turn == dir && "highlighted", @riichi[dir] && "riichi"]}></div>
          <div class={["wind-marker", @turn == dir && "highlighted", @is_bot[dir] && "bot"]}><%= symbol %></div>
          <div class="score-counter" :if={dir in @available_seats}><%= @score[dir] %></div>
        </div>
      <% end %>
    </div>
    """
  end

  def prepare_compass(kyoku, available_seats) do
    symbols = %{east: "東", south: "南", west: "西", north: "北"}
    Enum.map([:east, :south, :west, :north], fn seat -> 
      if seat in available_seats do
        {seat, symbols[Riichi.get_seat_wind(kyoku, seat, available_seats)]}
      else
        {seat, ""}
      end
    end)
  end

  def handle_event("notify_ai", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, :notify_ai)
    {:noreply, socket}
  end
end
