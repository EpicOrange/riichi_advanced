defmodule RiichiAdvancedWeb.RevealedTilesComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :game_state, nil)
    socket = assign(socket, :revealed_tiles, [])
    socket = assign(socket, :max_revealed_tiles, 0)
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <%= if Enum.empty?(@marking) do %>
        <div class={["tile", Utils.strip_attrs(tile)]} :for={tile <- prepare_revealed_tiles(@game_state, @revealed_tiles, @marking)}></div>
      <% else %>
        <%= for {tile, i} <- prepare_revealed_tiles(@game_state, @revealed_tiles, @marking) do %>
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

  def prepare_revealed_tiles(game_state, _revealed_tiles, _marking) do
    # need to pass in the revealed_tiles and marking args, so that this updates when revealed_tiles/marking updates
    if game_state != nil do
      GenServer.call(game_state, :get_revealed_tiles)
      |> Enum.with_index()
    else [] end
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, nil, ix, :revealed_tile})
    {:noreply, socket}
  end

end
