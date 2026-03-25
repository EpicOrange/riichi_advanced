defmodule RiichiAdvancedWeb.HandSelectionComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :hand, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["hand-selection-container", "yaku-#{@ruleset}"]}>
      <div class="hand-selection-inner-container">
        Hand:
        <div class="hand-selection-hand">
          <%= for {tile, i} <- Enum.with_index(@hand) do %>
            <button type="button" phx-cancellable-click="remove_hand_tile" phx-value-index={i}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div></button>
          <% end %>
          <%= if length(@hand) < 14 do %>
            <%= for _i <- length(@hand)..13 do %>
              <button type="button"><div class={"tile flat 1x"}></div></button>
            <% end %>
          <% end %>
        </div>
        <div class="hand-selection-buttons">
          <%= for tile <- @tiles do %>
            <button type="button" phx-cancellable-click="add_hand_tile" phx-value-tile={tile}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div></button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

end
