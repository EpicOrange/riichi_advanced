defmodule RiichiAdvancedWeb.HandPianoComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:num_hand_keys, 0)
    |> assign(:num_draw_keys, 0)
    |> assign(:selected_index, nil)
    |> assign(:hover_index, nil)
    |> assign(:marking, %{})
    |> assign(:your_turn?, [])
    |> assign(:playable_indices, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="hand-piano-container">
      <%= if not Enum.empty?(@marking) do %>
        <%= for {i, can_mark, is_marked} <- prepare_keys(assigns) do %>
          <%= cond do %>
            <% is_marked -> %>
              <div class={["hand-piano-key", "marked", "selected", i >= @num_hand_keys && "draw"]} phx-cancellable-click="unmark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
            <% can_mark -> %>
              <div class={["hand-piano-key", "markable", i >= @num_hand_keys && "draw"]} phx-cancellable-click="mark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
            <% true -> %>
              <div class={["hand-piano-key", "inactive", i >= @num_hand_keys && "draw"]} phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
          <% end %>
        <% end %>
      <% else %>
        <%= for i <- 0..(@num_hand_keys+@num_draw_keys-1) do %>
          <%= if not @your_turn? or i in @playable_indices do %>
            <div class={["hand-piano-key", @selected_index == i && "selected", i >= @num_hand_keys && "draw"]} phx-cancellable-click="play_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <div class={["hand-piano-key", "inactive", i >= @num_hand_keys && "draw"]} phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  def handle_event("play_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.play_tile.(ix)
    socket = assign(socket, :selected_index, ix)
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

  def prepare_keys(assigns) do
    # just return 0..@num_keys
    # we need to pass in assigns so that marking changes will update keys
    0..(assigns.num_hand_keys + assigns.num_draw_keys - 1)
    |> Enum.map(&{&1, 
      GenServer.call(assigns.game_state, {:can_mark?, assigns.viewer, assigns.seat, &1, :hand}),
      GenServer.call(assigns.game_state, {:is_marked?, assigns.viewer, assigns.seat, &1, :hand})
    })
  end
end
