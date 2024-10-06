defmodule RiichiAdvancedWeb.MenuButtonsComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :log_button, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="menu-buttons-container">
      <button class="back" phx-cancellable-click="back">Back</button>
      <%= if @log_button do %>
        <button class="log" phx-cancellable-click="log">Copy log</button>
      <% end %>
    </div>
    """
  end

end
