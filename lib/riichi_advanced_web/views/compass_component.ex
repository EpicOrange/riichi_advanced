defmodule RiichiAdvancedWeb.CompassComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["compass", @seat]} phx-click="set_turn" phx-target={@myself}>
      <%= for {dir, symbol} <- [{:east, "東"}, {:south, "南"}, {:west, "西"}, {:north, "北"}] do %>
      <div class="score-box"></div>
      <div class={["direction", dir]}>
        <div class={["riichi-tray", @turn == dir && "highlighted", @riichi[dir] && "riichi"]}></div>
        <div class={["wind-marker", @turn == dir && "highlighted"]}><%= symbol %></div>
        <div class="score">25000</div>
      </div>
      <% end %>
    </div>
    """
  end

  def handle_event("set_turn", _assigns, socket) do
    [{game_state, _}] = Registry.lookup(RiichiAdvanced.Registry, :game_state)
    GenServer.cast(game_state, {:change_turn, socket.assigns.seat})
    {:noreply, socket}
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    {:ok, socket}
  end
end
