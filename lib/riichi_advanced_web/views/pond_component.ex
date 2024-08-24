defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :pond, [])
    socket = assign(socket, :just_discarded, false)
    socket = assign(socket, :riichi_index, nil)
    socket = assign(socket, :marking, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= if @marking do %>
        <%= for {tile, i} <- prepare_pond(@pond, @saki) do %>
          <%= if GenServer.call(@game_state, {:can_mark, @seat, i, :discard}) do %>
            <div class={["tile", tile, "markable", @just_discarded && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]} phx-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
          <% else %>
            <%= if GenServer.call(@game_state, {:is_marked, @seat, i, :discard}) do %>
              <div class={["tile", tile, "marked", @just_discarded && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
            <% else %>
              <div class={["tile", tile, @just_discarded && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
            <% end %>
          <% end %>
        <% end %>
      <% else %>
        <div :for={{tile, i} <- Enum.with_index(@pond)} class={["tile", tile, @just_discarded && i == length(@pond) - 1 && "just-played", i == @riichi_index && "sideways"]}></div>
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
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.seat, ix, :discard})
    {:noreply, socket}
  end

  def update(assigns, socket) do
    # check if we just declared riichi
    socket = if socket.assigns.riichi_index == nil && Map.has_key?(assigns, :riichi) && assigns.riichi do
      assign(socket, :riichi_index, length(socket.assigns.pond))
    else socket end

    # animate incoming discards
    socket = if Map.has_key?(assigns, :pond) && length(assigns.pond) > length(socket.assigns.pond) do
      socket = assign(socket, :just_discarded, true)
      :timer.apply_after(750, Kernel, :send, [self(), {:reset_discard_anim, socket.assigns.seat}])
      socket
    else socket end

    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :marking, socket.assigns.saki != nil && GenServer.call(socket.assigns.game_state, :needs_marking))

    {:ok, socket}
  end
end
