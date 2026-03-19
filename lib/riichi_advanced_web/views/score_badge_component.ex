defmodule RiichiAdvancedWeb.ScoreBadgeComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["score-badge", @dir]} phx-hover="hover" phx-hover-off="hover_off" phx-target={@parent_cid} phx-value-key={@dir}>
      <div class="initial-score"><%= @score %></div>
      <%= if @delta_score != 0 do %>
        <div class={["delta-score", if @delta_score >= 0 do "positive" else "negative" end]}>
          <%= if @delta_score >= 0 do "+" else "−" end %>
          <%= abs(@delta_score) %>
        </div>
      <% end %>
      <div class="hline"></div>
      <div class="player-name"><%= if @name == "" do "Player" else @name end %></div>
      <div class="placement"><div class="placement-place"><%= dt(@lang, @placement) %></div></div>
    </div>
    """
  end
end
