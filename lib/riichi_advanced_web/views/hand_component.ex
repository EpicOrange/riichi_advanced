defmodule RiichiAdvancedWeb.HandComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :your_hand?, false)
    socket = assign(socket, :revealed?, false)
    socket = assign(socket, :played_tile, nil)
    socket = assign(socket, :played_tile_index, nil)
    socket = assign(socket, :animating_played_tile, false)
    socket = assign(socket, :just_called, false)
    socket = assign(socket, :status, [])
    socket = assign(socket, :calls, [])
    socket = assign(socket, :marking, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= if @your_hand? do %>
        <%= if @marking do %>
          <div class="tiles">
            <%= for {i, tile, removed} <- prepare_hand(assigns) do %>
              <%= if removed do %>
                <div class={["tile", tile, "removed"]} data-id={i}></div>
              <% else %>
                <%= if GenServer.call(@game_state, {:can_mark, @seat, i, :hand}) do %>
                  <div class={["tile", tile, "markable"]} phx-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
                <% else %>
                  <%= if GenServer.call(@game_state, {:is_marked, @seat, i, :hand}) do %>
                    <div class={["tile", tile, "marked"]}></div>
                  <% else %>
                    <div class={["tile", tile]}></div>
                  <% end %>
                <% end %>
              <% end %>
            <% end %>
          </div>
          <div class="draws">
            <%= for {tile, i} <- prepare_draw(assigns) do %>
              <%= if GenServer.call(@game_state, {:can_mark, @seat, length(assigns.hand) + i, :hand}) do %>
                <div class={["tile", tile, "markable"]} phx-click="mark_tile" phx-target={@myself} phx-value-index={length(assigns.hand) + i}></div>
              <% else %>
                <%= if GenServer.call(@game_state, {:is_marked, @seat, length(assigns.hand) + i, :hand}) do %>
                  <div class={["tile", tile, "marked"]}></div>
                <% else %>
                  <div class={["tile", tile]}></div>
                <% end %>
              <% end %>
            <% end %>
          </div>

        <% else %>
          <div class="tiles" phx-hook="Sortable" id={@id}>
            <%= for {i, tile, removed} <- prepare_hand(assigns) do %>
              <%= if removed do %>
                <div class={["tile", tile, "removed"]} data-id={i}></div>
              <% else %>
                <%= if not @your_turn? || GenServer.call(@game_state, {:is_playable, @seat, tile, :hand}) do %>
                  <div phx-click="play_tile" phx-target={@myself} phx-value-tile={tile} phx-value-index={i} class={["tile", tile]} data-id={i}></div>
                <% else %>
                  <div class={["tile", tile, "inactive"]} data-id={i}></div>
                <% end %>
              <% end %>
            <% end %>
          </div>
          <div class="draws">
            <%= for {tile, i} <- prepare_draw(assigns) do %>
              <%= if not @your_turn? || GenServer.call(@game_state, {:is_playable, @seat, tile, :draw}) do %>
                <div phx-click="play_tile" phx-target={@myself} phx-value-index={length(assigns.hand) + i} class={["tile", tile]}></div>
              <% else %>
                <div class={["tile", tile, "inactive"]}></div>
              <% end %>
            <% end %>
          </div>
        <% end %>
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
            <div class={["call", @just_called && i == length(@calls) - 1 && "just_called"]}>
              <div class={["tile", tile, sideways && "sideways"]} :for={{tile, sideways} <- call}></div>
            </div>
          <% end %>
      </div>
    </div>
    """
  end

  def handle_event("play_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.play_tile.(ix)
    {:noreply, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => to, "old" => from}, socket) do
    socket.assigns.reindex_hand.(from, to)
    {:noreply, socket}
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.seat, ix, :hand})
    {:noreply, socket}
  end

  def hide_tiles(tiles, assigns) do
    if assigns.revealed? do tiles else Enum.map(tiles, fn _tile -> :"1x" end) end
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
    # randomize position of played tile (if tedashi)
    no_played_tile_yet? = socket.assigns.played_tile_index == nil
    assigns = if not socket.assigns.revealed? && Map.has_key?(assigns, :played_tile_index) && assigns.played_tile_index != nil && assigns.played_tile_index < length(socket.assigns.hand) do
      if no_played_tile_yet? do
        Map.put(assigns, :played_tile_index, Enum.random(1..length(socket.assigns.hand)) - 1)
      else
        Map.put(assigns, :played_tile_index, socket.assigns.played_tile_index)
      end
    else assigns end

    # animate incoming calls
    socket = if Map.has_key?(assigns, :calls) && length(assigns.calls) > length(socket.assigns.calls) do
      socket = assign(socket, :just_called, true)
      :timer.apply_after(750, Kernel, :send, [self(), {:reset_call_anim, socket.assigns.seat}])
      socket
    else socket end

    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    # animate played tile by inserting an invisible tile at its index
    # this gets undone after 750ms
    socket = if Map.has_key?(socket.assigns, :played_tile_index) do
      socket = if socket.assigns.played_tile_index != nil do
        actual_hand = socket.assigns.hand ++ socket.assigns.draw
        socket = assign(socket, :hand, List.insert_at(actual_hand, socket.assigns.played_tile_index, socket.assigns.played_tile))
        :timer.apply_after(750, Kernel, :send, [self(), {:reset_hand_anim, socket.assigns.seat}])
        socket
      else socket end
      socket
    else socket end

    socket = assign(socket, :marking, socket.assigns.saki != nil && GenServer.call(socket.assigns.game_state, :needs_marking))

    {:ok, socket}
  end
end
