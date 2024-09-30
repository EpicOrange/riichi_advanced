defmodule RiichiAdvancedWeb.WinWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :winners, %{})
    socket = assign(socket, :winner, nil)
    socket = assign(socket, :timer, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", @visible_screen != :winner && "inactive"]}>
      <%= if @winner != nil && Map.has_key?(@winner, :yaku) && @winner.yaku != nil do %>
        <div class="hand winning-hand">
          <div class={["tile", tile]} :for={tile <- @winner.player.hand}></div>
          <%= for {_name, call} <- @winner.player.calls do %>
            <div class="call">
              <div class={["tile", tile, sideways && "sideways"]} :for={{tile, sideways} <- call}></div>
            </div>
          <% end %>
          <div class="winning-tile-container">
            <div class={["tile", "winning-tile", @winner.winning_tile]}></div>
            <div class="winning-tile-text"><%= @winner.winning_tile_text %></div>
          </div>
        </div>
        <div class="yakus">
          <%= for {name, points} <- @winner.yaku do %>
            <div class="yaku">
              <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= name %></div>
              <div class="han-counter"><%= points %> <%= @winner.point_name %></div>
            </div>
          <% end %>
          <%= for {name, points} <- @winner.yakuman do %>
            <div class="yaku">
              <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= name %></div>
              <div class="han-counter"><%= points %> <%= @winner.limit_point_name %></div>
            </div>
          <% end %>
        </div>
        <div class="score-display">
          <div class="total-han-display"><%= @winner.points %> <%= @winner.point_name %></div>
          <div class="total-fu-display" :if={Map.has_key?(@winner, :minipoints)}><%= @winner.minipoints %> <%= @winner.minipoint_name %></div>
          <div class="total-score-display"><%= @winner.score %></div>
          <div class="total-score-name-display" :if={Map.has_key?(@winner, :score_name) && @winner.score_name != ""}><%= @winner.score_name %></div>
        </div>
        <div class="timer" phx-click="ready_for_next_round"><%= @timer %></div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = if Map.has_key?(assigns, :winners) do
      if not Enum.empty?(assigns.winners) do
        {_seat, winner} = Enum.at(assigns.winners, assigns.winner_index)
        socket = assign(socket, :winner, winner)
        socket
      else
        socket = assign(socket, :winner, nil)
        socket
      end
    else socket end
    {:ok, socket}
  end
end
