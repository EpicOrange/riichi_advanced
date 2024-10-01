defmodule RiichiAdvancedWeb.LobbyLive do
  use RiichiAdvancedWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:session_id, params["id"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, params["nickname"])
    |> assign(:id, socket.id)
    |> assign(:players, %{east: nil, south: nil, west: nil, north: nil})
    |> assign(:state, %Lobby{})
    if socket.root_pid != nil do
      # start a new lobby process, if it doesn't exist already
      lobby_spec = {RiichiAdvanced.LobbySupervisor, session_id: socket.assigns.session_id, ruleset: socket.assigns.ruleset, name: {:via, Registry, {:game_registry, Utils.to_registry_name("lobby", socket.assigns.ruleset, socket.assigns.session_id)}}}
      lobby_state = case DynamicSupervisor.start_child(RiichiAdvanced.LobbySessionSupervisor, lobby_spec) do
        {:ok, _pid} ->
          IO.puts("Starting lobby session #{socket.assigns.session_id}")
          [{lobby_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", socket.assigns.ruleset, socket.assigns.session_id))
          lobby_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting lobby session #{socket.assigns.session_id}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started lobby session #{socket.assigns.session_id}")
          [{lobby_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", socket.assigns.ruleset, socket.assigns.session_id))
          lobby_state
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> "-lobby:" <> socket.assigns.session_id)
      # init a new player and get the current state
      [state] = GenServer.call(lobby_state, {:new_player, socket})
      socket = socket
      |> assign(:lobby_state, lobby_state)
      |> assign(:state, state)
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="lobby">
      <header>
        <h1>Lobby</h1>
        <div class="variant">Variant:&nbsp;<b><%= @ruleset %></b></div>
        <div class="session">Room:&nbsp;<b><%= @session_id %></b></div>
      </header>
      <div class="seats">
        <%= for seat <- [:east, :south, :west, :north] do %>
          <div class={["player-slot", @state.seats[seat] != nil && "filled"]}>
            <button phx-click="sit" phx-value-seat={seat}>
              <%= if @state.seats[seat] != nil do %>
                <%= @state.seats[seat].nickname %>
              <% else %>
                Sit
              <% end %>
            </button>
            <div class="player-slot-label"><%= seat %></div>
          </div>
        <% end %>
      </div>
      <div class="seats-buttons">
        <input id="shuffle-seats" type="checkbox" class="shuffle-seats" phx-click="shuffle_seats_toggled" phx-value-enabled={if @state.shuffle do "true" else "false" end} checked={@state.shuffle}>
        <label for="shuffle-seats">Shuffle seats on start?</label>
        <%= if Enum.any?(@state.seats, fn {_seat, player} -> player != nil && player.id == @id end) do %>
          <button class="get-up-button" phx-click="get_up">Get up</button>
        <% end %>
        <%= if not Enum.all?(@state.seats, fn {_seat, player} -> player == nil end) do %>
          <button class="start-game-button" phx-click="start_game">
            Start game
            <%= if nil in Map.values(@state.seats) do %>
            (with AI)
            <% end %>
          </button>
        <% end %>
      </div>
      <div class="mods">
        <%= for {mod, _} <- @state.mods do %>
          <input id={mod} type="checkbox" phx-click="toggle_mod" phx-value-mod={mod} phx-value-enabled={if @state.mods[mod].enabled do "true" else "false" end} checked={@state.mods[mod].enabled}>
          <label for={mod}><%= mod %></label>
        <% end %>
      </div>
      <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={nil} error={@state.error}/>
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
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
    if topic == (socket.assigns.ruleset <> "-lobby:" <> socket.assigns.session_id) do
      socket = assign(socket, :state, state)
      socket = if state.started do
        seat = cond do
          get_in(state.seats.east.id)  == socket.id -> :east
          get_in(state.seats.south.id) == socket.id -> :south
          get_in(state.seats.west.id)  == socket.id -> :west
          get_in(state.seats.north.id) == socket.id -> :north
          true                              -> :spectator
        end
        push_navigate(socket, to: ~p"/game/#{socket.assigns.ruleset}/#{socket.assigns.session_id}?nickname=#{socket.assigns.nickname}&seat=#{seat}")
      else socket end
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
