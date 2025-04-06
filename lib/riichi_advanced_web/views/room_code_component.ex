defmodule RiichiAdvancedWeb.RoomCodeComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :room_code, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="room-code-modal">
      <div class="room-code-display">
        <%= t(@lang, "Enter room code:") %>
        <div class={["tile", Enum.at(@room_code, 0) || "1x"]}></div>
        <div class={["tile", Enum.at(@room_code, 1) || "1x"]}></div>
        <div class={["tile", Enum.at(@room_code, 2) || "1x"]}></div>
      </div>
      <br>
      <div class="room-code-buttons">
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="1m"><div class="tile flat 1m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="2m"><div class="tile flat 2m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="3m"><div class="tile flat 3m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="4m"><div class="tile flat 4m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="5m"><div class="tile flat 5m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="6m"><div class="tile flat 6m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="7m"><div class="tile flat 7m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="8m"><div class="tile flat 8m"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="9m"><div class="tile flat 9m"></div></button>
        <br/>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="1p"><div class="tile flat 1p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="2p"><div class="tile flat 2p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="3p"><div class="tile flat 3p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="4p"><div class="tile flat 4p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="5p"><div class="tile flat 5p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="6p"><div class="tile flat 6p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="7p"><div class="tile flat 7p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="8p"><div class="tile flat 8p"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="9p"><div class="tile flat 9p"></div></button>
        <br/>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="1s"><div class="tile flat 1s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="2s"><div class="tile flat 2s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="3s"><div class="tile flat 3s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="4s"><div class="tile flat 4s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="5s"><div class="tile flat 5s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="6s"><div class="tile flat 6s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="7s"><div class="tile flat 7s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="8s"><div class="tile flat 8s"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="9s"><div class="tile flat 9s"></div></button>
        <br/>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="1z"><div class="tile flat 1z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="2z"><div class="tile flat 2z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="3z"><div class="tile flat 3z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="4z"><div class="tile flat 4z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="5z"><div class="tile flat 5z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="6z"><div class="tile flat 6z"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself} phx-value-tile="7z"><div class="tile flat 7z"></div></button>
        <button type="button"><div class="tile flat 2x"></div></button>
        <button type="button" phx-cancellable-click="enter_room_code" phx-target={@myself}><div class="tile flat 1t"></div></button>
      </div>
    </div>
    """
  end

  def handle_event("enter_room_code", %{"tile" => tile}, socket) do
    socket = assign(socket, :room_code, Enum.take(socket.assigns.room_code ++ [tile], 3))
    socket.assigns.set_room_code.(socket.assigns.room_code)
    {:noreply, socket}
  end

  def handle_event("enter_room_code", _assigns, socket) do
    socket = assign(socket, :room_code, Enum.drop(socket.assigns.room_code, -1))
    socket.assigns.set_room_code.(socket.assigns.room_code)
    {:noreply, socket}
  end
end
