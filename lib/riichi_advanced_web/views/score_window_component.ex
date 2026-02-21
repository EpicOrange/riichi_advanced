defmodule RiichiAdvancedWeb.ScoreWindowComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  @example_payments %{
    "self" => [
        [:set, 3900, "Nondealer Ron"],
        [:add, 300, "Honba"],
        [:add, 300, "Arakawa Kei"],
        [:multiply, 2, "Wareme"],
        [:add, 2000, "Riichi Bets"],
        [:total, 11000, "Total"]
    ],
    "shimocha" => [
        [:set, -3900, "Nondealer Ron"],
        [:add, -300, "Honba"],
        [:add, -300, "Arakawa Kei"],
        [:multiply, 2, "Wareme"],
        [:total, -9000, "Total"]
    ],
    "s2u" => [
        [:set, 3900, "Nondealer Ron"],
        [:add, 300, "Honba"],
        [:add, 300, "Arakawa Kei"],
        [:multiply, 2, "Wareme"],
        [:total, 9000, "Total"]
    ],
  }

  def mount(socket) do
    socket = assign(socket, :payments, @example_payments)
    socket = assign(socket, :hovered, [])
    {:ok, socket}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={["game-modal-container", @visible_screen != :scores && "inactive"]}>
      <div class={["game-modal", "game-modal-hide"] ++ get_arrow_classes(@seat, @delta_scores)}>
        <svg class="arrow t2u" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="t2u" style="--xpos: 6.875; --ypos: 3; --rotate: 90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow u2t" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="u2t" style="--xpos: 6.875; --ypos: 10.5; --rotate: -90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow k2s" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="k2s" style="--xpos: 4.5; --ypos: 6.625; --rotate: 0; --length: 5;"><use href="#arrow"/></svg>
        <svg class="arrow s2k" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="s2k" style="--xpos: 9.25; --ypos: 6.625; --rotate: 180; --length: 5;"><use href="#arrow"/></svg>
        <svg class="curve k2u" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="k2u" style="--xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve s2u" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="s2u" style="--xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve s2t" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="s2t" style="--xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve k2t" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="k2t" style="--xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve u2k" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="u2k" style="--xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve u2s" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="u2s" style="--xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve t2s" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="t2s" style="--xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve2"/></svg>
        <svg class="curve t2k" phx-hover="hover" phx-hover-off="hover_off" phx-target={@myself} phx-value-key="t2k" style="--xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve2"/></svg>
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
              parent_cid={@myself}
              :if={Utils.get_seat(@seat, dir) in @available_seats} />
          <% end %>
        <% end %>
        <div class={["score-ledger-container"] ++ [@hovered]}>
          <%= for {key, payments} <- @payments do %>
            <table class={["score-ledger", key]}>
              <thead><tr>
                <th colspan="3"><%= key_title(@players, @seat, key) %>
                  <div class="score-ledger-mini">
                    <span class="mini-east selected"></span>
                    <span class="mini-south"></span>
                    <span class="mini-west"></span>
                    <span class="mini-north"></span>
                  </div>
                </th>
              </tr></thead>
              <tbody>
                <%= for [op, value, reason] <- payments do %>
                  <tr class={if op == :total do "score-ledger-total" else nil end}>
                    <td class="score-ledger-reason"><%= reason %></td>
                    <td class="score-ledger-op"><%= display_op(op) %></td>
                    <td class="score-ledger-value"><%= value %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
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

  def get_arrow_classes(our_seat, delta_scores) do
    # TODO: just because someone lost pts, doesn't necessarily mean they paid everyone who got points
    # we'll change this once we find an example situation (double ron pao is one of them)
    {winners, losers} = delta_scores
    |> Enum.filter(fn {_seat, delta} -> delta != 0 end)
    |> Enum.map(fn {seat, delta} -> case Utils.get_relative_seat(our_seat, seat) do
      :shimocha -> {"s", delta}
      :toimen   -> {"t", delta}
      :kamicha  -> {"k", delta}
      :self     -> {"u", delta}
    end end)
    |> Enum.split_with(fn {_seat, delta} -> delta > 0 end)
    if length(winners) == 2 and length(losers) == 2 do
      for {{w, _delta}, {l, _delta2}} <- Enum.zip(winners, losers), do: "#{l}2#{w}"
    else
      for {w, _delta} <- winners, {l, _delta} <- losers, do: "#{l}2#{w}"
    end
  end

  def display_op(op) do
    case op do
      :add      -> "+"
      :subtract -> "-"
      :multiply -> "×"
      :divide   -> "÷"
      _         -> ""
    end
  end

  def key_title(players, seat, key) do
    dirs = %{
      u: players[Utils.get_seat(seat, :self)].nickname,
      s: players[Utils.get_seat(seat, :shimocha)].nickname,
      t: players[Utils.get_seat(seat, :toimen)].nickname,
      k: players[Utils.get_seat(seat, :kamicha)].nickname,
    }
    default = fn s, dir -> s |> Utils.get_seat(dir) |> Atom.to_string() |> String.capitalize() end
    dirs = %{
      u: if dirs.u == "" do default.(seat, :self) else dirs.u end,
      s: if dirs.s == "" do default.(seat, :shimocha) else dirs.s end,
      t: if dirs.t == "" do default.(seat, :toimen) else dirs.t end,
      k: if dirs.k == "" do default.(seat, :kamicha) else dirs.k end,
    }
    case key do
      "self"     -> dirs.u
      "shimocha" -> dirs.s
      "toimen"   -> dirs.t
      "kamicha"  -> dirs.k
      "t2u"      -> dirs.t <> "→" <> dirs.u
      "u2t"      -> dirs.u <> "→" <> dirs.t
      "k2s"      -> dirs.k <> "→" <> dirs.s
      "s2k"      -> dirs.s <> "→" <> dirs.k
      "k2u"      -> dirs.k <> "→" <> dirs.u
      "s2u"      -> dirs.s <> "→" <> dirs.u
      "s2t"      -> dirs.s <> "→" <> dirs.t
      "k2t"      -> dirs.k <> "→" <> dirs.t
      "u2k"      -> dirs.u <> "→" <> dirs.k
      "u2s"      -> dirs.u <> "→" <> dirs.s
      "t2s"      -> dirs.t <> "→" <> dirs.s
      "t2k"      -> dirs.t <> "→" <> dirs.k
      _ -> "TODO"
    end
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    # TODO don't caclulate every tick, e.g. if only the skip counter changes
    placements = socket.assigns.players
      |> Enum.map(fn {seat, player} -> {seat, player.score + Map.get(assigns.delta_scores, seat, 0)} end)
      |> Enum.sort_by(fn {_seat, score} -> -score end)
      |> Enum.zip(["1st", "2nd", "3rd", "4th"])
      |> Map.new(fn {{seat, _score}, place} -> {seat, place} end)
    socket = assign(socket, :placements, placements)

    {:ok, socket}
  end

  def handle_event("hover", %{"key" => key}, socket) do
    socket = assign(socket, :hovered, key)
    {:noreply, socket}
  end

  def handle_event("hover_off", _assigns, socket) do
    socket = assign(socket, :hovered, nil);
    {:noreply, socket}
  end
end
