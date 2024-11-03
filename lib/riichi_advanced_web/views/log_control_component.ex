defmodule RiichiAdvancedWeb.LogControlComponent do
  alias RiichiAdvanced.GameState, as: GameState
  alias RiichiAdvanced.GameState.Log, as: Log
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :game_state, nil)
    socket = assign(socket, :state, nil)
    socket = assign(socket, :log, nil)
    socket = assign(socket, :kyoku_index, 0)
    socket = assign(socket, :event_index, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <button class="back-button" phx-cancellable-click="back" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M7 6a1 1 0 0 1 2 0v4l6.4-4.8A1 1 0 0 1 17 6v12a1 1 0 0 1-1.6.8L9 14v4a1 1 0 1 1-2 0V6Z" clip-rule="evenodd"/>
        </svg>
      </button>
      <button class="play-button" phx-cancellable-click="play" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M8.6 5.2A1 1 0 0 0 7 6v12a1 1 0 0 0 1.6.8l8-6a1 1 0 0 0 0-1.6l-8-6Z" clip-rule="evenodd"/>
        </svg>
      </button>
      <button class="next-button" phx-cancellable-click="next" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M17 6a1 1 0 1 0-2 0v4L8.6 5.2A1 1 0 0 0 7 6v12a1 1 0 0 0 1.6.8L15 14v4a1 1 0 1 0 2 0V6Z" clip-rule="evenodd"/>
        </svg>
      </button>
    </div>
    """
  end

  def get_current_kyoku(socket) do
    socket.assigns.log["kyokus"] |> Enum.at(socket.assigns.kyoku_index)
  end

  def get_current_event(socket) do
    get_current_kyoku(socket)["events"] |> Enum.at(socket.assigns.event_index)
  end

  def advance(socket, skip \\ false) do
    curr_kyoku = get_current_kyoku(socket)
    if skip do
      # only proceed if the current event is something we care about
      curr_event = get_current_event(socket)
      if curr_event["type"] not in ["discard", "button_pressed"] do
        advance(socket, false)
      else socket end
    else
      if socket.assigns.event_index + 1 >= length(curr_kyoku["events"]) do
        if socket.assigns.kyoku_index + 1 >= length(socket.assigns.log["kyokus"]) do
          socket
        else
          socket = socket
          |> assign(:kyoku_index, socket.assigns.kyoku_index + 1)
          |> assign(:event_index, 0)
          advance(socket, true)
        end
      else
        socket = socket
        |> assign(:event_index, socket.assigns.event_index + 1)
        advance(socket, true)
      end
    end
  end

  def wait_for_state_change(socket) do
    assign(socket, :state, GenServer.call(socket.assigns.game_state, :get_state))
  end

  def handle_event("back", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("next", _assigns, socket) do
    curr_kyoku = get_current_kyoku(socket)
    curr_event = get_current_event(socket)
    IO.inspect(curr_event)
    seat = Log.from_seat(curr_event["player"])
    case curr_event["type"] do
      "discard" ->
        hand = socket.assigns.state.players[seat].hand
        draw = socket.assigns.state.players[seat].draw
        tile = curr_event["tile"] |> Utils.to_tile()
        # figure out what index was discarded
        ix = if not curr_event["tsumogiri"] do
          Enum.find_index(hand, &Utils.same_tile(&1, tile))
        else
          length(hand) + Enum.find_index(draw, &Utils.same_tile(&1, tile))
        end
        GenServer.cast(socket.assigns.game_state, {:play_tile, seat, ix})
        socket = wait_for_state_change(socket)
        IO.inspect(socket.assigns.state.players.south.buttons)
        # for all possible calls attached to this event
        # have players press skip on them if they weren't actually called
        call = if Map.has_key?(curr_event, "call") do [curr_event["call"]] else [] end
        possible_calls = Map.get(curr_event, "possible_calls", []) -- call
        call_seats = Enum.map(call, &Log.from_seat(&1["player"]))
        possible_call_seats = Enum.map(possible_calls, &Log.from_seat(&1["player"]))
        for seat <- possible_call_seats -- call_seats do
          GenServer.cast(socket.assigns.game_state, {:press_button, seat, "skip"})
        end
      "button_pressed" ->
        name = curr_event["name"]
        GenServer.cast(socket.assigns.game_state, {:press_button, seat, name})
      _ -> :ok
    end
    socket = advance(socket)
    {:noreply, socket}
  end

  def handle_event("play", _assigns, socket) do
    {:noreply, socket}
  end

  def update(assigns, socket) do
    prev_log = socket.assigns.log

    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = if prev_log == nil && assigns.log != nil do
      advance(socket, true)
    else socket end

    {:ok, socket}
  end
end
