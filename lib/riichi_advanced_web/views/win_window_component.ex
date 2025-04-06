defmodule RiichiAdvancedWeb.WinWindowComponent do
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

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
              <%= for {{name, call}, i} <- Enum.with_index(process_calls(@winner.player.calls)) do %>
                <div class={["call", (name == "_flowers" and length(call) > 3) && "winning-flowers"]}>
                  <div class="flower-count" :if={name == "_flowers" and length(call) > 3}>&#215;<%= length(call) %></div>
                  <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
                </div>
              <% end %>
              <div class="winning-tile-container">
                <div class={Utils.get_tile_class(@winner.winning_tile, nil, assigns, ["winning-tile"])}></div>
                <div class="winning-tile-text"><%= dt(@lang, @winner.winning_tile_text) %></div>
              </div>
            </div>
            <div class="hand winning-hand separated-hand">
              <div class={Utils.get_tile_class(tile, i, assigns)} :for={{tile, i} <- Enum.with_index(@winner.separated_hand)}></div>
              <%= for {{name, call}, i} <- Enum.with_index(process_calls(@winner.player.calls)) do %>
                <div class={["call", (name == "_flowers" and length(call) > 3) && "winning-flowers"]}>
                  <div class="flower-count" :if={name == "_flowers" and length(call) > 3}>&#215;<%= length(call) %></div>
                  <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
                </div>
              <% end %>
              <div class="winning-tile-container">
                <div class={Utils.get_tile_class(@winner.winning_tile, nil, assigns, ["winning-tile"])}></div>
                <div class="winning-tile-text"><%= dt(@lang, @winner.winning_tile_text) %></div>
              </div>
            </div>
          </div>
          <div class="yakus">
            <%= for {name, points} <- @winner.yaku do %>
              <div class="yaku">
                <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= dt(@lang, name) %></div>
                <div class="han-counter"><%= Utils.try_integer(points) %> <%= dt(@lang, @winner.point_name) %></div>
              </div>
            <% end %>
            <%= for {name, points} <- @winner.yaku2 do %>
              <div class="yaku">
                <div class={["yaku-text", String.length(name) >= 12 && "small", String.length(name) >= 20 && "tiny"]}><%= dt(@lang, name) %></div>
                <div class="han-counter"><%= Utils.try_integer(points) %> <%= dt(@lang, @winner.point2_name) %></div>
              </div>
            <% end %>
          </div>
          <div class="score-display">
            <div class="total-han-display"><%= Utils.try_integer(@winner.points) %> <%= dt(@lang, @winner.point_name) %></div>
            <div class="total-fu-display" :if={@winner.right_display != nil}><%= @winner.right_display %> <%= dt(@lang, @winner.right_display_name) %></div>
            <div class={["total-score-display", String.length("#{@winner.score} #{@winner.score_denomination}") >= 12 && "small"]}><%= @winner.displayed_score %> <%= dt(@lang, @winner.score_denomination) %></div>
            <div class={["total-score-name-display", String.length("#{@winner.score_name}") >= 12 && "small"]} :if={Map.has_key?(@winner, :score_name) and @winner.score_name != nil}><%= dt(@lang, @winner.score_name) %></div>
          </div>
        <% end %>
      </div>
      <div class="timer" phx-cancellable-click="ready_for_next_round">Skip (<%= @timer %>)</div>
    </div>
    """
  end

  def process_calls(calls) do
    # combine all flower calls into one call
    # the UI will display this specially if there are too many flowers
    {flowers, calls} = Enum.split_with(calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    calls ++ [{"_flowers", Enum.flat_map(flowers, &Utils.call_to_tiles/1)}]
  end
end
