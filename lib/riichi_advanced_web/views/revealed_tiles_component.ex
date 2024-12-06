defmodule RiichiAdvancedWeb.RevealedTilesComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :game_state, nil)
    socket = assign(socket, :revealed_tiles, nil)
    socket = assign(socket, :max_revealed_tiles, 0)
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(prepare_revealed_tiles(assigns.revealed_tiles, assigns.marking))
    ~H"""
    <div class={[@id]}>
      <%= if Enum.empty?(@marking) do %>
        <div class={["tile", Utils.strip_attrs(tile), Utils.has_attr?(tile, ["transparent"]) && "transparent"]} :for={{tile, _i} <- prepare_revealed_tiles(@revealed_tiles, @marking)}></div>
      <% else %>
        <%= for {tile, i} <- prepare_revealed_tiles(@revealed_tiles, @marking) do %>
          <%= if GenServer.call(@game_state, {:can_mark?, @viewer, nil, i, :revealed_tile}) do %>
            <div class={["tile", Utils.strip_attrs(tile), Utils.has_attr?(tile, ["transparent"]) && "transparent", "markable"]} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <%= if GenServer.call(@game_state, {:is_marked?, @viewer, nil, i, :revealed_tile}) do %>
              <div class={["tile", Utils.strip_attrs(tile), Utils.has_attr?(tile, ["transparent"]) && "transparent", "marked"]}></div>
            <% else %>
              <div class={["tile", Utils.strip_attrs(tile), Utils.has_attr?(tile, ["transparent"]) && "transparent"]}></div>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
      <div class={["tile", tile]} :for={tile <- prepare_unrevealed_tiles(@revealed_tiles, @max_revealed_tiles)}></div>
    </div>
    """
  end

  def prepare_revealed_tiles(revealed_tiles, _marking) do
    # need to pass in marking arg, so that this updates when marking updates
    if revealed_tiles != nil do
      revealed_tiles
      |> Enum.with_index()
    else [] end
  end

  def prepare_unrevealed_tiles(revealed_tiles, max_revealed_tiles) do
    num_unrevealed_tiles = if revealed_tiles == nil do 0 else max(0, max_revealed_tiles - length(revealed_tiles)) end
    List.duplicate(:"1x", num_unrevealed_tiles)
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, nil, ix, :revealed_tile})
    {:noreply, socket}
  end

end
