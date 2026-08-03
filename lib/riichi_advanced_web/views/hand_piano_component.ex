defmodule RiichiAdvancedWeb.HandPianoComponent do
  # alias RiichiAdvanced.GameState.Debug, as: Debug
  # alias RiichiAdvanced.Riichi, as: Riichi
  # alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:num_keys, 0)
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
        <%= for i <- prepare_keys(assigns) do %>
          <%= cond do %>
            <% GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :hand}) -> %>
              <div class="hand-piano-key markable" phx-cancellable-click="mark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
            <% GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :hand}) -> %>
              <div class="hand-piano-key marked selected" phx-cancellable-click="unmark_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
            <% true -> %>
              <div class="hand-piano-key inactive" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
          <% end %>
        <% end %>
      <% else %>
        <%= for i <- 0..@num_keys do %>
          <%= if not @your_turn? or i in @playable_indices do %>
            <div class={["hand-piano-key", @selected_index == i && "selected"]} phx-cancellable-click="play_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <div class="hand-piano-key inactive" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i}></div>
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
    0..assigns.num_keys
  end
end
