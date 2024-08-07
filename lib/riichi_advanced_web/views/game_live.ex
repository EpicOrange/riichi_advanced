defmodule RiichiAdvancedWeb.GameLive do
  use RiichiAdvancedWeb, :live_view

  # This function initializes the state
  def mount(_params, _session, socket) do
    # liveviews mount twice
    if socket.root_pid != nil do
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "game:main")

      # TODO notify all other players that we have joined the game
      IO.inspect(socket)
      {seat, turn} = RiichiAdvanced.GlobalState.new_player(socket)

      socket = assign(socket, :player_id, socket.id)
      socket = assign(socket, :turn, turn)
      socket = assign(socket, :seat, seat)
      socket = assign(socket, :shimocha, nil)
      socket = assign(socket, :toimen, nil)
      socket = assign(socket, :kamicha, nil)
      {:ok, socket}
    else
      socket = assign(socket, :seat, :east)
      socket = assign(socket, :turn, :east)
      socket = assign(socket, :shimocha, nil)
      socket = assign(socket, :toimen, nil)
      socket = assign(socket, :kamicha, nil)
      {:ok, socket}
    end
  end

  # Render the template using the assigned state
  def render(assigns) do
    ~H"""
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand self"
      your_turn={@seat == @turn}
      seat={@seat}
      play_tile={&send(self(), {:play_tile, &1})}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond self" />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand shimocha"
      your_turn={@shimocha == @turn}
      seat={@shimocha}
      :if={@shimocha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond shimocha" :if={@shimocha != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand toimen"
      your_turn={@toimen == @turn}
      seat={@toimen}
      :if={@toimen != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond toimen" :if={@toimen != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand kamicha"
      your_turn={@kamicha == @turn}
      seat={@kamicha}
      :if={@kamicha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond kamicha" :if={@kamicha != nil} />
    <div class="seating">You are <%= @seat %></div>
    <div class="compass"></div>
    """
  end

  def handle_info({:play_tile, tile}, socket) do
    RiichiAdvanced.GlobalState.play_tile(socket.assigns.seat, tile)
    {:noreply, socket}
  end

  def handle_info(%{topic: "game:main", event: "played_tile", payload: %{"seat" => seat, "tile" => tile}}, socket) do
    relative_seat = RiichiAdvanced.GlobalState.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", played_tile: tile)
    send_update(RiichiAdvancedWeb.PondComponent, id: "pond #{relative_seat}", played_tile: tile)
    {:noreply, socket}
  end

  def handle_info(%{topic: "game:main", event: "state_updated", payload: %{"state" => state}}, socket) do
    IO.puts("Global state updated event:")
    IO.inspect(state)
    socket = assign(socket, :turn, state.turn)
    shimocha = RiichiAdvanced.GlobalState.get_seat(socket.assigns.seat, :shimocha)
    toimen = RiichiAdvanced.GlobalState.get_seat(socket.assigns.seat, :toimen)
    kamicha = RiichiAdvanced.GlobalState.get_seat(socket.assigns.seat, :kamicha)
    socket = assign(socket, :shimocha, if state[shimocha] != nil do shimocha else nil end)
    socket = assign(socket, :toimen, if state[toimen] != nil do shimocha else nil end)
    socket = assign(socket, :kamicha, if state[kamicha] != nil do shimocha else nil end)
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

  def terminate({:shutdown, :closed}, socket) do
    # navigated away, or refreshed, or tab closed
    RiichiAdvanced.GlobalState.delete_player(socket)
  end
  def terminate(reason, socket) do
    RiichiAdvanced.GlobalState.delete_player(socket)
    IO.puts("unhandled reason:")
    IO.inspect(reason)
  end
end
