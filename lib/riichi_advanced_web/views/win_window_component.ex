defmodule RiichiAdvancedWeb.WinWindowComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :winner, nil)
    socket = assign(socket, :timer, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-modal-container", @visible_screen != :winner && "inactive"]}>
      <div class="game-modal game-modal-hide">
        <%= if @winner != nil and Map.has_key?(@winner, :yaku) and @winner.yaku != nil do %>
          <div class="winning-hand-container">
            <div class="hand winning-hand">
              <div class={Utils.get_tile_class(tile, i, assigns)} :for={{tile, i} <- Enum.with_index(@winner.player.hand)}></div>
              <%= for {{_name, call}, i} <- Enum.with_index(@winner.player.calls) do %>
                <div class="call">
                  <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
                </div>
              <% end %>
              <div class="winning-tile-container">
                <div class={["tile", "winning-tile", Utils.strip_attrs(@winner.winning_tile), Utils.has_attr?(@winner.winning_tile, ["transparent"]) && "transparent"]}></div>
                <div class="winning-tile-text"><%= @winner.winning_tile_text %></div>
              </div>
            </div>
            <div class="hand winning-hand separated-hand">
              <div class={Utils.get_tile_class(tile, i, assigns)} :for={{tile, i} <- Enum.with_index(@winner.separated_hand)}></div>
              <%= for {{_name, call}, i} <- Enum.with_index(@winner.player.calls) do %>
                <div class="call">
                  <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
                </div>
              <% end %>
              <div class="winning-tile-container">
                <div class={["tile", "winning-tile", Utils.strip_attrs(@winner.winning_tile), Utils.has_attr?(@winner.winning_tile, ["transparent"]) && "transparent"]}></div>
                <div class="winning-tile-text"><%= @winner.winning_tile_text %></div>
              </div>
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
            <div class={["total-score-display", String.length("#{@winner.score} #{@winner.score_denomination}") >= 12 && "small"]}><%= @winner.score %> <%= @winner.score_denomination %></div>
            <div class={["total-score-name-display", String.length("#{@winner.score_name}") >= 12 && "small"]} :if={Map.has_key?(@winner, :score_name) and @winner.score_name != ""}><%= @winner.score_name %></div>
          </div>
        <% end %>
      </div>
      <div class="timer" phx-cancellable-click="ready_for_next_round">Skip (<%= @timer %>)</div>
    </div>
    """
  end
end
