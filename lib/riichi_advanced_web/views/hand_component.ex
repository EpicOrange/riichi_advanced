defmodule RiichiAdvancedWeb.HandComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :played_tile_index, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= if @your_hand? do %>
        <div class="tiles" phx-hook="Sortable" id={@id}>
          <%= for {i, tile, removed} <- prepare_tiles(assigns) do %>
            <%= if removed do %>
              <div class={["tile", tile, "removed"]} data-id={i}></div>
            <% else %>
              <%= if not @your_turn? || RiichiAdvanced.GlobalState.is_playable(tile) do %>
                <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} phx-value-index={i} class={["tile", tile]} data-id={i}></div>
              <% else %>
                <div class={["tile", tile, "inactive"]} data-id={i}></div>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <div class="draws">
          <%= for {tile, i} <- Enum.with_index(assigns.draw) do %>
            <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} phx-value-index={length(assigns.hand) + i} class={["tile", tile]}></div>
          <% end %>
        </div>
      <% else %>
        <div class="tiles">
          <%= for {i, tile, removed} <- prepare_tiles(assigns) do %>
            <div class={["tile", tile, removed && "removed"]} data-id={i}></div>
          <% end %>
        </div>
        <div class="draws">
          <%= for tile <- assigns.draw do %>
            <div class={["tile", tile]}></div>
          <% end %>
        </div>
      <% end %>
      <div class="calls">
      </div>
    </div>
    """
  end

  def handle_event("play_tile", %{"tile" => tile, "index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.play_tile.(tile, ix)
    {:noreply, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => to, "old" => from}, socket) do
    socket.assigns.reindex_hand.(from, to)
    {:noreply, socket}
  end

  def prepare_tiles(assigns) do
    # map tiles to [{index, tile, is_last_discard}]
    assigns.hand
      |> Enum.with_index
      |> Enum.map(fn {tile, i} -> {i, tile, i == assigns.played_tile_index} end)
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    if Map.has_key?(assigns, :played_tile_index) && assigns.played_tile_index < length(socket.assigns.hand) do
      # Animate the last tile
      IO.puts("Animating tile at index #{assigns.played_tile_index}")
      socket = assign(socket, :hand, List.insert_at(socket.assigns.hand, assigns.played_tile_index, assigns.played_tile))
      {:ok, socket}
    else
      socket = assign(socket, :played_tile_index, nil)
      {:ok, socket}
    end
  end
end
