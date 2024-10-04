defmodule RiichiAdvancedWeb.MenuButtonsComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="menu-buttons-container">
      <button class="back" phx-cancellable-click="back">Back</button>
    </div>
    """
  end

end
