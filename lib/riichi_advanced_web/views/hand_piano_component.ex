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
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="hand-piano-container">
      <div class={["hand-piano-key", @selected_index == i && "selected"]} phx-cancellable-click="play_tile" phx-hover="hover_tile" phx-hover-off="hover_off" phx-target={@myself} phx-value-index={i} :for={i <- 0..@num_keys}></div>
    </div>
    """
  end

  def handle_event("play_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket.assigns.play_tile.(ix)
    socket = assign(socket, :selected_index, ix)
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
end
