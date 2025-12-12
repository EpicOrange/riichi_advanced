defmodule RiichiAdvancedWeb.HandComponent do
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :your_hand?, false)
    socket = assign(socket, :revealed?, false)
    socket = assign(socket, :hover_index, nil)
    socket = assign(socket, :played_tile, nil)
    socket = assign(socket, :played_tile_index, nil)
    socket = assign(socket, :animating_played_tile, false)
    socket = assign(socket, :just_called, nil)
    socket = assign(socket, :just_upgraded, nil)
    socket = assign(socket, :just_called_flower, nil)
    socket = assign(socket, :just_drew, false)
    socket = assign(socket, :called_tile, nil)
    socket = assign(socket, :call_choice, nil)
    socket = assign(socket, :playable_indices, [])
    socket = assign(socket, :preplayed_index, nil)
    socket = assign(socket, :status, [])
    socket = assign(socket, :calls, [])
    socket = assign(socket, :aside, [])
    socket = assign(socket, :draw, [])
    socket = assign(socket, :marking, %{})
    socket = assign(socket, :dead_hand_buttons, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id, @just_called != nil && "just-called", @just_upgraded != nil && "just-upgraded", @just_called_flower != nil && "just-called-flower", @just_drew && "just-drew", not Enum.empty?(@marking) && "marking"]}>
      <%= if @your_hand? do %>
        <%= if not Enum.empty?(@marking) do %>
          <div class="tiles">
            <%= for {i, tile, removed, _highlight} <- prepare_hand(assigns) do %>
              <%= if removed do %>
                <div class={["tile", Utils.strip_attrs(tile), "removed"]} data-id={i}></div>
              <% else %>
                <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :hand}) do %>
                  <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} phx-cancellable-click="mark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
                <% else %>
                  <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :hand}) do %>
                    <div class={Utils.get_tile_class(tile, i, assigns, ["marked", "selected"])} phx-cancellable-click="unmark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
                  <% else %>
                    <div class={Utils.get_tile_class(tile, i, assigns, ["inactive"])} phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
                  <% end %>
                <% end %>
              <% end %>
            <% end %>
          </div>
          <div class="draws" :if={not Enum.empty?(@draw)}>
            <%= for {tile, i} <- prepare_draw(assigns) do %>
              <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :hand}) do %>
                <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} phx-cancellable-click="mark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
              <% else %>
                <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :hand}) do %>
                  <div class={Utils.get_tile_class(tile, i, assigns, ["marked", "selected"])} phx-cancellable-click="unmark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
                <% else %>
                  <div class={Utils.get_tile_class(tile, i, assigns, ["inactive"])} phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
                <% end %>
              <% end %>
            <% end %>
          </div>

        <% else %>
          <div class="tiles" phx-hook="Sortable" id={@id}>
            <%= for {i, tile, removed, highlight} <- prepare_hand(assigns) do %>
              <%= if removed do %>
                <div class={["tile", Utils.strip_attrs(tile), "removed"]} data-id={i}></div>
              <% else %>
                <%= if not @your_turn? or i in @playable_indices do %>
                  <div phx-cancellable-click="play_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i} class={Utils.get_tile_class(tile, i, assigns, [highlight && "highlight"], true)} data-id={i}></div>
                <% else %>
                  <div phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i} class={Utils.get_tile_class(tile, i, assigns, ["inactive", highlight && "highlight"], true)} data-id={i}></div>
                <% end %>
              <% end %>
            <% end %>
          </div>
          <div class="draws" :if={not Enum.empty?(@draw)}>
            <%= for {tile, i} <- prepare_draw(assigns) do %>
              <%= if not @your_turn? or i in @playable_indices do %>
                <div phx-cancellable-click="play_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i} class={Utils.get_tile_class(tile, i, assigns, [], true)}></div>
              <% else %>
                <div phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i} class={Utils.get_tile_class(tile, i, assigns, ["inactive"], true)} data-id={i}></div>
              <% end %>
            <% end %>
          </div>
        <% end %>
      <% else %>
        <div class="tiles">
          <%= for {i, tile, removed, highlight} <- prepare_hand(assigns) do %>
            <div class={Utils.get_tile_class(tile, i, assigns, [removed && "removed", highlight && "highlight"], true)} data-id={i}></div>
          <% end %>
        </div>
        <div class="draws" :if={not Enum.empty?(@draw)}>
          <%= for {tile, i} <- prepare_draw(assigns) do %>
            <div class={Utils.get_tile_class(tile, i, assigns, [], true)}></div>
          <% end %>
        </div>
      <% end %>
      <div class="calls">
        <%= if not Enum.empty?(@marking) do %>
          <%= for {{_name, call}, i} <- prepare_calls(assigns) do %>
            <div class="dead-hand-button inactive" :if={@dead_hand_buttons and i == 0 and @seat != @viewer and @viewer != :spectator}></div>
            <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :calls}) do %>
              <div class="call" phx-cancellable-click="mark_call" phx-target={@myself} phx-value-index={i}>
                <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} :for={tile <- call}></div>
              </div>
            <% else %>
              <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :calls}) do %>
                <div class="call" phx-cancellable-click="unmark_call" phx-target={@myself} phx-value-index={i}>
                  <div class={Utils.get_tile_class(tile, i, assigns, ["marked"])} :for={tile <- call}></div>
                </div>
              <% else %>
                <div class="call">
                  <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
                </div>
              <% end %>
            <% end %>
          <% end %>
        <% else %>
          <%= for {{_name, call}, i} <- prepare_calls(assigns) do %>
            <div class={["dead-hand-button", (not @your_turn? || @dead_hand?) && "inactive"]} phx-cancellable-click="declare_dead_hand" phx-value-seat={@seat} :if={@dead_hand_buttons and i == 0 and @seat != @viewer and @viewer != :spectator}></div>
            <div class={["call", @just_called == i && "just-called", @just_upgraded == i && "just-upgraded"]}>
              <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
            </div>
          <% end %>
        <% end %>
        <div class="call aside">
          <%= for {tile, i} <- prepare_aside(assigns) do %>
            <%= if not Enum.empty?(@marking) do %>
              <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :aside}) do %>
                <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} phx-cancellable-click="mark_tile_aside" phx-target={@myself} phx-value-index={i}></div>
              <% else %>
                <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :aside}) do %>
                  <div class={Utils.get_tile_class(tile, i, assigns, ["marked"])}></div>
                <% else %>
                  <div class={Utils.get_tile_class(tile, i, assigns)}></div>
                <% end %>
              <% end %>
            <% else %>
              <div class={Utils.get_tile_class(tile, i, assigns)}></div>
            <% end %>
          <% end %>
        </div>
      </div>
      <div class="calls flowers">
        <%= for {{_name, call}, i} <- prepare_flowers(assigns) do %>
          <div class={Utils.get_tile_class(tile, i, assigns)} :for={tile <- call}></div>
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

  def handle_event("hover_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket = assign(socket, :hover_index, ix)
    socket.assigns.hover.(ix)
    {:noreply, socket}
  end

  def handle_event("hover_off", _assigns, socket) do
    socket = assign(socket, :hover_index, nil)
    socket.assigns.hover_off.()
    {:noreply, socket}
  end

  def handle_event("reposition", %{"id" => _id, "new" => to, "old" => from}, socket) do
    socket.assigns.reindex_hand.(from, to)
    {:noreply, socket}
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.mark_tile.(ix, :hand)
    {:noreply, socket}
  end

  def handle_event("unmark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.unmark_tile.(ix, :hand)
    {:noreply, socket}
  end

  def handle_event("mark_call", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.mark_tile.(ix, :calls)
    {:noreply, socket}
  end

  def handle_event("unmark_call", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.unmark_tile.(ix, :calls)
    {:noreply, socket}
  end

  def handle_event("mark_tile_aside", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.mark_tile.(ix, :aside)
    {:noreply, socket}
  end

  def hide_tiles(tiles, revealed?) do
    if revealed? do tiles else Enum.map(tiles, fn tile ->
      if Utils.has_attr?(tile, ["revealed"]) do tile else :"1x" end
    end) end
  end

  def sort_value_by_visibility({tile, i}, assigns) do
    visible = assigns.revealed? or Utils.has_attr?(tile, ["revealed"]) and Map.get(assigns, :played_tile_index, nil) != i
    if visible do i + 100 else i end
  end

  def prepare_hand(assigns) do
    # map tiles to [{index, tile, is_last_discard, is highlighted}]
    # even if we didn't use assigns, we need to pass in assigns so that marking changes will update these tiles
    highlighted_indices = if assigns.your_hand? and assigns.called_tile != nil do
      highlighted_tiles = if assigns.your_turn? do
        [assigns.called_tile] ++ (if assigns.call_choice != nil do assigns.call_choice else [] end)
      else assigns.call_choice end
      {indices, _call_choice} = for {tile, i} <- Enum.with_index(assigns.hand), reduce: {[], highlighted_tiles} do
        {indices, tiles} ->
          case Enum.find_index(tiles, &Utils.same_tile(&1, tile)) do
            nil -> {indices, tiles}
            choice_ix -> {[i | indices], List.delete_at(tiles, choice_ix)}
          end
      end
      indices
    else [] end
    assigns.hand
    |> hide_tiles(assigns.revealed?)
    |> Enum.with_index()
    |> Enum.sort_by(&sort_value_by_visibility(&1, assigns))
    |> Enum.map(fn {tile, i} -> {
      if assigns.played_tile_index != nil and i >= assigns.played_tile_index do i-1 else i end,
      tile,
      i == assigns.played_tile_index,
      i in highlighted_indices
    } end)
  end

  def prepare_draw(assigns) do
    # map tiles to [{tile, index}]
    # even if we didn't use assigns, we need to pass in assigns so that marking changes will update these tiles
    assigns.draw
    |> hide_tiles(assigns.revealed?)
    |> Enum.with_index()
    |> Enum.map(fn {tile, ix} -> {tile, ix + length(assigns.hand)} end)
    |> Enum.sort_by(&sort_value_by_visibility(&1, assigns))
  end

  def mark_last_sideways(call) do
    {call, _} = for tile <- Enum.reverse(call), reduce: {[], false} do
      {acc, true}  -> {[tile | acc], true}
      {acc, false} ->
        if Utils.has_attr?(tile, ["_sideways"]) do
          {[Utils.add_attr(tile, ["_last_sideways"]) | acc], true}
        else {[tile | acc], false} end
    end
    call
  end

  def prepare_calls(assigns) do
    # map calls to [{call, index}], omitting flowers
    # even if we didn't use assigns, we need to pass in assigns so that marking changes will update these tiles
    assigns.calls
    |> Enum.with_index()
    |> Enum.reject(fn {{name, _call}, _i} -> name in Riichi.flower_names() end)
    |> Enum.map(fn {{name, call}, i} -> {{name, mark_last_sideways(call)}, i} end)
  end

  def prepare_flowers(assigns) do
    # map calls to [{flower, index}]
    # even if we didn't use assigns, we need to pass in assigns so that marking changes will update these tiles
    assigns.calls
    |> Enum.with_index()
    |> Enum.filter(fn {{name, _call}, _i} -> name in Riichi.flower_names() end)
  end

  def prepare_aside(assigns) do
    # map tiles to [{tile, index}]
    # even if we didn't use assigns, we need to pass in assigns so that marking changes will update these tiles
    assigns.aside
    |> hide_tiles(assigns.revealed?)
    |> Enum.with_index()
    |> Enum.sort_by(&sort_value_by_visibility(&1, assigns))
  end

  def update(assigns, socket) do
    # randomize position of played tile (if tedashi)
    no_played_tile_yet? = socket.assigns.played_tile_index == nil
    assigns = if not socket.assigns.revealed? and Map.has_key?(assigns, :played_tile_index) and assigns.played_tile_index != nil do
      not_visible = assigns.played_tile_index < length(socket.assigns.hand) and not Utils.has_attr?(Enum.at(socket.assigns.hand, assigns.played_tile_index), ["revealed"])
      if not_visible do
        if no_played_tile_yet? do
          Map.put(assigns, :played_tile_index, Enum.random(1..length(socket.assigns.hand)) - 1)
        else
          Map.put(assigns, :played_tile_index, socket.assigns.played_tile_index)
        end
      else assigns end
    else assigns end

    # animate incoming calls
    socket = if Map.has_key?(assigns, :calls) do
      changed_call_index = if length(socket.assigns.calls) < length(assigns.calls) do
        length(assigns.calls) - 1
      else
        Enum.zip(socket.assigns.calls, assigns.calls)
        |> Enum.find_index(fn {old, new} -> old != new end)
      end
      if changed_call_index != nil do
        {last_call_name, _last_call} = Enum.at(assigns.calls, -1)
        key = cond do
          last_call_name in Riichi.flower_names() -> :just_called_flower
          length(socket.assigns.calls) == length(assigns.calls) -> :just_upgraded
          true -> :just_called
        end
        socket = assign(socket, key, changed_call_index)
        :timer.apply_after(750, Kernel, :send, [self(), {:reset_call_anim, assigns.seat}])
        socket
      else socket end
    else socket end

    # animate incoming draws
    socket = if Map.has_key?(assigns, :draw) and length(assigns.draw) > length(socket.assigns.draw) do
      socket = assign(socket, :just_drew, true)
      :timer.apply_after(750, Kernel, :send, [self(), {:reset_draw_anim, assigns.seat}])
      socket
    else socket end

    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    # animate played tile by inserting an invisible tile at its index
    # this gets undone after 750ms by sending :reset_hand_anim
    socket = if Map.has_key?(socket.assigns, :played_tile_index) do
      socket = if socket.assigns.played_tile_index != nil do
        actual_hand = socket.assigns.hand ++ socket.assigns.draw
        socket = assign(socket, :hand, List.insert_at(actual_hand, socket.assigns.played_tile_index, socket.assigns.played_tile))
        :timer.apply_after(750, Kernel, :send, [self(), {:reset_hand_anim, socket.assigns.seat}])
        socket
      else socket end
      socket
    else socket end

    {:ok, socket}
  end
end
