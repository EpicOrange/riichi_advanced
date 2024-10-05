defmodule RiichiAdvancedWeb.LobbyLive do
  use RiichiAdvancedWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:id, socket.id)
    |> assign(:lobby_state, nil)
    |> assign(:messages, [])
    |> assign(:state, %Lobby{})
    if socket.root_pid != nil do
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
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "lobby:" <> socket.assigns.ruleset)
      # init a new player and get the current state
      [state] = GenServer.call(lobby_state, {:new_player, socket})
      socket = socket
      |> assign(:lobby_state, lobby_state)
      |> assign(:state, state)

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
        <div class="variant">Variant:&nbsp;<b><%= @ruleset %></b></div>
      </header>
      <div class="rooms">
        <%= for {room_name, _room} <- @state.rooms do %>
          <div class="room">
            <button class="join-room">
              <%= for tile <- String.split(room_name, " ") do %>
                <div class={["tile", tile]}></div>
              <% end %>
            </button>
            <div class="room-mods">
              <%= for mod <- ["aka", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora", "dora", "aka", "dora"] do %>
                <div class="room-mod"><%= mod %></div>
              <% end %>
            </div>
            <div class="room-players">0/4</div>
          </div>
        <% end %>
      </div>
      <button class="create-room">Create a room</button>
      <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@lobby_state} error={@state.error}/>
      <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu_buttons" />
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("sit", %{"seat" => seat}, socket) do
    GenServer.cast(socket.assigns.lobby_state, {:sit, socket.id, seat})
    {:noreply, socket}
  end

  def handle_event("get_up", _assigns, socket) do
    GenServer.cast(socket.assigns.lobby_state, {:get_up, socket.id})
    {:noreply, socket}
  end

  def handle_event("shuffle_seats_toggled", %{"enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.lobby_state, {:toggle_shuffle_seats, not enabled})
    {:noreply, socket}
  end

  def handle_event("toggle_mod", %{"mod" => mod, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.lobby_state, {:toggle_mod, mod, not enabled})
    {:noreply, socket}
  end

  def handle_event("start_game", _assigns, socket) do
    GenServer.cast(socket.assigns.lobby_state, :start_game)
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == ("lobby:" <> socket.assigns.ruleset) do
      socket = assign(socket, :state, state)
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
end
