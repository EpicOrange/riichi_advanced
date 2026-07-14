defmodule RiichiAdvancedWeb.HandSelectionComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:hand, [])
    |> assign(:calls, [])
    |> assign(:call_selection_ixs, [])
    |> assign(:call_buttons, %{})
    |> assign(:selected_call_button, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["hand-selection-container", "yaku-#{@ruleset}"]}>
      <div class="hand-selection-inner-container">
        Hand:
        <div class="hand-selection-hand">
          <%= for {tile, i} <- Enum.with_index(@hand) |> Enum.take(@hand_length) do %>
            <%= if @selected_call_button != nil do %>
              <%= if i in @call_selection_ixs do %>
                <button type="button" phx-cancellable-click="exclude_hand_tile" phx-value-index={i}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat", "marked"])}></div></button>
              <% else %>
                <button type="button" phx-cancellable-click="include_hand_tile" phx-value-index={i}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat", "markable"])}></div></button>
              <% end %>
            <% else %>
              <button type="button" phx-cancellable-click="remove_hand_tile" phx-value-index={i}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div></button>
            <% end %>
          <% end %>
          <%= if length(@hand) < @hand_length do %>
            <%= for _i <- length(@hand)..(@hand_length - 1) do %>
              <button type="button"><div class={"tile flat 1x"}></div></button>
            <% end %>
          <% end %>
          <%= for {{_name, call_tiles}, i} <- @calls |> Enum.with_index() |> Enum.reverse() do %>
            <button type="button" class="hand-selection-call" phx-cancellable-click="remove_call" phx-value-index={i}>
              <%= for tile <- call_tiles do %>
                <div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div>
              <% end %>
            </button>
          <% end %>
          <%= if length(@hand) <= @hand_length do %>
            <button type="button"><div class={"tile flat 1x"}></div></button>
          <% end %>
          <%= if length(@hand) > @hand_length do %>
            <%= if @selected_call_button != nil do %>
              <%= if @hand_length in @call_selection_ixs do %>
                <button type="button" phx-cancellable-click="exclude_hand_tile" phx-value-index={@hand_length}><div class={@hand |> Enum.at(-1) |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat", "marked"])}></div></button>
              <% else %>
                <button type="button" phx-cancellable-click="include_hand_tile" phx-value-index={@hand_length}><div class={@hand |> Enum.at(-1) |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat", "markable"])}></div></button>
              <% end %>
            <% else %>
              <button type="button" phx-cancellable-click="remove_hand_tile" phx-value-index={@hand_length}><div class={@hand |> Enum.at(-1) |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div></button>
            <% end %>
          <% end %>
        </div>
        <div class="hand-selection-buttons">
          <%= for tile <- @tiles do %>
            <button type="button" phx-cancellable-click="add_hand_tile" phx-value-tile={tile}><div class={tile |> Utils.to_tile() |> Utils.get_tile_class(-1, %{}, ["flat"])}></div></button>
          <% end %>
        </div>
        <div class="hand-selection-calls">
          <%= for {name, button} <- @call_buttons do %>
            <%= if @selected_call_button == name do %>
              <button type="button" class="button scoringtest_call_button pressed" phx-cancellable-click="deselect_call_button"><%= button["display_name"] %></button>
            <% else %>
              <button type="button" class="button scoringtest_call_button" phx-cancellable-click="select_call_button" phx-value-name={name}><%= button["display_name"] %></button>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

end
