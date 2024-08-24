defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :pond, [])
    socket = assign(socket, :length, 0)
    socket = assign(socket, :riichi_index, nil)
    socket = assign(socket, :picking_discards, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id, @picking_discards && "picking-discards"]}>
      <%= if @picking_discards do %>
        <div :for={{tile, i} <- Enum.with_index(@pond)} class={["tile", tile, "clickable", i + 1 >= @length && "just-played", i == @riichi_index && "sideways"]} phx-click="pick_discard" phx-target={@myself} phx-value-index={i}></div>
      <% else %>
        <div :for={{tile, i} <- Enum.with_index(@pond)} class={["tile", tile, i + 1 >= @length && "just-played", i == @riichi_index && "sideways"]}></div>
      <% end %>
    </div>
    """
  end

  def handle_event("pick_discard", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    context = %{seat: socket.assigns.saki.picking_discards, discard_pile: socket.assigns.seat, discard_index: ix}
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, context})
    {:noreply, socket}
  end

  def update(assigns, socket) do
    # check if we just declared riichi
    socket = if socket.assigns.riichi_index == nil && Map.has_key?(assigns, :riichi) && assigns.riichi do
      assign(socket, :riichi_index, length(socket.assigns.pond))
    else socket end

    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :length, max(length(socket.assigns.pond), socket.assigns.length))
    socket = assign(socket, :picking_discards, socket.assigns.saki != nil && Map.has_key?(socket.assigns.saki, :all_drafted) && socket.assigns.saki.picking_discards == socket.assigns.viewer)

    {:ok, socket}
  end
end
