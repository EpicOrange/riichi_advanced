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
      if curr_event != nil && curr_event["type"] not in ["discard", "buttons_pressed", "mark"] do
        advance(socket, false)
      else socket end
    else
      curr_kyoku = get_current_kyoku(socket)
      if socket.assigns.event_index + 1 >= length(curr_kyoku["events"]) do
        overflow = socket.assigns.kyoku_index + 1 >= length(socket.assigns.log["kyokus"])
        socket
        |> assign(:kyoku_index, if overflow do 0 else socket.assigns.kyoku_index + 1 end)
        |> assign(:event_index, -1)
      else
        socket = socket
        |> assign(:event_index, socket.assigns.event_index + 1)
        advance(socket, true)
      end
    end
  end

  def rewind(socket, skip \\ false) do
    if skip do
      # only proceed if the current event is something we care about
      curr_event = get_current_event(socket)
      if curr_event != nil && curr_event["type"] not in ["discard", "buttons_pressed", "mark"] do
        rewind(socket, false)
      else socket end
    else
      if socket.assigns.event_index - 1 < -1 do
        underflow = socket.assigns.kyoku_index - 1 < 0
        socket = assign(socket, :kyoku_index, if underflow do length(socket.assigns.log["kyokus"]) - 1 else socket.assigns.kyoku_index - 1 end)
        curr_kyoku = get_current_kyoku(socket)
        socket = assign(socket, :event_index, length(curr_kyoku["events"]) - 1)
        rewind(socket, true)
      else
        socket = socket
        |> assign(:event_index, socket.assigns.event_index - 1)
        rewind(socket, true)
      end
    end
  end

  def handle_event("back", _assigns, socket) do
    socket = rewind(socket)
    curr_event = get_current_event(socket) # debug only
    IO.inspect({socket.assigns.kyoku_index, socket.assigns.event_index, curr_event})
    GenServer.cast(socket.assigns.log_control_state, {:seek, socket.assigns.kyoku_index, socket.assigns.event_index})
    state = GenServer.call(socket.assigns.log_control_state, :get_game_state)
    socket = assign(socket, :state, state)
    {:noreply, socket}
  end

  def handle_event("next", _assigns, socket) do
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
  end

  def handle_event("play", _assigns, socket) do
    {:noreply, socket}
  end

  # def update(assigns, socket) do
  #   prev_log = socket.assigns.log

  #   socket = assigns
  #   |> Map.drop([:flash])
  #   |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

  #   socket = if prev_log == nil && assigns.log != nil do
  #     advance(socket, true)
  #   else socket end

  #   {:ok, socket}
  # end
end
