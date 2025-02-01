defmodule RiichiAdvancedWeb.PondComponent do
  alias RiichiAdvanced.Utils, as: Utils
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
    socket = assign(socket, :four_rows?, false)
    socket = assign(socket, :secondary_pond?, false)
    socket = assign(socket, :marking, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@four_rows? && "four-rows"]}>
      <div class={[@id, @highlight? && not @secondary_pond? && "highlight"]}>
        <%= if not Enum.empty?(@marking) do %>
          <%= for {tile, i} <- prepare_pond(@pond, @marking) |> Enum.take(24) do %>
            <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :discard}) do %>
              <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
            <% else %>
              <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :discard}) do %>
                <div class={Utils.get_tile_class(tile, i, assigns, ["marked"])}></div>
              <% else %>
                <div class={Utils.get_tile_class(tile, i, assigns)}></div>
              <% end %>
            <% end %>
          <% end %>
        <% else %>
          <div :for={{tile, i} <- Enum.take(Enum.with_index(@pond), 24)} class={Utils.get_tile_class(tile, i, assigns)}></div>
        <% end %>
      </div>
      <div class={[@id, "secondary-pond", @highlight? && "highlight"]} :if={@secondary_pond?}>
        <%= if not Enum.empty?(@marking) do %>
          <%= for {tile, i} <- prepare_pond(@pond, @marking) |> Enum.drop(24) do %>
            <%= if GenServer.call(@game_state, {:can_mark?, @viewer, @seat, i, :discard}) do %>
              <div class={Utils.get_tile_class(tile, i, assigns, ["markable"])} phx-cancellable-click="mark_tile" phx-target={@myself} phx-value-index={i}></div>
            <% else %>
              <%= if GenServer.call(@game_state, {:is_marked?, @viewer, @seat, i, :discard}) do %>
                <div class={Utils.get_tile_class(tile, i, assigns, ["marked"])}></div>
              <% else %>
                <div class={Utils.get_tile_class(tile, i, assigns)}></div>
              <% end %>
            <% end %>
          <% end %>
        <% else %>
          <div :for={{tile, i} <- Enum.drop(Enum.with_index(@pond), 24)} class={Utils.get_tile_class(tile, i, assigns)}></div>
        <% end %>
      </div>
    </div>
    """
  end

  def prepare_pond(pond, _marking) do
    # need to pass in the marking arg, so the pond updates when marking updates
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

    # toggle secondary pond
    socket = assign(socket, :secondary_pond?, socket.assigns.four_rows? && (socket.assigns.secondary_pond? || length(Map.get(assigns, :pond, [])) > 24))

    # toggle highlight
    socket = assign(socket, :highlight?, socket.assigns.viewer != socket.assigns.seat && socket.assigns.seat_turn? && socket.assigns.viewer_buttons? && socket.assigns.just_discarded?)

    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    {:ok, socket}
  end
end
