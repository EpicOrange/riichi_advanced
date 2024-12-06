defmodule RiichiAdvancedWeb.WinWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :winner, nil)
    socket = assign(socket, :timer, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", @visible_screen != :winner && "inactive"]}>
      <%= if @winner != nil && Map.has_key?(@winner, :yaku) && @winner.yaku != nil do %>
        <div class="hand winning-hand">
          <div class={["tile", Utils.strip_attrs(tile), Utils.has_attr?(tile, ["transparent"]) && "transparent"]} :for={tile <- @winner.player.hand}></div>
          <%= for {_name, call} <- @winner.player.calls do %>
            <div class="call">
              <div class={["tile", Utils.strip_attrs(tile), sideways && "sideways", Utils.has_attr?(tile, ["transparent"]) && "transparent"]} :for={{tile, sideways} <- call}></div>
            </div>
          <% end %>
          <div class="winning-tile-container">
            <div class={["tile", "winning-tile", Utils.strip_attrs(@winner.winning_tile)]}></div>
            <div class="winning-tile-text"><%= @winner.winning_tile_text %></div>
          </div>
        </div>
        <div class="yakus">
          <%= for {name, points} <- @winner.yaku do %>
            <div class="yaku">
              <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= name %></div>
              <div class="han-counter"><%= Utils.try_integer(points) %> <%= @winner.point_name %></div>
            </div>
          <% end %>
          <%= for {name, points} <- @winner.yaku2 do %>
            <div class="yaku">
              <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= name %></div>
              <div class="han-counter"><%= Utils.try_integer(points) %> <%= @winner.point2_name %></div>
            </div>
          <% end %>
        </div>
        <div class="score-display">
          <div class="total-han-display"><%= Utils.try_integer(@winner.points) %> <%= @winner.point_name %></div>
          <div class="total-fu-display" :if={@winner.right_display != nil}><%= @winner.right_display %> <%= @winner.right_display_name %></div>
          <div class="total-score-display"><%= @winner.score %> <%= @winner.score_denomination %></div>
          <div class="total-score-name-display" :if={Map.has_key?(@winner, :score_name) && @winner.score_name != ""}><%= @winner.score_name %></div>
        </div>
        <div class="timer" phx-cancellable-click="ready_for_next_round"><%= @timer %></div>
      <% end %>
    </div>
    """
  end
end
