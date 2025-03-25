defmodule RiichiAdvancedWeb.EndWindowComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-modal-container", @visible_screen != :game_end && "inactive"]}>
      <div class="game-modal game-modal-hide">
        <div class="scoreboard">
          <%= for {{name, score}, place} <- @players
                |> Enum.map(fn {seat, player} -> {if player.nickname == nil do Atom.to_string(seat) else player.nickname end, player.score} end)
                |> Enum.sort_by(fn {_name, score} -> -score end)
                |> Enum.zip([t(@lang, "1st"), t(@lang, "2nd"), t(@lang, "3rd"), t(@lang, "4th")]) do %>
            <div class="placement">
              <div class="placement-place"><%= place %></div>
              <div class="placement-name"><%= name %>: <span class="placement-score"><%= score %></span></div>
            </div>
          <% end %>
        </div>
      </div>
      <button class="end-back-button" phx-cancellable-click="back">Return to room config</button>
    </div>
    """
  end

  def handle_event("dismiss_error", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, :dismiss_error)
    {:noreply, socket}
  end
end
