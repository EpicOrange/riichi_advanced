defmodule RiichiAdvancedWeb.HandComponent do
  use RiichiAdvancedWeb, :live_component

  # This function initializes the state
  def mount(socket) do
    hand = ["1m","2m","3m","4m","5m","6m","7m","8m","9m"]
    draw = "0m"
    socket = assign(socket, :hand, hand)
    socket = assign(socket, :last_tile, nil)
    socket = assign(socket, :draw, draw)
    {:ok, socket}
  end

  # Render the template using the assigned state
  def render(assigns) do
    ~H"""
    <div class={@id}>
      <div class="tiles">
        <%= if @your_turn do %>
          <%= for {tile, draw, removed} <- prepare_tiles(assigns) do %>
            <%= if removed do %>
              <div class={["tile", tile, draw && "draw", "removed"]}></div>
            <% else %>
              <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} class={["tile", tile, draw && "draw"]}></div>
            <% end %>
          <% end %>
        <% else %>
          <%= for {tile, draw, removed} <- prepare_tiles(assigns) do %>
            <div class={["tile", tile, draw && "draw", removed && "removed"]}></div>
          <% end %>
        <% end %>
      </div>
      <div class="calls">
        <div class="call">
          <div class="tile 7p sideways"></div>
          <div class="tile 6p"></div>
          <div class="tile 8p"></div>
        </div>
        <div class="call">
          <div class="tile 1x"></div>
          <div class="tile 4p"></div>
          <div class="tile 4p"></div>
          <div class="tile 1x"></div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("play_tile", %{"tile" => tile}, socket) do
    socket.assigns.play_tile.(tile)
    {:noreply, socket}
  end

  def prepare_tiles(assigns) do
    # map tiles to [{tile, is_draw, is_last_discard}]
    {result, _found} = Enum.reduce(assigns.hand ++ [assigns.draw], {[], false}, fn tile, {acc, found} ->
      if tile == assigns.last_tile and not found do
        {[{tile, tile == assigns.draw, true} | acc], true}
      else
        {[{tile, tile == assigns.draw, false} | acc], found}
      end
    end)
    Enum.reverse(result) # since reduce accumulates in reverse order
  end

  def update(assigns, socket) do
    socket = assign(socket, :id, assigns.id)
    socket = if Map.has_key?(assigns, :seat) do assign(socket, :seat, assigns.seat) else socket end
    socket = if Map.has_key?(assigns, :your_turn) do assign(socket, :your_turn, assigns.your_turn) else socket end
    socket = if Map.has_key?(assigns, :play_tile) do assign(socket, :play_tile, assigns.play_tile) else socket end
    if Map.has_key?(assigns, :played_tile) do
      hand = socket.assigns.hand
      last_tile = socket.assigns.last_tile
      socket = assign(socket, :last_tile, assigns.played_tile)
      socket = assign(socket, :your_turn, false)
      if Enum.member?(hand, last_tile) do
        hand = List.delete_at(hand, Enum.find_index(hand, fn x -> x == last_tile end))
        socket = assign(socket, :hand, hand)
        {:ok, socket}
      else
        {:ok, socket}
      end
    else
      {:ok, socket}
    end
  end
end
