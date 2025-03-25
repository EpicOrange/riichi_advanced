defmodule RiichiAdvancedWeb.ScoreWindowComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-modal-container", @visible_screen != :scores && "inactive"]}>
      <div class="game-modal game-modal-hide">
        <%= if not Enum.empty?(@delta_scores) do %>
          <div class="delta-score-reason"><%= dt(@lang, @delta_scores_reason) %></div>
          <div class="delta-score self" :if={@seat in @available_seats}>
            <%= if @delta_scores[@seat] != 0 do %>
              <div class="initial"><%= @players[@seat].score %></div>
              <div class={["change", if @delta_scores[@seat] >= 0 do "positive" else "negative" end]}>
                <%= if @delta_scores[@seat] >= 0 do "+" else "−" end %>
                <%= abs(@delta_scores[@seat]) %>
              </div>
              <div class="hline"></div>
              <div class="result"><%= @players[@seat].score + @delta_scores[@seat] %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[@seat]) %></div></div>
            <% else %>
              <div class="result"><%= @players[@seat].score %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[@seat]) %></div></div>
            <% end %>
          </div>
          <div class="delta-score shimocha" :if={Utils.get_seat(@seat, :shimocha) in @available_seats}>
            <%= if @delta_scores[Utils.get_seat(@seat, :shimocha)] != 0 do %>
              <div class="initial"><%= @players[Utils.get_seat(@seat, :shimocha)].score %></div>
              <div class={["change", if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "positive" else "negative" end]}>
                <%= if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "+" else "−" end %>
                <%= abs(@delta_scores[Utils.get_seat(@seat, :shimocha)]) %>
              </div>
              <div class="hline"></div>
              <div class="result"><%= @players[Utils.get_seat(@seat, :shimocha)].score + @delta_scores[Utils.get_seat(@seat, :shimocha)] %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :shimocha)]) %></div></div>
            <% else %>
              <div class="result"><%= @players[Utils.get_seat(@seat, :shimocha)].score %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :shimocha)]) %></div></div>
            <% end %>
          </div>
          <div class="delta-score toimen" :if={Utils.get_seat(@seat, :toimen) in @available_seats}>
            <%= if @delta_scores[Utils.get_seat(@seat, :toimen)] != 0 do %>
              <div class="initial"><%= @players[Utils.get_seat(@seat, :toimen)].score %></div>
              <div class={["change", if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "positive" else "negative" end]}>
                <%= if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "+" else "−" end %>
                <%= abs(@delta_scores[Utils.get_seat(@seat, :toimen)]) %>
              </div>
              <div class="hline"></div>
              <div class="result"><%= @players[Utils.get_seat(@seat, :toimen)].score + @delta_scores[Utils.get_seat(@seat, :toimen)] %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :toimen)]) %></div></div>
            <% else %>
              <div class="result"><%= @players[Utils.get_seat(@seat, :toimen)].score %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :toimen)]) %></div></div>
            <% end %>
          </div>
          <div class="delta-score kamicha" :if={Utils.get_seat(@seat, :kamicha) in @available_seats}>
            <%= if @delta_scores[Utils.get_seat(@seat, :kamicha)] != 0 do %>
              <div class="initial"><%= @players[Utils.get_seat(@seat, :kamicha)].score %></div>
              <div class={["change", if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "positive" else "negative" end]}>
                <%= if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "+" else "−" end %>
                <%= abs(@delta_scores[Utils.get_seat(@seat, :kamicha)]) %>
              </div>
              <div class="hline"></div>
              <div class="result"><%= @players[Utils.get_seat(@seat, :kamicha)].score + @delta_scores[Utils.get_seat(@seat, :kamicha)] %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :kamicha)]) %></div></div>
            <% else %>
              <div class="result"><%= @players[Utils.get_seat(@seat, :kamicha)].score %></div>
              <div class="placement"><div class="placement-place"><%= dt(@lang, @placements[Utils.get_seat(@seat, :kamicha)]) %></div></div>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class="timer" phx-cancellable-click="ready_for_next_round">Skip (<%= @timer %>)</div>
    </div>
    """
  end


  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    placements = socket.assigns.players
      |> Enum.map(fn {seat, player} -> {seat, player.score + Map.get(assigns.delta_scores, seat, 0)} end)
      |> Enum.sort_by(fn {_seat, score} -> -score end)
      |> Enum.zip(["1st", "2nd", "3rd", "4th"])
      |> Map.new(fn {{seat, _score}, place} -> {seat, place} end)
    socket = assign(socket, :placements, placements)

    {:ok, socket}
  end
end
