defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    tiles = ["1m", "2m", "3m", "4m", "5m", "6m",
             "1p", "2p", "3p", "4p", "5p", "6p",
             "1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"]
    socket = assign(socket, :tiles, tiles)
    socket = assign(socket, :last_tile, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= for tile <- @tiles do %>
        <div class={["tile", tile, tile == @last_tile && "just-played"]}></div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assign(socket, :id, assigns.id)
    if Map.has_key?(assigns, :played_tile) do
      tiles = socket.assigns.tiles ++ [assigns.played_tile]
      socket = assign(socket, :tiles, tiles)
      socket = assign(socket, :last_tile, assigns.played_tile)
      {:ok, socket}
    else
      {:ok, socket}
    end
  end
end
