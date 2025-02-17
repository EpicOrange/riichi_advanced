defmodule RiichiAdvancedWeb.ScryedTilesComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :game_state, nil)
    socket = assign(socket, :wall, [])
    socket = assign(socket, :wall_index, 0)
    socket = assign(socket, :num_scryed_tiles, 0)
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="scryed-tiles-container">
      <div class={[@id]}>
        <%= if Enum.empty?(@marking) do %>
          <div class={["tile", Utils.strip_attrs(tile)]} :for={tile <- prepare_scryed_tiles(assigns)}></div>
        <% else %>
          <%= for {tile, i} <- prepare_scryed_tiles(assigns) do %>
            <%= if GenServer.call(@game_state, {:can_mark?, @viewer, nil, i, :scry}) do %>
              <div class={["tile", Utils.strip_attrs(tile), "markable"]} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
            <% else %>
              <%= if GenServer.call(@game_state, {:is_marked?, @viewer, nil, i, :scry}) do %>
                <div class={["tile", Utils.strip_attrs(tile), "marked"]}></div>
              <% else %>
                <div class={["tile", Utils.strip_attrs(tile)]}></div>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  def prepare_scryed_tiles(assigns) do
    # need to pass in assigns, so that this updates when marking updates
    Enum.slice(assigns.wall, assigns.wall_index, assigns.num_scryed_tiles)
    |> Enum.with_index()
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, nil, ix, :scry})
    {:noreply, socket}
  end

end
