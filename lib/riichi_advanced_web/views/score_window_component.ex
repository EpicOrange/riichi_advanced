defmodule RiichiAdvancedWeb.ScoreWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["game-end-window", (not Enum.empty?(@winners) || @delta_scores == nil) && "inactive"]}>
      <%= if Enum.empty?(@winners) && @delta_scores != nil do %>
        <div class="delta-score-reason"><%= @delta_scores_reason %></div>
        <div class="delta-score self">
          <%= if @delta_scores[@seat] != 0 do %>
            <div class="initial"><%= @players[@seat].score %></div>
            <div class={["change", if @delta_scores[@seat] >= 0 do "positive" else "negative" end]}>
              <%= if @delta_scores[@seat] >= 0 do "+" else "−" end %>
              <%= abs(@delta_scores[@seat]) %>
            </div>
            <div class="hline"></div>
            <div class="result"><%= @players[@seat].score + @delta_scores[@seat] %></div>
          <% else %>
            <div class="result"><%= @players[@seat].score %></div>
          <% end %>
        </div>
        <div class="delta-score shimocha">
          <%= if @delta_scores[Utils.get_seat(@seat, :shimocha)] != 0 do %>
            <div class="initial"><%= @players[Utils.get_seat(@seat, :shimocha)].score %></div>
            <div class={["change", if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "positive" else "negative" end]}>
              <%= if @delta_scores[Utils.get_seat(@seat, :shimocha)] >= 0 do "+" else "−" end %>
              <%= abs(@delta_scores[Utils.get_seat(@seat, :shimocha)]) %>
            </div>
            <div class="hline"></div>
            <div class="result"><%= @players[Utils.get_seat(@seat, :shimocha)].score + @delta_scores[Utils.get_seat(@seat, :shimocha)] %></div>
          <% else %>
            <div class="result"><%= @players[Utils.get_seat(@seat, :shimocha)].score %></div>
          <% end %>
        </div>
        <div class="delta-score toimen">
          <%= if @delta_scores[Utils.get_seat(@seat, :toimen)] != 0 do %>
            <div class="initial"><%= @players[Utils.get_seat(@seat, :toimen)].score %></div>
            <div class={["change", if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "positive" else "negative" end]}>
              <%= if @delta_scores[Utils.get_seat(@seat, :toimen)] >= 0 do "+" else "−" end %>
              <%= abs(@delta_scores[Utils.get_seat(@seat, :toimen)]) %>
            </div>
            <div class="hline"></div>
            <div class="result"><%= @players[Utils.get_seat(@seat, :toimen)].score + @delta_scores[Utils.get_seat(@seat, :toimen)] %></div>
          <% else %>
            <div class="result"><%= @players[Utils.get_seat(@seat, :toimen)].score %></div>
          <% end %>
        </div>
        <div class="delta-score kamicha">
          <%= if @delta_scores[Utils.get_seat(@seat, :kamicha)] != 0 do %>
            <div class="initial"><%= @players[Utils.get_seat(@seat, :kamicha)].score %></div>
            <div class={["change", if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "positive" else "negative" end]}>
              <%= if @delta_scores[Utils.get_seat(@seat, :kamicha)] >= 0 do "+" else "−" end %>
              <%= abs(@delta_scores[Utils.get_seat(@seat, :kamicha)]) %>
            </div>
            <div class="hline"></div>
            <div class="result"><%= @players[Utils.get_seat(@seat, :kamicha)].score + @delta_scores[Utils.get_seat(@seat, :kamicha)] %></div>
          <% else %>
            <div class="result"><%= @players[Utils.get_seat(@seat, :kamicha)].score %></div>
          <% end %>
        </div>
        <div class="timer" phx-click="ready_for_next_round"><%= @timer %></div>
      <% end %>
    </div>
    """
  end
end
