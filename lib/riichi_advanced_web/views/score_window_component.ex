defmodule RiichiAdvancedWeb.ScoreWindowComponent do
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :hovered, nil)
    socket = assign(socket, :txns, [])
    {:ok, socket}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={["game-modal-container", @visible_screen != :scores && "inactive"]}>
      <div class={["game-modal", "game-modal-hide"] ++ get_arrow_classes(@seat, @delta_scores, @round_result)}>
        <svg class="arrow t2u" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="t2u" style="--xpos: 6.875; --ypos: 3; --rotate: 90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow u2t" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="u2t" style="--xpos: 6.875; --ypos: 10.5; --rotate: -90; --length: 7.5;"><use href="#arrow"/></svg>
        <svg class="arrow k2s" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="k2s" style="--xpos: 4.5; --ypos: 6.625; --rotate: 0; --length: 5;"><use href="#arrow"/></svg>
        <svg class="arrow s2k" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="s2k" style="--xpos: 9.25; --ypos: 6.625; --rotate: 180; --length: 5;"><use href="#arrow"/></svg>
        <svg class="curve k2u" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="k2u" style="--xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve s2u" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="s2u" style="--xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve"/></svg>
        <svg class="curve s2t" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="s2t" style="--xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve k2t" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="k2t" style="--xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve"/></svg>
        <svg class="curve u2k" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="u2k" style="--xscale: 1; --yscale: 1; --xpos: 2.25; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve u2s" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="u2s" style="--xscale: -1; --yscale: 1; --xpos: 8.75; --ypos: 8;"><use href="#curve2"/></svg>
        <svg class="curve t2s" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="t2s" style="--xscale: -1; --yscale: -1; --xpos: 8.75; --ypos: 1.5;"><use href="#curve2"/></svg>
        <svg class="curve t2k" phx-hover="hover" phx-focus="hover" phx-hover-off="hover_off" phx-blur="hover_off" phx-target={@myself} phx-value-key="t2k" style="--xscale: 1; --yscale: -1; --xpos: 2.25; --ypos: 1.5;"><use href="#curve2"/></svg>
        <%= if not Enum.empty?(@delta_scores) do %>
          <div class="delta-score-reason" style={"--width: #{String.length(@delta_scores_reason)}"} :if={@delta_scores_reason}><%= dt(@lang, @delta_scores_reason) %></div>
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
        <div class={["score-ledger-container"] ++ [@hovered]} :if={@txns != nil and @players != nil}>
          <%= for {key, _total, line_items} <- format_txns(@txns, @seat, @players) do %>
            <table class={["score-ledger", key]}>
              <thead><tr>
                <th colspan="5"><%= key_title(@players, @seat, key) %>
                  <div class="score-ledger-mini">
                    <span class={["mini-self" | if mini_highlight?(key, :self) do ["selected"] else [] end]}></span>
                    <span class={["mini-shimocha" | if mini_highlight?(key, :shimocha) do ["selected"] else [] end]}></span>
                    <span class={["mini-toimen" | if mini_highlight?(key, :toimen) do ["selected"] else [] end]}></span>
                    <span class={["mini-kamicha" | if mini_highlight?(key, :kamicha) do ["selected"] else [] end]}></span>
                  </div>
                </th>
              </tr></thead>
              <tbody>
                <%= for %{op: op, amount: amount, result: result, reason: reason} <- line_items do %>
                  <tr class={if reason == "Total" do "score-ledger-total" else nil end}>
                    <td class="score-ledger-op"><%= display_op(op) %></td>
                    <td class="score-ledger-amount"><%= if amount != nil do Utils.try_integer(round(amount * 100) / 100) else "" end %></td>
                    <td><%= if op != nil do "=" else "" end %></td>
                    <td class="score-ledger-result"><%= if result != nil do Utils.try_integer(round(result * 100) / 100) else "" end %></td>
                    <td class="score-ledger-reason"><%= reason %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          <% end %>
        </div>
        </div>
      <div class="timer" phx-cancellable-click="ready_for_next_round">
        <%= if @timer == -1 do %>
          <%= dt(@lang, "Dismiss") %>
        <% else %>
          <%= dt(@lang, "Skip") %> (<%= @timer %>)
        <% end %>
      </div>
      <svg>
        <symbol id="arrow">
          <defs>
            <linearGradient id="fade" x2="1">
              <stop offset="0%" stop-color="white" stop-opacity="0"/>
              <stop offset="100%" stop-color="white" stop-opacity="1"/>
            </linearGradient>
            <mask id="tailMask" maskContentUnits="userSpaceOnUse">
              <rect x="70" y="-50%" width="45" height="max(99999px, 100%)" fill="url(#fade)" stroke-width="0px"/>
              <rect x="115" y="-50%" width="max(99999px, 100%)" height="max(99999px, 100%)" fill="white" stroke-width="0px"/>
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

  def get_name(seat, players) do
    cond do
      seat == nil -> "Pot"
      not Map.has_key?(players, seat) -> ""
      true ->
        ret = players[seat].nickname
        ret = if ret == "" or ret == nil do Atom.to_string(seat) |> String.capitalize() else ret end
        ret
    end
  end

  def format_txns(txns, seat, _players) do
    # first make ledger for arrows
    ret = for txn = %{from: from, to: to, line_items: line_items} <- txns, reduce: [] do
      ret -> [{make_key(seat, from, to), Payment.get_txn_result(txn), Enum.reverse(line_items)} | ret]
    end
    # then make ledgers for individual players
    ret = for {seat2, txn} <- Payment.consolidate_txns(txns), reduce: ret do
      ret when seat2 == nil -> ret # don't display transactions with the pot
      ret ->
        result = Payment.get_txn_result(txn)
        if result == 0 do
          ret
        else
          line_items = [%{op: nil, amount: nil, result: result, reason: "Total"} | txn.line_items]
          [{Utils.get_relative_seat(seat, seat2) |> Atom.to_string(), result, Enum.reverse(line_items)} | ret]
        end
    end
    ret
  end

  def get_arrow_classes(our_seat, delta_scores, round_result) do
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
    for {w, _delta} <- winners, {l, _delta} <- losers, do: "#{l}2#{w}"

    if length(winners) == 2 and length(losers) == 2 and round_result == :exhaustive_draw do
      # 2 arrows for riichi noten payments
      for {{w, _delta}, {l, _delta2}} <- Enum.zip(winners, losers), do: "#{l}2#{w}"
    else
      for {w, _delta} <- winners, {l, _delta} <- losers, do: "#{l}2#{w}"
    end
  end

  def display_op(op) do
    case op do
      "+" -> "+"
      "-" -> "-"
      "*" -> "×"
      "/" -> "÷"
      "round" -> "↕"
      "round_up" -> "↑"
      "round_down" -> "↓"
      _  -> ""
    end
  end

  def make_key(seat, from, to) do
    if from === nil or to === nil do
      "pot"
    else
      case {Utils.get_relative_seat(seat, from), Utils.get_relative_seat(seat, to)} do
        {:self, :self}         -> "self"
        {:self, :shimocha}     -> "u2s"
        {:self, :toimen}       -> "u2t"
        {:self, :kamicha}      -> "u2k"
        {:shimocha, :self}     -> "s2u"
        {:shimocha, :shimocha} -> "shimocha"
        {:shimocha, :toimen}   -> "s2t"
        {:shimocha, :kamicha}  -> "s2k"
        {:toimen, :self}       -> "t2u"
        {:toimen, :shimocha}   -> "t2s"
        {:toimen, :toimen}     -> "toimen"
        {:toimen, :kamicha}    -> "t2k"
        {:kamicha, :self}      -> "k2u"
        {:kamicha, :shimocha}  -> "k2s"
        {:kamicha, :toimen}    -> "k2t"
        {:kamicha, :kamicha}   -> "kamicha"
      end
    end
  end

  def key_title(players, seat, key) do
    u = Utils.get_seat(seat, :self)
    s = Utils.get_seat(seat, :shimocha)
    t = Utils.get_seat(seat, :toimen)
    k = Utils.get_seat(seat, :kamicha)
    dirs = Map.new(%{u: u, s: s, t: t, k: k}, fn {key, seat2} ->
      name = get_name(seat2, players)
      {key, if name == "" do Utils.get_seat(seat2, :self) |> Atom.to_string() |> String.capitalize() else name end}
    end)
    case key do
      "self"     -> dirs.u
      "shimocha" -> dirs.s
      "toimen"   -> dirs.t
      "kamicha"  -> dirs.k
      "t2u"      -> dirs.t <> " → " <> dirs.u
      "u2t"      -> dirs.u <> " → " <> dirs.t
      "k2s"      -> dirs.k <> " → " <> dirs.s
      "s2k"      -> dirs.s <> " → " <> dirs.k
      "k2u"      -> dirs.k <> " → " <> dirs.u
      "s2u"      -> dirs.s <> " → " <> dirs.u
      "s2t"      -> dirs.s <> " → " <> dirs.t
      "k2t"      -> dirs.k <> " → " <> dirs.t
      "u2k"      -> dirs.u <> " → " <> dirs.k
      "u2s"      -> dirs.u <> " → " <> dirs.s
      "t2s"      -> dirs.t <> " → " <> dirs.s
      "t2k"      -> dirs.t <> " → " <> dirs.k
      "pot"      -> "pot"
      _ ->
        IO.puts("score_window_component.ex: key_title/3 got unknown key #{key}")
        "TODO"
    end
  end

  def mini_highlight?(key, dir) do
    u = dir == :self
    s = dir == :shimocha
    t = dir == :toimen
    k = dir == :kamicha
    case key do
      "self"     -> u
      "shimocha" -> s
      "toimen"   -> t
      "kamicha"  -> k
      "t2u"      -> t or u
      "u2t"      -> u or t
      "k2s"      -> k or s
      "s2k"      -> s or k
      "k2u"      -> k or u
      "s2u"      -> s or u
      "s2t"      -> s or t
      "k2t"      -> k or t
      "u2k"      -> u or k
      "u2s"      -> u or s
      "t2s"      -> t or s
      "t2k"      -> t or k
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
