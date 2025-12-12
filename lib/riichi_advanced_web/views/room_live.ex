defmodule RiichiAdvancedWeb.RoomLive do
  alias RiichiAdvanced.RoomState.Room, as: Room
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view
  import RiichiAdvancedWeb.Translations

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:room_code, params["room_code"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:display_name, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:from, Map.get(params, "from", nil))
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:players, %{east: nil, south: nil, west: nil, north: nil})
    |> assign(:room_state, nil)
    |> assign(:messages, [])
    |> assign(:symbols, %{east: "東", south: "南", west: "西", north: "北"})
    |> assign(:state, %Room{})
    if socket.root_pid != nil do
      # start a new room process, if it doesn't exist already
      room_spec = {RiichiAdvanced.RoomSupervisor, room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, name: Utils.via_registry("room", socket.assigns.ruleset, socket.assigns.room_code)}
      room_state = case DynamicSupervisor.start_child(RiichiAdvanced.RoomSessionSupervisor, room_spec) do
        {:ok, _pid} ->
          IO.puts("Starting room session #{socket.assigns.room_code}")
          [{room_state, _}] = Utils.registry_lookup("room_state", socket.assigns.ruleset, socket.assigns.room_code)
          room_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting room session #{socket.assigns.room_code}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started room session #{socket.assigns.room_code}")
          [{room_state, _}] = Utils.registry_lookup("room_state", socket.assigns.ruleset, socket.assigns.room_code)
          room_state
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code)
      # init a new player and get the current state
      [state] = GenServer.call(room_state, {:new_player, socket.root_pid, socket.assigns.session_id, socket.assigns.nickname})
      socket = socket
      |> assign(:room_state, room_state)
      |> assign(:state, state)
      |> assign(:display_name, state.display_name)

      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.link_player_socket(socket.root_pid, socket.assigns.session_id)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.assigns.session_id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          %{
            text: "Entered room %{room_code} for variant %{ruleset}",
            vars: %{
              room_code: {:text, socket.assigns.room_code, %{bold: true}},
              ruleset: {:text, socket.assigns.ruleset, %{bold: true}}
            }
          }
        ]})
        socket
      else socket end

      # sit in first available seat, if we're not already in one
      if not Enum.any?(state.available_seats, fn seat -> get_in(state.seats[seat].session_id) == socket.assigns.session_id end) do
        case Enum.find(state.available_seats, fn seat -> state.seats[seat] == nil end) do
          nil  -> :ok
          seat -> GenServer.cast(socket.assigns.room_state, {:sit, socket.assigns.session_id, socket.assigns.session_id, seat})
        end
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
        <h3><%= dt(@lang, @display_name) %></h3>
        <div class="session">
          <%= for tile <- String.split(@room_code, ",") do %>
            <div class={["tile", tile]}></div>
          <% end %>
        </div>
        <input id="private-toggle" type="checkbox" phx-click="private_toggled" phx-value-enabled={if @state.private do "true" else "false" end} checked={not @state.private}>
        <label for="private-toggle" class="private-toggle-label">
          <%= if @state.private do %>
            <%= t(@lang, "Private") %>
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
              <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14v3m-3-6V7a3 3 0 1 1 6 0v4m-8 0h10a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1v-7a1 1 0 0 1 1-1Z"/>
            </svg>
          <% else %>
            <%= t(@lang, "Public") %>
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
              <%= t(@lang, "Documentation") %>
            <% else %>
              <%= t(@lang, "Rules") %>
            <% end %>
            <svg xmlns="http://www.w3.org/2000/svg" width="1.2em" height="1.2em" fill="none" viewBox="0 0 24 24">
              <path stroke="white" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 19V4a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v13H7a2 2 0 0 0-2 2Zm0 0a2 2 0 0 0 2 2h12M9 3v14m7 0v4"/>
            </svg>
          </a>
        <% end %>
        <br/>
        <label for="room-settings-toggle" class="room-settings-toggle">
          <%= t(@lang, "Room settings") %>
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
          <div class="mods-title"><%= t(@lang, "Ruleset") %></div>
          <div class="custom-json">
            <.live_component module={RiichiAdvancedWeb.CollaborativeTextareaComponent} id="custom-json-textarea" ruleset={@ruleset} room_code={@room_code} room_state={@room_state} />
          </div>
        <% else %>
          <%= if Enum.empty?(@state.presets) do %>
            <input type="radio" id="presets-tab" name="room-settings-tab" phx-update="ignore">
            <label for="presets-tab" class="room-tab-title"><%= t(@lang, "Rulesets") %></label>
            <input type="radio" id="mods-tab" name="room-settings-tab" checked phx-update="ignore">
            <label for="mods-tab" class="room-tab-title"><%= t(@lang, "Mods") %></label>
          <% else %>
            <input type="radio" id="presets-tab" name="room-settings-tab" checked phx-update="ignore">
            <label for="presets-tab" class="room-tab-title"><%= t(@lang, "Rulesets") %></label>
            <input type="radio" id="mods-tab" name="room-settings-tab" phx-update="ignore">
            <label for="mods-tab" class="room-tab-title"><%= t(@lang, "Mods") %></label>
          <% end %>
          <input type="radio" id="config-tab" name="room-settings-tab" phx-update="ignore">
          <label for="config-tab" class="room-tab-title"><%= t(@lang, "Config") %></label>
          <div class="presets">
            <%= for {preset, i} <- Enum.with_index(@state.presets) do %>
              <%= if i == @state.selected_preset_ix do %>
                <input type="radio" id={"preset-#{i}"} name="presets" checked phx-click="set_preset" phx-value-index={i}>
              <% else %>
                <input type="radio" id={"preset-#{i}"} name="presets" phx-click="set_preset" phx-value-index={i}>
              <% end %>
              <label for={"preset-#{i}"} class="presets-title"><%= dt(@lang, preset["display_name"]) %></label>
            <% end %>
          </div>
          <.live_component module={RiichiAdvancedWeb.ModSelectionComponent} id="room-mods" lang={@lang} ruleset={@ruleset} mods={@state.mods} categories={@state.categories} />
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
            <%= if @state.seats[seat].session_id == @session_id do %>
              <div class="player-slot-name" phx-cancellable-click="get_up"><%= @state.seats[seat].nickname %></div>
              <button class="player-slot-button" phx-cancellable-click="get_up">–</button>
            <% else %>
              <%= if @state.seats[seat].nickname == nil do %>
                <div class="player-slot-name"><%= t(@lang, "&lt;disconnected&gt;") %></div>
              <% else %>
                <div class="player-slot-name"><%= @state.seats[seat].nickname %></div>
              <% end %>
            <% end %>
          <% else %>
            <div class="player-slot-name empty" phx-cancellable-click="sit" phx-value-seat={seat}><%= t(@lang, "Empty") %></div>
          <% end %>
          </div>
        <% end %>
        <input id="shuffle-seats" type="checkbox" phx-click="shuffle_seats_toggled" phx-value-enabled={if @state.shuffle do "true" else "false" end} checked={@state.shuffle}>
        <label for="shuffle-seats" class="shuffle-seats"><%= t(@lang, "Shuffle seats on start?") %></label>
        <%= if not Enum.all?(@state.seats, fn {_seat, player} -> player == nil end) do %>
          <%= if @state.starting do %>
            <button class="start-game-button">
              <%= t(@lang, "Starting game...") %>
            </button>
          <% else %>
            <button class="start-game-button" phx-cancellable-click="start_game">
              <%= t(@lang, "Start game") %>
              <%= if nil in Map.values(@state.seats) do %>
              <%= t(@lang, "(with AI)") %>
              <% end %>
            </button>
          <% end %>
        <% end %>
      </div>
      <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@room_state} error={@state.error}/>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" lang={@lang} />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} lang={@lang} />
      <div class="ruleset">
        <div class="ruleset-text"><%= t(@lang, "Ruleset:") %></div>
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_event(socket, "left-page", %{})
    socket = case socket.assigns.from do
      "lobby" -> push_navigate(socket, to: ~p"/lobby/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
      "learn" -> push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
      _       -> push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
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
    GenServer.cast(socket.assigns.room_state, {:sit, socket.assigns.session_id, socket.assigns.session_id, seat})
    {:noreply, socket}
  end

  def handle_event("get_up", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, {:get_up, socket.assigns.session_id})
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

  def handle_event("set_preset", %{"index" => ix}, socket) do
    ix = String.to_integer(ix)
    GenServer.cast(socket.assigns.room_state, {:set_preset, ix})
    {:noreply, socket}
  end

  def handle_event("toggle_mod", %{"mod" => mod, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.room_state, {:toggle_mod, mod, not enabled})
    {:noreply, socket}
  end

  def handle_event("change_mod_config", assigns, socket) do
    %{"mod" => mod, "name" => name} = assigns
    ix = String.to_integer(assigns[name])
    GenServer.cast(socket.assigns.room_state, {:change_mod_config, mod, name, ix})
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

  def handle_event("randomize_mods", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, :randomize_mods)
    {:noreply, socket}
  end

  def handle_event("start_game", _assigns, socket) do
    GenServer.cast(socket.assigns.room_state, :start_game)
    {:noreply, socket}
  end
  
  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def vacate_room(socket) do
    seat = cond do
      :east  in socket.assigns.state.available_seats and get_in(socket.assigns.state.seats.east.id)  == socket.assigns.session_id -> :east
      :south in socket.assigns.state.available_seats and get_in(socket.assigns.state.seats.south.id) == socket.assigns.session_id -> :south
      :west  in socket.assigns.state.available_seats and get_in(socket.assigns.state.seats.west.id)  == socket.assigns.session_id -> :west
      :north in socket.assigns.state.available_seats and get_in(socket.assigns.state.seats.north.id) == socket.assigns.session_id -> :north
      true                                      -> :spectator
    end
    socket = push_event(socket, "left-page", %{})
    push_navigate(socket, to: ~p"/game/#{socket.assigns.ruleset}/#{socket.assigns.room_code}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}&seat=#{seat}")
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == (socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code) do
      socket = assign(socket, :state, state)
      socket = if state.started do vacate_room(socket) else socket end
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "vacate_room", payload: _}, socket) do
    if topic == (socket.assigns.ruleset <> "-room:" <> socket.assigns.room_code) do
      {:noreply, vacate_room(socket)}
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
    if topic == "messages:" <> socket.assigns.session_id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
