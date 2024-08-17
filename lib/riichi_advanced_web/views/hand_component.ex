defmodule RiichiAdvancedWeb.HandComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :played_tile, nil)
    socket = assign(socket, :played_tile_index, nil)
    socket = assign(socket, :animating_played_tile, false)
    socket = assign(socket, :num_new_calls, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= if @your_hand? do %>
        <div class="tiles" phx-hook="Sortable" id={@id}>
          <%= for {i, tile, removed} <- prepare_hand(assigns) do %>
            <%= if removed do %>
              <div class={["tile", tile, "removed"]} data-id={i}></div>
            <% else %>
              <%= if not @your_turn? || GenServer.call(RiichiAdvanced.GameState, {:is_playable, @seat, tile, :hand}) do %>
                <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} phx-value-index={i} class={["tile", tile]} data-id={i}></div>
              <% else %>
                <div class={["tile", tile, "inactive"]} data-id={i}></div>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <div class="draws">
          <%= for {tile, i} <- prepare_draw(assigns) do %>
            <%= if not @your_turn? || GenServer.call(RiichiAdvanced.GameState, {:is_playable, @seat, tile, :draw}) do %>
              <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} phx-value-index={length(assigns.hand) + i} class={["tile", tile]}></div>
            <% else %>
              <div class={["tile", tile, "inactive"]}></div>
            <% end %>
          <% end %>
        </div>
      <% else %>
        <div class="tiles">
          <%= for {i, tile, removed} <- prepare_hand(assigns) do %>
            <div class={["tile", tile, removed && "removed"]} data-id={i}></div>
          <% end %>
        </div>
        <div class="draws">
          <%= for {tile, _i} <- prepare_draw(assigns) do %>
            <div class={["tile", tile]}></div>
          <% end %>
        </div>
      <% end %>
      <div class="calls">
          <%= for {{_name, call}, i} <- Enum.with_index(@calls) do %>
            <div class={["call", (i >= length(@calls) - @num_new_calls) && "just_called"]}>
              <div class={["tile", tile, sideways && "sideways"]} :for={{tile, sideways} <- call}></div>
            </div>
          <% end %>
      </div>
    </div>
    """
  end

  def handle_event("play_tile", %{"tile" => tile, "index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    tile = Riichi.to_tile(tile)
    socket.assigns.play_tile.(tile, ix)
    {:noreply, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => to, "old" => from}, socket) do
    socket.assigns.reindex_hand.(from, to)
    {:noreply, socket}
  end

  def hide_tiles(tiles, assigns) do
    if assigns.your_hand? do tiles else Enum.map(tiles, fn _tile -> :"1x" end) end
  end

  def prepare_hand(assigns) do
    # map tiles to [{index, tile, is_last_discard}]
    assigns.hand
      |> hide_tiles(assigns)
      |> Enum.with_index
      |> Enum.map(fn {tile, i} -> {if assigns.played_tile_index != nil && i >= assigns.played_tile_index do i-1 else i end, tile, i == assigns.played_tile_index} end)
  end

  def prepare_draw(assigns) do
    # map tiles to [{index, tile}]
    # this function is necessary since we need phoenix to update draws when anything in assigns changes
    assigns.draw
      |> hide_tiles(assigns)
      |> Enum.with_index
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    # animate played tile by inserting an invisible tile at its index
    # this gets undone after 750ms
    socket = if Map.has_key?(socket.assigns, :played_tile_index) do
      socket = if socket.assigns.played_tile_index != nil do
        # randomize position of played tile (if tedashi)
        socket = if not socket.assigns.your_hand? && socket.assigns.played_tile_index < length(socket.assigns.hand) do
          assign(socket, :played_tile_index, Enum.random(1..length(socket.assigns.hand)) - 1)
          else socket end

        actual_hand = socket.assigns.hand
        socket = assign(socket, :hand, List.insert_at(actual_hand, socket.assigns.played_tile_index, socket.assigns.played_tile))
        :timer.apply_after(750, Kernel, :send, [self(), {:reset_anim, actual_hand, socket.assigns.seat}])
        socket
      else socket end
      socket
    else socket end
    {:ok, socket}
  end
end
