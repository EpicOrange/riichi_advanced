defmodule RiichiAdvancedWeb.ErrorWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", "error-window", @error == nil && "inactive"]}>
      <%= if @error != nil do %>
        <h1>Error!</h1>
        <textarea class="error" readonly><%= @error %></textarea>
        <button class="dismiss-error" phx-click="dismiss_error" phx-target={@myself}>Dismiss</button>
      <% end %>
    </div>
    """
  end

  def handle_event("dismiss_error", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, :dismiss_error)
    {:noreply, socket}
  end
end
