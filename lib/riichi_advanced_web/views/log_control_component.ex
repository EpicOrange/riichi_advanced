defmodule RiichiAdvancedWeb.LogControlComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :log_control_state, nil)
    socket = assign(socket, :state, nil)
    socket = assign(socket, :log, nil)
    socket = assign(socket, :kyoku_index, 0)
    socket = assign(socket, :event_index, -1)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <button class="log-control-button" phx-cancellable-click="prev_kyoku" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m17 16-4-4 4-4m-6 8-4-4 4-4"/>
        </svg>
      </button>
      <button class="log-control-button" phx-cancellable-click="back" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M7 6a1 1 0 0 1 2 0v4l6.4-4.8A1 1 0 0 1 17 6v12a1 1 0 0 1-1.6.8L9 14v4a1 1 0 1 1-2 0V6Z" clip-rule="evenodd"/>
        </svg>
      </button>
      <button class="log-control-button" phx-cancellable-click="play" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M8.6 5.2A1 1 0 0 0 7 6v12a1 1 0 0 0 1.6.8l8-6a1 1 0 0 0 0-1.6l-8-6Z" clip-rule="evenodd"/>
        </svg>
      </button>
      <button class="log-control-button" phx-cancellable-click="next" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path fill-rule="evenodd" d="M17 6a1 1 0 1 0-2 0v4L8.6 5.2A1 1 0 0 0 7 6v12a1 1 0 0 0 1.6.8L15 14v4a1 1 0 1 0 2 0V6Z" clip-rule="evenodd"/>
        </svg>
      </button>
      <button class="log-control-button" phx-cancellable-click="next_kyoku" phx-target={@myself}>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m7 16 4-4-4-4m6 8 4-4-4-4"/>
        </svg>
      </button>
    </div>
    """
  end

  def get_current_kyoku(socket) do
    socket.assigns.log["kyokus"] |> Enum.at(socket.assigns.kyoku_index)
  end

  def get_current_event(socket) do
    if socket.assigns.event_index == -1 do
      nil
    else
      get_current_kyoku(socket)["events"] |> Enum.at(socket.assigns.event_index)
    end
  end

  def advance(socket, skip \\ false) do
    if skip do
      # only proceed if the current event is something we care about
      curr_event = get_current_event(socket)
      if curr_event != nil and curr_event["type"] not in ["discard", "buttons_pressed", "mark"] do
        advance(socket, false)
      else socket end
    else
      socket
      |> assign(:event_index, socket.assigns.event_index + 1)
      |> handle_kyoku_overflow()
      |> advance(true)
    end
  end

  def rewind(socket, skip \\ false) do
    if skip do
      # only proceed if the current event is something we care about
      curr_event = get_current_event(socket)
      if curr_event != nil and curr_event["type"] not in ["discard", "buttons_pressed", "mark"] do
        rewind(socket, false)
      else socket end
    else
      socket
      |> assign(:event_index, socket.assigns.event_index - 1)
      |> handle_kyoku_underflow()
      |> rewind(true)
    end
  end

  def handle_kyoku_underflow(socket) do
    # handle kyoku index underflow
    num_kyokus = length(socket.assigns.log["kyokus"])
    socket = if socket.assigns.kyoku_index < 0 do
      socket = assign(socket, :kyoku_index, num_kyokus - 1)
      num_events = length(get_current_kyoku(socket)["events"])
      socket = assign(socket, :event_index, num_events - 1)
      socket
    else socket end

    # handle event index underflow
    if socket.assigns.event_index < -1 do
      socket = assign(socket, :kyoku_index, if socket.assigns.kyoku_index - 1 < 0 do num_kyokus - 1 else socket.assigns.kyoku_index - 1 end)
      num_events = length(get_current_kyoku(socket)["events"])
      socket = assign(socket, :event_index, num_events - 1)
      socket
    else socket end
  end

  def handle_kyoku_overflow(socket) do
    # handle kyoku index overflow
    num_kyokus = length(socket.assigns.log["kyokus"])
    socket = if socket.assigns.kyoku_index >= num_kyokus do
      socket
      |> assign(:kyoku_index, 0)
      |> assign(:event_index, -1)
    else socket end

    # handle event index overflow
    num_events = length(get_current_kyoku(socket)["events"])
    if socket.assigns.event_index >= num_events do
      socket
      |> assign(:kyoku_index, if socket.assigns.kyoku_index + 1 >= num_kyokus do 0 else socket.assigns.kyoku_index + 1 end)
      |> assign(:event_index, -1)
    else socket end
  end

  def seek_to_match(socket) do
    curr_event = get_current_event(socket) # debug only
    IO.inspect({socket.assigns.kyoku_index, socket.assigns.event_index, curr_event})
    GenServer.cast(socket.assigns.log_control_state, {:seek, socket.assigns.kyoku_index, socket.assigns.event_index})
    state = GenServer.call(socket.assigns.log_control_state, :get_game_state)
    assign(socket, :state, state)
  end

  def handle_event("back", _assigns, socket) do
    if socket.assigns.state.game_active do
      socket = socket
      |> rewind()
      |> seek_to_match()
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next", _assigns, socket) do
    if socket.assigns.state.game_active do
      socket = advance(socket)
      curr_event = get_current_event(socket)
      IO.inspect({socket.assigns.kyoku_index, socket.assigns.event_index, curr_event})
      state = if curr_event == nil do
        GenServer.cast(socket.assigns.log_control_state, {:seek, socket.assigns.kyoku_index, socket.assigns.event_index})
        GenServer.call(socket.assigns.log_control_state, :get_game_state)
      else
        case curr_event["type"] do
          "discard"         -> GenServer.call(socket.assigns.log_control_state, {:send_discard, false, curr_event})
          "buttons_pressed" -> GenServer.call(socket.assigns.log_control_state, {:send_button_press, false, curr_event})
          "mark"            -> GenServer.call(socket.assigns.log_control_state, {:send_mark, false, curr_event})
          _                 -> socket.assigns.state
        end
      end
      socket = assign(socket, :state, state)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("next_kyoku", _assigns, socket) do
    socket = socket
    |> assign(:kyoku_index, socket.assigns.kyoku_index + 1)
    |> assign(:event_index, -1)
    |> handle_kyoku_overflow()
    |> seek_to_match()
    {:noreply, socket}
  end

  def handle_event("prev_kyoku", _assigns, socket) do
    socket = socket
    |> assign(:kyoku_index, socket.assigns.kyoku_index - 1)
    |> assign(:event_index, -1)
    |> handle_kyoku_underflow()
    |> assign(:event_index, -1)
    |> seek_to_match()
    {:noreply, socket}
  end

  def handle_event("play", _assigns, socket) do
    {:noreply, socket}
  end

  # def update(assigns, socket) do
  #   prev_log = socket.assigns.log

  #   socket = assigns
  #   |> Map.drop([:flash])
  #   |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

  #   socket = if prev_log == nil and assigns.log != nil do
  #     advance(socket, true)
  #   else socket end

  #   {:ok, socket}
  # end
end
