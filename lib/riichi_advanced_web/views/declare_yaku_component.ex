defmodule RiichiAdvancedWeb.DeclareYakuComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :game_state, nil)
    socket = assign(socket, :viewer, nil)
    socket = assign(socket, :minimized, false)
    socket = assign(socket, :yakus, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="declare-yaku-container">
      <input id="minimize" type="checkbox" class="declare-yaku-minimize">
      <label for="minimize" class="declare-yaku-minimize-label" phx-cancellable-click="minimize" phx-target={@myself}><%= if @minimized do "+" else "–" end %></label>
      <div class={[@id, @minimized && "minimized"]}>
        <form phx-submit="submit" phx-target={@myself}>
          <div class="declarable-yakus">
            <%= for yaku <- @yakus do %>
              <input id={"yaku-" <> yaku} name={yaku} type="checkbox" class="yaku-toggle">
              <label for={"yaku-" <> yaku}><%= yaku %></label>
            <% end %>
          </div>
          <button type="submit" class="declare-yaku-button" phx-submit>Declare yaku</button>
        </form>
      </div>
    </div>
    """
  end

  def handle_event("minimize", _assigns, socket) do
    socket = assign(socket, :minimized, not socket.assigns.minimized)
    {:noreply, socket}
  end

  def handle_event("submit", assigns, socket) do
    GenServer.cast(socket.assigns.game_state, {:declare_yaku, socket.assigns.viewer, Map.keys(assigns)})
    {:noreply, socket}
  end

end
