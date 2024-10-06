defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :seat, nil)
    socket = assign(socket, :viewer, nil)
    socket = assign(socket, :pond, [])
    socket = assign(socket, :highlight?, false)
    socket = assign(socket, :just_discarded?, false)
    socket = assign(socket, :seat_turn?, false)
    socket = assign(socket, :viewer_buttons?, false)
    socket = assign(socket, :riichi_index, nil)
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id, @highlight? && "highlight"]}>
      <%= if not Enum.empty?(@marking) do %>
        <%= for {tile, i} <- prepare_pond(@pond, @saki) do %>
          <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :discard}) do %>
            <div class={["tile", tile, "markable", @just_discarded? && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :discard}) do %>
              <div class={["tile", tile, "marked", @just_discarded? && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
            <% else %>
              <div class={["tile", tile, @just_discarded? && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
            <% end %>
          <% end %>
        <% end %>
      <% else %>
        <div :for={{tile, i} <- Enum.with_index(@pond)} class={["tile", tile, @just_discarded? && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
      <% end %>
    </div>
    """
  end

  def prepare_pond(pond, _saki) do
    # need to pass in the saki arg, so the pond updates when saki updates
    Enum.with_index(pond)
  end

  def handle_event("mark_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, socket.assigns.seat, ix, :discard})
    {:noreply, socket}
  end

  def update(assigns, socket) do
    # check if we just declared riichi
    socket = if Map.has_key?(assigns, :riichi) do
      if socket.assigns.riichi_index == nil && assigns.riichi do
        assign(socket, :riichi_index, length(socket.assigns.pond))
      else
        if socket.assigns.riichi_index != nil && not assigns.riichi do
          assign(socket, :riichi_index, nil)
        else socket end
      end
    else socket end

    # animate incoming discards
    socket = if Map.has_key?(assigns, :pond) && length(assigns.pond) > length(socket.assigns.pond) do
      socket = assign(socket, :just_discarded?, true)
      :timer.apply_after(750, Kernel, :send, [self(), {:reset_discard_anim, assigns.seat}])
      socket
    else socket end

    # toggle highlight
    socket = assign(socket, :highlight?, socket.assigns.viewer != socket.assigns.seat && socket.assigns.seat_turn? && socket.assigns.viewer_buttons? && socket.assigns.just_discarded?)

    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    {:ok, socket}
  end
end
