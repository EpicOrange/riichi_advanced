defmodule RiichiAdvancedWeb.AboutLive do
  use RiichiAdvancedWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :messages, [])
    socket = assign(socket, :beta_testers, [
      "Hyperistic",
      "Nehalem",
      "モカ妹紅（MochaMoko）",
      "Sophie",
      "Anton00",
      "Glassy",
      "KlorofinMaster",
      "5𝔷ł𝔬𝔱𝔶𝔠𝔥-𝔨𝔲𝔫",
      "lorena.davletiar",
      "nilay",
      "tomato",
      "averyoriginalname",
      "schi",
      "stuf",
      "Miisuya",
      "#yuriaddict",
      "DragonRider JC",
      "Caballo",
      "GameRaccoon",
      "UltimateNeutrino",
      "GOAT^3"
    ])
    messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
      GenServer.cast(messages_init.messages_state, :poll_messages)
      socket
    else socket end
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container" phx-hook="ClickListener">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <form>
        Created by Dani in their spare time.
        This project is still in beta, so any playtesting is appreciated!
        For any information, drop a message in our Discord (link below).
        <br/>
        Special thanks to our beta testers:
        <ul class="beta-testers">
          <li :for={user <- Enum.shuffle(@beta_testers)}><%= user %></li>
        </ul>
      </form>
      <div class="index-bottom-buttons">
        <button phx-click="goto_index">Back</button>
        <button><a href="https://github.com/EpicOrange/riichi_advanced">Source</a></button>
        <button><a href="https://discord.gg/5QQHmZQavP">Discord</a></button>
        <button phx-click="goto_logs">Logs</button>
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("goto_index", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/")
    {:noreply, socket}
  end
  
  def handle_event("goto_logs", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/log")
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:set_room_code, room_code}, socket) do
    socket = assign(socket, :room_code, room_code)
    {:noreply, socket}
  end

end
