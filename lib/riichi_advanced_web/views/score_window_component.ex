defmodule RiichiAdvancedWeb.ScoreWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", @delta_scores == nil && "inactive"]}>
      <%= if @delta_scores != nil do %>
        <div class="delta-score self">
          <div class="initial"><%= @players[@seat].score - @delta_scores[@seat] %></div>
          <div class={["change", if @delta_scores[@seat] >= 0 do "positive" else "negative" end]}>
            <%= if @delta_scores[@seat] >= 0 do "+" else "−" end %>
            <%= abs(@delta_scores[@seat]) %>
          </div>
          <div class="hline"></div>
          <div class="result"><%= @players[@seat].score %></div>
        </div>
        <div class="delta-score shimocha">
          <div class="initial"><%= @players[Utils.get_seat(@seat, :shimocha)].score - @delta_scores[Utils.get_seat(@seat, :shimocha)] %></div>
          <div class={["change", if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "positive" else "negative" end]}>
            <%= if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "+" else "−" end %>
            <%= abs(@delta_scores[Utils.get_seat(@seat, :shimocha)]) %>
          </div>
          <div class="hline"></div>
          <div class="result"><%= @players[Utils.get_seat(@seat, :shimocha)].score %></div>
        </div>
        <div class="delta-score toimen">
          <div class="initial"><%= @players[Utils.get_seat(@seat, :toimen)].score - @delta_scores[Utils.get_seat(@seat, :toimen)] %></div>
          <div class={["change", if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "positive" else "negative" end]}>
            <%= if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "+" else "−" end %>
            <%= abs(@delta_scores[Utils.get_seat(@seat, :toimen)]) %>
          </div>
          <div class="hline"></div>
          <div class="result"><%= @players[Utils.get_seat(@seat, :toimen)].score %></div>
        </div>
        <div class="delta-score kamicha">
          <div class="initial"><%= @players[Utils.get_seat(@seat, :kamicha)].score - @delta_scores[Utils.get_seat(@seat, :kamicha)] %></div>
          <div class={["change", if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "positive" else "negative" end]}>
            <%= if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "+" else "−" end %>
            <%= abs(@delta_scores[Utils.get_seat(@seat, :kamicha)]) %>
          </div>
          <div class="hline"></div>
          <div class="result"><%= @players[Utils.get_seat(@seat, :kamicha)].score %></div>
        </div>
        <div class="timer" phx-click="ready_for_next_round"><%= @timer %></div>
      <% end %>
    </div>
    """
  end
end
