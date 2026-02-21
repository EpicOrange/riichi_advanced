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
        <svg class="arrow" style="display: none; --xpos: 6.875; --ypos: 3; --rotate: 90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow" style="display: none; --xpos: 6.875; --ypos: 10.5; --rotate: -90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow" style="display: none; --xpos: 4.5; --ypos: 6.625; --rotate: 0; --length: 5;"><use href="#arrow"/></svg>
        <svg class="arrow" style="display: none; --xpos: 9.25; --ypos: 6.625; --rotate: 180; --length: 5;"><use href="#arrow"/></svg>
        <svg class="curve" style="display: none; --xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve" style="display: none; --xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve" style="display: none; --xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve" style="display: none; --xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve" style="display: none; --xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve" style="display: none; --xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve" style="display: none; --xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve2"/></svg>
        <svg class="curve" style="display: none; --xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve2"/></svg>
        <%= if not Enum.empty?(@delta_scores) do %>
          <div class="delta-score-reason"><%= dt(@lang, @delta_scores_reason) %></div>
          <%= for dir <- [:self, :shimocha, :toimen, :kamicha] do %>
            <.live_component module={RiichiAdvancedWeb.ScoreBadgeComponent}
              id={"score-badge-#{dir}"}
              dir={dir}
              lang={@lang}
              seat={Utils.get_seat(@seat, dir)}
              placement={@placements[Utils.get_seat(@seat, dir)]}
              name={@players[Utils.get_seat(@seat, dir)].nickname}
              score={@players[Utils.get_seat(@seat, dir)].score}
              delta_score={@delta_scores[Utils.get_seat(@seat, dir)]}
              :if={Utils.get_seat(@seat, dir) in @available_seats} />
          <% end %>
        <% end %>
      </div>
      <div class="timer" phx-cancellable-click="ready_for_next_round">Skip (<%= @timer %>)</div>
      <svg style="display: none">
        <symbol id="arrow">
          <defs>
            <linearGradient id="fade" x2="1">
              <stop offset="0%" stop-color="white" stop-opacity="0"/>
              <stop offset="100%" stop-color="white" stop-opacity="1"/>
            </linearGradient>
            <mask id="tailMask" maskContentUnits="userSpaceOnUse">
              <rect x="70" y="-50%" width="45" height="100%" fill="url(#fade)" stroke-width="0px"/>
              <rect x="115" y="-50%" width="100%" height="100%" fill="white" stroke-width="0px"/>
            </mask>
          </defs>
          <rect mask="url(#tailMask)" x="0" y="0" width="100%" height="50" style="transform:translate(-70px,calc(50% - 25px))"/>
          <path d="M 0,125 v 50 l 90,-75 -90,-75 v 50" style="transform:translateX(calc(100% - 100px))"/>
        </symbol>
        <symbol id="curve" viewBox="0 0 125 200" overflow="visible">
          <defs>
            <linearGradient id="fade2" x1="0%" y1="100%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="white" stop-opacity="1"/>
              <stop offset="90%" stop-color="white" stop-opacity="1"/>
              <stop offset="90%" stop-color="white" stop-opacity="0"/>
            </linearGradient>
            <marker id="arrowhead2" viewBox="0 25 200 175" markerUnits="userSpaceOnUse" markerWidth="50" markerHeight="40" refX="90" refY="100" orient="0" fill="context-stroke">
              <path d="M 0,125 v 50 l 90,-75 -90,-75 v 50 z" fill="white"/>
            </marker>
          </defs>
          <path d="M0,0 Q0,200 130,200" fill="none" stroke="url(#fade2)" stroke-width="45" vector-effect="non-scaling-stroke" marker-end="url(#arrowhead2)"/>
        </symbol>
        <symbol id="curve2" viewBox="0 0 125 200" overflow="visible">
          <defs>
            <linearGradient id="fade3" x1="0%" y1="100%" x2="0%" y2="0%">
              <stop offset="0%" stop-color="white" stop-opacity="1"/>
              <stop offset="90%" stop-color="white" stop-opacity="1"/>
              <stop offset="90%" stop-color="white" stop-opacity="0"/>
            </linearGradient>
            <marker id="arrowhead3" viewBox="0 25 200 175" markerUnits="userSpaceOnUse" markerWidth="50" markerHeight="40" refX="90" refY="100" orient="-90deg" fill="context-stroke">
              <path d="M 0,125 v 50 l 90,-75 -90,-75 v 50 z" fill="white"/>
            </marker>
          </defs>
          <path d="M150,200 Q0,200 0,0" fill="none" stroke="url(#fade3)" stroke-width="45" vector-effect="non-scaling-stroke" marker-end="url(#arrowhead3)"/>
        </symbol>
      </svg>
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
