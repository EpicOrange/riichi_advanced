defmodule RiichiAdvancedWeb.DrawWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :draw, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", @draw == nil && "inactive"]}>
      <%= if @draw != nil do %>
        <div class="draw-reason"><%= @draw.reason %></div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    {:ok, socket}
  end
end
