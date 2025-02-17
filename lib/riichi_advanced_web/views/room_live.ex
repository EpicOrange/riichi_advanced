defmodule RiichiAdvancedWeb.RoomLive do
  alias RiichiAdvanced.RoomState.Room, as: Room
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:room_code, params["room_code"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:display_name, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:from, Map.get(params, "from", nil))
    |> assign(:id, socket.id)
    |> assign(:players, %{east: nil, south: nil, west: nil, north: nil})
    |> assign(:room_state, nil)
    |> assign(:messages, [])
    |> assign(:symbols, %{east: "東", south: "南", west: "西", north: "北"})
    |> assign(:state, %Room{})
    if socket.root_pid != nil do
      # start a new room process, if it doesn't exist already
      room_spec = {RiichiAdvanced.RoomSupervisor, room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, name: {:via, Registry, {:game_registry, Utils.to_registry_name("room", socket.assigns.ruleset, socket.assigns.room_code)}}}
      room_state = case DynamicSupervisor.start_child(RiichiAdvanced.RoomSessionSupervisor, room_spec) do
        {:ok, _pid} ->
          IO.puts("Starting room session #{socket.assigns.room_code}")
          [{room_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room_state", socket.assigns.ruleset, socket.assigns.room_code))
          room_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting room session #{socket.assigns.room_code}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started room session #{socket.assigns.room_code}")
          [{room_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room_state", socket.assigns.ruleset, socket.assigns.room_code))
          room_state
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code)
      # init a new player and get the current state
      [state] = GenServer.call(room_state, {:new_player, socket})
      socket = socket
      |> assign(:room_state, room_state)
      |> assign(:state, state)
      |> assign(:display_name, state.display_name)

      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          %{text: "Entered room"},
          %{bold: true, text: socket.assigns.room_code},
          %{text: "for variant"},
          %{bold: true, text: socket.assigns.ruleset}
        ]})
        socket
      else socket end

      case Enum.find(state.available_seats, fn seat -> state.seats[seat] == nil end) do
        nil  -> :ok
        seat -> GenServer.cast(socket.assigns.room_state, {:sit, socket.id, socket.assigns.session_id, seat})
      end

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="container" class="room" phx-hook="ClickListener">
      <header>
        <h3><%= @display_name %></h3>
        <div class="session">
          <%= for tile <- String.split(@room_code, ",") do %>
            <div class={["tile", tile]}></div>
          <% end %>
        </div>
        <input id="private-toggle" type="checkbox" phx-click="private_toggled" phx-value-enabled={if @state.private do "true" else "false" end} checked={not @state.private}>
        <label for="private-toggle" class="private-toggle-label">
          <%= if @state.private do %>
            Private
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
              <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14v3m-3-6V7a3 3 0 1 1 6 0v4m-8 0h10a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1v-7a1 1 0 0 1 1-1Z"/>
            </svg>
          <% else %>
            Public
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
              <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14v3m4-6V7a3 3 0 1 1 6 0v4M5 11h10a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-7a1 1 0 0 1 1-1Z"/>
            </svg>
          <% end %>
        </label>
      </header>
      <div class="sidebar">
        <%= if @state.tutorial_link != nil do %>
          <a class="tutorial-link" href={@state.tutorial_link} target="_blank">
            <%= if @ruleset == "custom" do %>
              Documentation
            <% else %>
              Rules
            <% end %>
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
              <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 19V4a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v13H7a2 2 0 0 0-2 2Zm0 0a2 2 0 0 0 2 2h12M9 3v14m7 0v4"/>
            </svg>
          </a>
        <% end %>
        <br/>
        <label for="room-settings-toggle" class="room-settings-toggle">
          Room settings
          <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
            <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13v-2a1 1 0 0 0-1-1h-.757l-.707-1.707.535-.536a1 1 0 0 0 0-1.414l-1.414-1.414a1 1 0 0 0-1.414 0l-.536.535L14 4.757V4a1 1 0 0 0-1-1h-2a1 1 0 0 0-1 1v.757l-1.707.707-.536-.535a1 1 0 0 0-1.414 0L4.929 6.343a1 1 0 0 0 0 1.414l.536.536L4.757 10H4a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h.757l.707 1.707-.535.536a1 1 0 0 0 0 1.414l1.414 1.414a1 1 0 0 0 1.414 0l.536-.535 1.707.707V20a1 1 0 0 0 1 1h2a1 1 0 0 0 1-1v-.757l1.707-.708.536.536a1 1 0 0 0 1.414 0l1.414-1.414a1 1 0 0 0 0-1.414l-.535-.536.707-1.707H20a1 1 0 0 0 1-1Z"/>
            <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/>
          </svg>
        </label>
      </div>
      <input id="room-settings-toggle" type="checkbox" phx-update="ignore">
      <div class="room-settings">
        <%= if false do %>
          <input type="checkbox" id="expand-checkbox" class="expand-checkbox for-mods" phx-update="ignore"/>
          <label for="expand-checkbox"/>
        <% end %>
        <%= if @ruleset == "custom" do %>
          <div class="mods-title">Ruleset</div>
          <div class="custom-json">
            <.live_component module={RiichiAdvancedWeb.CollaborativeTextareaComponent} id="custom-json-textarea" ruleset={@ruleset} room_code={@room_code} room_state={@room_state} />
          </div>
        <% else %>
          <input type="radio" id="mods-tab" name="room-settings-tab" checked phx-update="ignore">
          <label for="mods-tab" class="mods-title">Mods</label>
          <input type="radio" id="config-tab" name="room-settings-tab" phx-update="ignore">
          <label for="config-tab" class="mods-title">Config</label>
          <div class={["mods", "mods-#{@state.ruleset}"]}>
            <div class="mods-inner-container">
              <%= for {category, mods} <- Enum.group_by(@state.mods, fn {_name, mod} -> mod.category end) |> Enum.sort_by(fn {category, _mods} -> Enum.find_index(@state.categories, & &1 == category) end) do %>
                <div class="mod-category" :if={category}>
                  <%= category %>
                  <button class="mod-menu-button" phx-cancellable-click="toggle_category" phx-value-category={category}>Toggle all</button>
                </div>
                <%= for {mod, mod_details} <- Enum.sort_by(mods, fn {_name, mod} -> mod.index end) do %>
                  <input id={mod} type="checkbox" phx-click="toggle_mod" phx-value-mod={mod} phx-value-enabled={if @state.mods[mod].enabled do "true" else "false" end} checked={@state.mods[mod].enabled}>
                  <label for={mod} title={mod_details.desc} class={["mod", mod_details.class]}><%= mod_details.name %></label>
                <% end %>
                <div class="mod-category-spacer"></div>
              <% end %>
              <div class="reset-to-default-button">
                <button class="mod-menu-button" phx-cancellable-click="reset_mods_to_default">Reset mods to default</button>
              </div>
            </div>
          </div>
          <div class="config">
            <.live_component module={RiichiAdvancedWeb.CollaborativeTextareaComponent} id="config-textarea" ruleset={@ruleset} room_code={@room_code} room_state={@room_state} />
          </div>
        <% end %>
      </div>
      <div class="seats">
        <%= for seat <- @state.available_seats do %>
          <div class={["player-slot", @state.seats[seat] != nil && "filled"]}>
          <div class="player-slot-label"><%= @symbols[seat] %></div>
          <%= if @state.seats[seat] != nil do %>
            <%= if @state.seats[seat].id == @id do %>
              <div class="player-slot-name" phx-cancellable-click="get_up"><%= @state.seats[seat].nickname %></div>
              <button class="player-slot-button" phx-cancellable-click="get_up">–</button>
            <% else %>
              <%= if @state.seats[seat].nickname == nil do %>
                <%= if @state.seats[seat].session_id == @session_id do %>
                  <div class="player-slot-name empty" phx-cancellable-click="sit" phx-value-seat={seat}>(reconnect?)</div>
                <% else %>
                  <div class="player-slot-name">&lt;disconnected&gt;</div>
                <% end %>
              <% else %>
                <div class="player-slot-name"><%= @state.seats[seat].nickname %></div>
              <% end %>
            <% end %>
          <% else %>
            <div class="player-slot-name empty" phx-cancellable-click="sit" phx-value-seat={seat}>Empty</div>
          <% end %>
          </div>
        <% end %>
        <input id="shuffle-seats" type="checkbox" phx-click="shuffle_seats_toggled" phx-value-enabled={if @state.shuffle do "true" else "false" end} checked={@state.shuffle}>
        <label for="shuffle-seats" class="shuffle-seats">Shuffle seats on start?</label>
        <%= if not Enum.all?(@state.seats, fn {_seat, player} -> player == nil end) do %>
          <%= if @state.starting do %>
            <button class="start-game-button">
              Starting game...
            </button>
          <% else %>
            <button class="start-game-button" phx-cancellable-click="start_game">
              Start game
              <%= if nil in Map.values(@state.seats) do %>
              (with AI)
              <% end %>
            </button>
          <% end %>
        <% end %>
      </div>
      <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@room_state} error={@state.error}/>
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
    socket = push_event(socket, "left-page", %{})
    socket = case socket.assigns.from do
      "lobby" -> push_navigate(socket, to: ~p"/lobby/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}")
      "learn" -> push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}")
      _       -> push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}")
    end
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("sit", %{"seat" => seat}, socket) do
    seat = case seat do
      "south" -> :south
      "west"  -> :west
      "north" -> :north
      _       -> :east
    end
    GenServer.cast(socket.assigns.room_state, {:sit, socket.id, socket.assigns.session_id, seat})
    {:noreply, socket}
  end

  def handle_event("get_up", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, {:get_up, socket.id})
    {:noreply, socket}
  end

  def handle_event("private_toggled", %{"enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.room_state, {:toggle_private, not enabled})
    {:noreply, socket}
  end

  def handle_event("shuffle_seats_toggled", %{"enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.room_state, {:toggle_shuffle_seats, not enabled})
    {:noreply, socket}
  end

  def handle_event("toggle_mod", %{"mod" => mod, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.room_state, {:toggle_mod, mod, not enabled})
    {:noreply, socket}
  end

  def handle_event("toggle_category", %{"category" => category}, socket) do
    GenServer.cast(socket.assigns.room_state, {:toggle_category, category})
    {:noreply, socket}
  end

  def handle_event("reset_mods_to_default", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, :reset_mods_to_default)
    {:noreply, socket}
  end

  def handle_event("start_game", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, :start_game)
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == (socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code) do
      socket = assign(socket, :state, state)
      socket = if state.started do
        seat = cond do
          :east  in state.available_seats and get_in(state.seats.east.id)  == socket.id -> :east
          :south in state.available_seats and get_in(state.seats.south.id) == socket.id -> :south
          :west  in state.available_seats and get_in(state.seats.west.id)  == socket.id -> :west
          :north in state.available_seats and get_in(state.seats.north.id) == socket.id -> :north
          true                                      -> :spectator
        end
        socket = push_event(socket, "left-page", %{})
        push_navigate(socket, to: ~p"/game/#{socket.assigns.ruleset}/#{socket.assigns.room_code}?nickname=#{socket.assigns.nickname}&seat=#{seat}")
      else socket end
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "textarea_updated", payload: %{"from_version" => from_version, "version" => version, "uuids" => uuids, "deltas" => deltas}}, socket) do
    if topic == (socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code) do
      socket = push_event(socket, "apply-delta", %{from_version: from_version, version: version, uuids: uuids, deltas: deltas})
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
