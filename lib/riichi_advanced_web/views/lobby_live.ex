defmodule RiichiAdvancedWeb.LobbyLive do
  alias RiichiAdvanced.LobbyState.Lobby, as: Lobby
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:display_name, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:id, socket.id)
    |> assign(:lobby_state, nil)
    |> assign(:messages, [])
    |> assign(:state, %Lobby{})
    |> assign(:show_room_code_buttons, false)
    |> assign(:room_code, [])
    if socket.root_pid != nil do
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "lobby:" <> socket.assigns.ruleset)

      # start a new lobby process, if it doesn't exist already
      lobby_spec = {RiichiAdvanced.LobbySupervisor, ruleset: socket.assigns.ruleset, name: {:via, Registry, {:game_registry, Utils.to_registry_name("lobby", socket.assigns.ruleset, "")}}}
      lobby_state = case DynamicSupervisor.start_child(RiichiAdvanced.LobbySessionSupervisor, lobby_spec) do
        {:ok, _pid} ->
          IO.puts("Starting lobby for ruleset #{socket.assigns.ruleset}")
          [{lobby_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", socket.assigns.ruleset, ""))
          lobby_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting lobby for ruleset #{socket.assigns.ruleset}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started lobby for ruleset #{socket.assigns.ruleset}")
          [{lobby_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", socket.assigns.ruleset, ""))
          lobby_state
      end

      # init a new player and get the current state
      [state] = GenServer.call(lobby_state, {:new_player, socket})
      socket = socket
      |> assign(:lobby_state, lobby_state)
      |> assign(:state, state)
      |> assign(:display_name, state.display_name)

      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          %{text: "Entered lobby for variant"},
          %{bold: true, text: socket.assigns.ruleset}
        ]})
        socket
      else socket end
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="container" class="lobby" phx-hook="ClickListener">
      <header>
        <h1>Lobby</h1>
        <div class="variant">Variant:&nbsp;<b><%= @display_name %></b></div>
      </header>
      <div class="rooms">
        <div class="lobby-room" :for={{room_name, room} <- @state.rooms} :if={not room.private}>
          <button class="join-room" phx-cancellable-click="join_room" phx-value-name={room_name}>
            <%= for tile <- String.split(room_name, ",") do %>
              <div class={["tile", tile]}></div>
            <% end %>
          </button>
          <div class="room-mods">
            <%= for mod <- room.mods do %>
              <div class="room-mod"><%= mod %></div>
            <% end %>
          </div>
          <div class="room-players">
            <div class="room-player-count"><%= Map.values(room.players) |> Enum.count(& &1 != nil) %>/<%= map_size(room.players) %></div>
            <div class="room-started" :if={room.started}>(ongoing)</div>
          </div>
        </div>
      </div>
      <%= if @show_room_code_buttons do %>
        <.live_component module={RiichiAdvancedWeb.RoomCodeComponent} id="room-code" set_room_code={&send(self(), {:set_room_code, &1})} />
      <% end %>
      <div class="enter-buttons">
        <button class="create-room" phx-cancellable-click="create_room">
          <%= if @show_room_code_buttons do %>
            Enter
          <% else %>
            Create a room
          <% end %>
        </button>
        <button phx-cancellable-click="toggle_show_room_code">
          <%= if @show_room_code_buttons do %>
            Close
          <% else %>
            Join private room
          <% end %>
        </button>
      </div>
      <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@lobby_state} error={@state.error}/>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_show_room_code", _assigns, socket) do
    socket = assign(socket, :show_room_code_buttons, not socket.assigns.show_room_code_buttons)
    {:noreply, socket}
  end

  def handle_event("join_room", %{"name" => room_code}, socket) do
    socket = push_navigate(socket, to: ~p"/room/#{socket.assigns.ruleset}/#{room_code}?nickname=#{socket.assigns.nickname}")
    {:noreply, socket}
  end

  def handle_event("create_room", _assigns, socket) do
    if socket.assigns.show_room_code_buttons do
      socket = if length(socket.assigns.room_code) == 3 do
        # enter private room, or create a new room
        room_code = Enum.join(socket.assigns.room_code, ",")
        push_navigate(socket, to: ~p"/room/#{socket.assigns.ruleset}/#{room_code}?nickname=#{socket.assigns.nickname}")
      else socket end
      {:noreply, socket}
    else
      case GenServer.call(socket.assigns.lobby_state, :create_room) do
        :no_names_remaining -> {:noreply, socket}
        {:ok, room_code}    ->
          socket = push_navigate(socket, to: ~p"/room/#{socket.assigns.ruleset}/#{room_code}?nickname=#{socket.assigns.nickname}")
          {:noreply, socket}
      end
    end
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == ("lobby:" <> socket.assigns.ruleset) do
      socket = assign(socket, :state, state)
      {:noreply, socket}
    else
      if String.starts_with?(topic, state.ruleset <> "-room:") do
        room_code = String.replace_prefix(topic, state.ruleset <> "-room:", "")
        GenServer.cast(socket.assigns.lobby_state, {:update_room_state, room_code, state})
        {:noreply, socket}
      else
        {:noreply, socket}
      end
    end
  end

  def handle_info(%{topic: topic, event: "new_room", payload: %{"name" => room_code}}, socket) do
    if topic == ("lobby:" <> socket.assigns.ruleset) do
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> "-room:" <> room_code)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
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
