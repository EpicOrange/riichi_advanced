defmodule RiichiAdvancedWeb.CompassComponent do
  alias RiichiAdvanced.Riichi, as: Riichi
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :show_relative_scores, false)
    socket = assign(socket, :show_relative_scores_timer, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["compass", @seat]} phx-click="compass_clicked" phx-target={@myself}>
      <div class="centerpiece">
        <div class="tiles-left"><%= @tiles_left %></div>
        <div class="riichi-stick-counter" :if={@display_riichi_sticks}><%= @riichi_sticks %></div>
        <div class="honba-counter" :if={@display_honba}><%= @honba %></div>
      </div>
      <div class="score-box"></div>
      <%= for {dir, symbol, score} <- prepare_compass(assigns) do %>
        <div class={["direction", dir]}>
          <div class={["riichi-tray", @turn == dir && "highlighted", @riichi[dir] && "riichi"]}></div>
          <div class={["wind-marker", @turn == dir && "highlighted", @is_bot[dir] && "bot"]}><%= symbol %></div>
          <div class={["score-counter", score < 0 && "negative", dir != @seat and @show_relative_scores && "relative", abs(score) >= 1000000 && "scientific"]} :if={dir in @available_seats}>
            <%= if abs(score) >= 1000000 and @score_e_notation do %>
              <%= if dir != @seat and @show_relative_scores and score >= 0 do "+" else "" end %><%= mantissa(score) %>e<b><%= exponent(score) %></b>
            <% else %>
              <%= if dir != @seat and @show_relative_scores and score >= 0 do "+" else "" end %><%= score %>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mantissa(score) do
    chars = 4 + if score < 0 do 1 else 0 end - if exponent(score) >= 10 do 1 else 0 end
    1.0 * score |> :erlang.float_to_binary() |> String.slice(0..chars)
  end

  def exponent(score) do
    score |> abs() |> :math.log10() |> trunc()
  end

  def prepare_compass(assigns) do
    symbols = %{east: "東", south: "南", west: "西", north: "北"}
    Enum.map([:east, :south, :west, :north], fn seat -> 
      if seat in assigns.available_seats do
        score = assigns.score[seat]
        score = if seat != assigns.seat and assigns.show_relative_scores do score - assigns.score[assigns.seat] else score end
        {seat, symbols[Riichi.get_seat_wind(assigns.kyoku, seat, assigns.available_seats)], score}
      else
        {seat, "", 0}
      end
    end)
  end

  def handle_event("compass_clicked", _assigns, socket) do
    socket = assign(socket, :show_relative_scores, true)
    if Map.get(socket.assigns, :show_relative_scores_timer) != nil do Process.cancel_timer(socket.assigns.show_relative_scores_timer) end
    timer = send_update_after(self(), __MODULE__, [id: "compass", show_relative_scores: false, show_relative_scores_timer: nil], 2000)
    socket = assign(socket, :show_relative_scores_timer, timer)
    # spawn ai
    GenServer.cast(socket.assigns.game_state, {:fill_empty_seats_with_ai, true})
    # notify ai
    GenServer.cast(socket.assigns.game_state, :notify_ai)
    {:noreply, socket}
  end
end
