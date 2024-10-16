defmodule RiichiAdvancedWeb.RevealedTilesComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :revealed_tiles, [])
    socket = assign(socket, :max_revealed_tiles, 0)
    socket = assign(socket, :reserved_tiles, [])
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <%= if Enum.empty?(@marking) do %>
        <div class={["tile", Utils.strip_attrs(tile)]} :for={tile <- prepare_revealed_tiles(@revealed_tiles, @reserved_tiles, @marking)}></div>
      <% else %>
        <%= for {tile, i} <- prepare_revealed_tiles(@revealed_tiles, @reserved_tiles, @marking) do %>
          <%= if GenServer.call(@game_state, {:can_mark?, @viewer, nil, i, :revealed_tile}) do %>
            <div class={["tile", Utils.strip_attrs(tile), "markable"]} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <%= if GenServer.call(@game_state, {:is_marked?, @viewer, nil, i, :revealed_tile}) do %>
              <div class={["tile", Utils.strip_attrs(tile), "marked"]}></div>
            <% else %>
              <div class={["tile", Utils.strip_attrs(tile)]}></div>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
      <div class={["tile", "1x"]} :for={_ <- length(@revealed_tiles)+1..@max_revealed_tiles//1}></div>
    </div>
    """
  end

  def prepare_revealed_tiles(revealed_tiles, reserved_tiles, _marking) do
    # need to pass in the marking arg, so that this updates when marking updates
    for tile_spec <- revealed_tiles do
      {_, tile} = List.keyfind(reserved_tiles, tile_spec, 0, {tile_spec, Utils.to_tile(tile_spec)})
      tile
    end |> Enum.with_index()
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, nil, ix, :revealed_tile})
    {:noreply, socket}
  end

end
