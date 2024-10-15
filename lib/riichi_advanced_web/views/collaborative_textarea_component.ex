defmodule RiichiAdvancedWeb.CollaborativeTextareaComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :room_state, nil)
    {:ok, socket}
  end

  def render(assigns) do
    # all changes should be done via pushing events in javascript
    ~H"""
    <textarea id="collaborative-textarea" phx-target={@myself} phx-hook="CollaborativeTextarea"></textarea>
    """
  end

  def handle_event("push_delta", %{"version" => version, "uuids" => uuids, "deltas" => deltas}, socket) do
    GenServer.call(socket.assigns.room_state, {:update_textarea, version, uuids, deltas})
    {:noreply, socket}
  end

  def handle_event("poll_deltas", %{"version" => version}, socket) do
    GenServer.call(socket.assigns.room_state, {:update_textarea, version, [], []})
    {:noreply, socket}
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    # component shouldn't ever call update, except to update room_state to a non-nil value
    socket = if socket.assigns.room_state != nil do
      # initialize the textarea to the current value
      {version, delta} = GenServer.call(socket.assigns.room_state, :get_textarea)
      socket = push_event(socket, "apply-delta", %{from_version: -1, version: version, uuids: [[]], deltas: [delta]})
      socket
    else socket end

    {:ok, socket}
  end

end
