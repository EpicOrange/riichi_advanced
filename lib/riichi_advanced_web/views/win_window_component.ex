defmodule RiichiAdvancedWeb.WinWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :winner, nil)
    socket = assign(socket, :timer, 0)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", @winner == nil && "inactive"]}>
      <%= if @winner != nil && @winner.yaku != nil do %>
        <div class="hand winning-hand">
          <div class={["tile", tile]} :for={tile <- @winner.player.hand}></div>
          <%= for {_name, call} <- @winner.player.calls do %>
            <div class="call">
              <div class={["tile", tile, sideways && "sideways"]} :for={{tile, sideways} <- call}></div>
            </div>
          <% end %>
          <div class={["tile", "winning-tile", @winner.winning_tile]}></div>
        </div>
        <div class="yakus">
          <%= if Enum.empty?(@winner.yakuman) do %>
            <%= for {name, points} <- @winner.yaku do %>
              <div class="yaku">
                <div class="yaku-text"><%= name %></div>
                <div class="han-counter"><%= points %> <%= @winner.point_name %></div>
              </div>
            <% end %>
          <% else %>
            <%= for {name, points} <- @winner.yakuman do %>
              <div class="yaku">
                <div class="yaku-text"><%= name %></div>
                <div class="han-counter"><%= points %> ★</div>
              </div>
            <% end %>
          <% end %>
        </div>
        <div class="score-display">
          <%= if Enum.empty?(@winner.yakuman) do %>
            <div class="total-han-display"><%= @winner.points %> <%= @winner.point_name %></div>
            <div class="total-fu-display" :if={Map.has_key?(@winner, :minipoints)}><%= @winner.minipoints %> Fu</div>
            <div class="total-score-display"><%= @winner.score %></div>
            <div class="total-score-name-display" :if={@winner.score_name != ""}><%= @winner.score_name %></div>
          <% else %>
            <div class="total-han-display"><%= @winner.yakuman_mult %> ★</div>
            <div class="total-score-display"><%= @winner.score %></div>
            <div class="total-score-name-display">Yakuman</div>
          <% end %>
        </div>
        <div class="timer" phx-click="ready_for_next_round" phx-target={@myself}><%= @timer %></div>
      <% end %>
    </div>
    """
  end

  def handle_event("ready_for_next_round", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, socket.assigns.seat})
    socket = assign(socket, :timer, 0)
    {:noreply, socket}
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    {:ok, socket}
  end
end
