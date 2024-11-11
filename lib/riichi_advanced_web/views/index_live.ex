defmodule RiichiAdvancedWeb.IndexLive do
  use RiichiAdvancedWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :messages, [])
    messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
      GenServer.cast(messages_init.messages_state, {:add_message, %{text: "Welcome to Riichi Advanced!"}})
      socket
    else socket end
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <form phx-submit="redirect">
        Ruleset:
        <select name="ruleset" id="ruleset">
          <option value="riichi" selected>Riichi</option>
          <option value="hk">Hong Kong</option>
          <option value="sichuan">Sichuan Bloody</option>
          <option value="saki">Sakicards v1.3</option>
          <option value="vietnamese">Vietnamese</option>
          <option value="bloody30faan">Bloody 30-Faan Jokers</option>
          <option value="cosmic">Cosmic Riichi (beta)</option>
          <option value="custom">Custom</option>
        </select>
        <br/>
        Name:
        <input type="text" name="nickname" placeholder="Nickname (optional)" />
        <br/>
        <button type="submit" class="enter-button">Enter</button>
      </form>
      <div class="index-bottom-buttons">
        <button><a href="https://github.com/EpicOrange/riichi_advanced">Source</a></button>
        <button><a href="https://discord.gg/5QQHmZQavP">Discord</a></button>
        <button phx-click="goto_logs">Logs</button>
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("redirect", %{"ruleset" => ruleset, "nickname" => nickname}, socket) do
    # check if there are any public rooms of this ruleset
    # if not, skip the lobby and go directly to making a new table
    session_ids = DynamicSupervisor.which_children(RiichiAdvanced.RoomSessionSupervisor)
    |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
    |> Enum.filter(fn name -> String.starts_with?(name, "room-#{ruleset}-") end)
    |> Enum.map(fn name -> String.replace_prefix(name, "room-#{ruleset}-", "") end)
    has_public_room = Enum.any?(session_ids, fn session_id -> 
      [{room_state_pid, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room_state", ruleset, session_id))
      room_state = GenServer.call(room_state_pid, :get_state)
      not room_state.private
    end)
    socket = if has_public_room do
      push_navigate(socket, to: ~p"/lobby/#{ruleset}?nickname=#{nickname}")
    else
      {:ok, _, session_id} = RiichiAdvanced.LobbyState.create_room(%Lobby{ruleset: ruleset})
      push_navigate(socket, to: ~p"/room/#{ruleset}/#{session_id}?nickname=#{nickname}")
    end
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
end
