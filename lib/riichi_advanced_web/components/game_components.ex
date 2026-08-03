defmodule RiichiAdvancedWeb.GameComponents do
  alias RiichiAdvanced.GameState
  alias RiichiAdvanced.GameState.Rules
  alias RiichiAdvanced.Utils
  use Phoenix.Component
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  attr :state, :any, required: true
  attr :ruleset, :any, required: true
  attr :seat, :any, required: true
  attr :game_state, :any, required: true
  attr :viewer, :any, required: true
  attr :hovered_called_tile, :any, required: true
  attr :hovered_call_choice, :any, required: true
  attr :playable_indices, :any, required: true
  attr :selected_index, :any, required: true
  attr :preplayed_index, :any, required: true
  attr :lang, :any, required: true
  attr :display_riichi_sticks, :any, required: true
  attr :display_honba, :any, required: true
  attr :waiting_on_timer, :any, required: true
  attr :hide_buttons, :any, required: true
  attr :marking, :any, required: true
  attr :revealed_tiles, :any, required: true
  attr :loading, :any, required: true
  attr :visible_waits, :any, required: true
  attr :show_waits_index, :any, required: true
  attr :messages, :any, required: true
  attr :messages_state, :any, required: true
  attr :tutorial_state, :any, required: true
  def game_view(assigns) do
    ~H"""
    <div id="container" class={[@ruleset == "minefield" && "minefield"]} phx-hook="ClickListener">
      <%= if Rules.has_key?(@state.rules_ref, "custom_style") do %>
        <.live_component module={RiichiAdvancedWeb.CustomStyleComponent} id="custom-tiles" style={Rules.get(@state.rules_ref, "custom_style", %{})}/>
      <% end %>
      <input id="mobile-zoom-checkbox" type="checkbox" class="mobile-zoom-checkbox" phx-update="ignore">
      <label for="mobile-zoom-checkbox">
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 4H4m0 0v4m0-4 5 5m7-5h4m0 0v4m0-4-5 5M8 20H4m0 0v-4m0 4 5-5m7 5h4m0 0v-4m0 4-5-5"/>
        </svg>
        <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#f4f0eb" fill="#f4f0eb" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5 9h4m0 0V5m0 4L4 4m15 5h-4m0 0V5m0 4 5-5M5 15h4m0 0v4m0-4-5 5m15-5h-4m0 0v4m0-4 5 5"/>
        </svg>
      </label>
      <input id="tile-numbers-checkbox" type="checkbox" class="tile-numbers-checkbox" phx-update="ignore">
      <label for="tile-numbers-checkbox" class="game-bottom-element">123</label>
      <.live_component module={RiichiAdvancedWeb.HandComponent}
        id={"hand #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        revealed?={@viewer == seat or player.hand_revealed}
        your_hand?={@viewer == seat}
        your_turn?={@seat == @state.turn}
        seat={seat}
        viewer={@viewer}
        hand={player.hand}
        draw={player.draw}
        calls={player.calls}
        aside={player.aside}
        status={player.status}
        saki={if Map.has_key?(@state, :saki) do @state.saki else nil end}
        marking={@state.marking[@seat]}
        called_tile={@hovered_called_tile}
        call_choice={@hovered_call_choice}
        playable_indices={@playable_indices}
        selected_index={@selected_index}
        preplayed_index={@preplayed_index}
        dead_hand_buttons={Rules.get(@state.rules_ref, "dead_hand_buttons", false)}
        dead_hand?={"dead_hand" in @state.players[seat].status}
        play_tile={&send(self(), {:play_tile, &1})}
        mark_tile={&send(self(), {:mark_tile, &1, &2})}
        unmark_tile={&send(self(), {:unmark_tile, &1, &2})}
        hover={&send(self(), {:hover, &1})}
        hover_off={fn -> send(self(), :hover_off) end}
        reindex_hand={&send(self(), {:reindex_hand, &1, &2})}
        :for={{seat, player} <- @state.players} />
      <.live_component module={RiichiAdvancedWeb.PondComponent}
        id={"pond #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        seat_turn?={seat == @state.turn}
        viewer_buttons?={not Enum.empty?(@state.players[@seat].buttons)}
        seat={seat}
        viewer={@viewer}
        pond={player.pond}
        riichi={"riichi" in player.status}
        saki={if Map.has_key?(@state, :saki) do @state.saki else nil end}
        marking={@state.marking[@seat]}
        four_rows?={Rules.get(@state.rules_ref, "four_rows_discards", false)}
        :for={{seat, player} <- @state.players} />
      <.live_component module={RiichiAdvancedWeb.CornerInfoComponent}
        id={"corner-info #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        seat={seat}
        viewer={@viewer}
        player={player}
        kyoku={@state.kyoku}
        saki={if Map.has_key?(@state, :saki) do @state.saki else nil end}
        all_drafted={if Map.has_key?(@state, :saki) do RiichiAdvanced.GameState.Saki.check_if_all_drafted(@state) else nil end}
        num_players={length(@state.available_seats)}
        display_round_marker={Rules.get(@state.rules_ref, "display_round_marker", true)}
        ai_thinking={@state.players[seat].ai_thinking}
        :for={{seat, player} <- @state.players} />
      <.live_component module={RiichiAdvancedWeb.BigTextComponent}
        id={"big-text #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        seat={seat}
        relative_seat={Utils.get_relative_seat(@seat, seat)}
        lang={@lang}
        big_text={player.big_text}
        :if={player.big_text != ""}
        :for={{seat, player} <- @state.players} />
      <.live_component module={RiichiAdvancedWeb.CompassComponent}
        id="compass"
        game_state={@game_state}
        seat={@seat}
        viewer={@viewer}
        turn={@state.turn}
        tiles_left={length(@state.wall) - @state.wall_index}
        kyoku={@state.kyoku}
        honba={@state.honba}
        riichi_sticks={Utils.try_integer(@state.pot / max(1, Rules.get(@state.rules_ref, "score_calculation", %{}) |> Map.get("riichi_value", 1)))}
        riichi={Map.new(@state.players, fn {seat, player} -> {seat, player.riichi_stick} end)}
        score={Map.new(@state.players, fn {seat, player} -> {seat, player.score} end)}
        display_riichi_sticks={@display_riichi_sticks}
        display_honba={@display_honba}
        score_e_notation={Rules.get(@state.rules_ref, "score_e_notation", false)}
        available_seats={@state.available_seats}
        is_bot={Map.new([:east, :south, :west, :north], fn seat -> {seat, is_pid(Map.get(@state, seat))} end)} />
      <%= if @state.visible_screen != nil do %>
        <.live_component module={RiichiAdvancedWeb.WinWindowComponent} id="win-window" game_state={@game_state} seat={@seat} lang={@lang} winner={Map.get(@state.winners, Enum.at(@state.winner_seats, @state.winner_index), nil)} timer={@state.timer} waiting_on_timer={@waiting_on_timer} visible_screen={@state.visible_screen}/>
        <.live_component module={RiichiAdvancedWeb.ScoreWindowComponent} id="score-window" game_state={@game_state} seat={@seat} lang={@lang} players={@state.players} winners={@state.winners} delta_scores={@state.delta_scores} delta_scores_reason={@state.delta_scores_reason} timer={@state.timer} waiting_on_timer={@waiting_on_timer} visible_screen={@state.visible_screen} available_seats={@state.available_seats} txns={@state.txns} kyoku={@state.kyoku} next_dealer={@state.next_dealer} rules_ref={@state.rules_ref}/>
        <.live_component module={RiichiAdvancedWeb.EndWindowComponent} id="end-window" game_state={@game_state} seat={@seat} lang={@lang} players={@state.players} visible_screen={@state.visible_screen}/>
      <% end %>
      <%= if @state.error != nil do %>
        <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@game_state} seat={@seat} lang={@lang} players={@state.players} error={@state.error}/>
      <% end %>
      <%= if @viewer != :spectator do %>
        <div class="buttons" :if={not @hide_buttons and @state.players[@seat].declared_yaku != []}>
          <%= if @marking and not Enum.empty?(@state.marking[@seat]) do %>
            <button class="button" phx-cancellable-click="clear_marked_objects" :if={RiichiAdvanced.GameState.Marking.num_objects_needed(@state.marking[@seat]) > 1}><%= t(@lang, "Clear") %></button>
            <button class="button" phx-cancellable-click="cancel_marked_objects" :if={Keyword.get(@state.marking[@seat], :cancellable)}><%= t(@lang, "Cancel") %></button>
          <% else %>
            <%= if not Enum.empty?(@state.players[@seat].call_buttons) do %>
              <%= if Enum.all?(@state.players[@seat].call_buttons, fn {called_tile, _choices} -> called_tile != "saki" end) do %>
                <button class="button" phx-cancellable-click="cancel_call_buttons"><%= t(@lang, "Cancel") %></button>
              <% end %>
            <% else %>
              <%= for button <- @state.players[@seat].buttons, button_display_name <- [dt(@lang, get_button_name(@state.rules_ref, button))] do %>
                <button class={["button", String.length(button_display_name) >= 40 && "small-text"]} phx-cancellable-click="button_clicked" phx-hover="hover_button" phx-hover-off="hover_off" phx-value-name={button}><%= button_display_name %></button>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <.live_component module={RiichiAdvancedWeb.HandPianoComponent}
          id="hand-piano-component"
          num_keys={length(@state.players[@seat].hand)}
          game_state={@game_state}
          seat={@seat}
          viewer={@viewer}
          marking={@state.marking[@seat]}
          your_turn?={@seat == @state.turn}
          playable_indices={@playable_indices}
          play_tile={&send(self(), {:play_tile, &1})}
          mark_tile={&send(self(), {:mark_tile, &1, &2})}
          unmark_tile={&send(self(), {:unmark_tile, &1, &2})}
          hover={&send(self(), {:hover, &1})}
          hover_off={fn -> send(self(), :hover_off) end}
          selected_index={@selected_index} />
        <div class="auto-buttons game-bottom-element">
          <%= for {{name, desc, checked, _}, i} <- Enum.with_index(@state.players[@seat].auto_buttons) do %>
            <input id={"auto-button-" <> name} type="checkbox" class="auto-button" phx-click="auto_button_toggled" phx-value-name={name} phx-value-enabled={if checked do "true" else "false" end} checked={checked}>
            <label for={"auto-button-" <> name} title={desc} data-name={t(@lang, get_auto_button_name(@state.rules_ref, name))} tabindex={i}><%= Rules.get(@state.rules_ref, "auto_buttons", %{})[name]["display_name"] %></label>
          <% end %>
        </div>
        <div class="call-buttons-container">
          <%= for {called_tile, choices} <- @state.players[@seat].call_buttons do %>
            <%= if not Enum.empty?(choices) do %>
              <div class="call-buttons">
                <%= if called_tile != "saki" do %>
                  <%= if called_tile != nil do %>
                    <div class={["tile", Utils.strip_attrs(called_tile)]}></div>
                    <div class="call-button-separator"></div>
                  <% end %>
                  <%= for choice <- choices do %>
                    <button class="call-button" phx-cancellable-click="call_button_clicked" phx-value-tile={Utils.strip_attrs(called_tile)} phx-value-choice={Enum.join(Utils.strip_attrs(choice), ",")}>
                    <%= for tile <- choice do %>
                      <div class={["tile", Utils.strip_attrs(tile)]}></div>
                    <% end %>
                    </button>
                  <% end %>
                <% else %>
                  <%= for choice <- choices do %>
                    <button class="call-button" phx-cancellable-click="saki_card_clicked" phx-value-choice={choice}>
                    <%= for card <- choice do %>
                      <div class={["saki-card", @state.saki.version, card]}></div>
                    <% end %>
                    </button>
                  <% end %>
                <% end %>
              </div>
            <% end %>
          <% end %>
        </div>
      <% end %>
      <.live_component module={RiichiAdvancedWeb.RevealedTilesComponent}
        id="revealed-tiles"
        game_state={@game_state}
        viewer={@viewer}
        revealed_tiles={@revealed_tiles}
        max_revealed_tiles={@state.max_revealed_tiles}
        marking={@state.marking[@seat]} />
      <.live_component module={RiichiAdvancedWeb.ScryedTilesComponent}
        id="scryed-tiles"
        game_state={@game_state}
        viewer={@viewer}
        wall={@state.wall}
        wall_index={@state.wall_index}
        num_scryed_tiles={@state.players[@seat].num_scryed_tiles}
        named_scryed_tiles={Enum.map(@state.named_scryed_tiles, &GameState.from_named_tile(@state, %{seat: @seat}, &1))}
        marking={@state.marking[@seat]}
        :if={@state.players[@seat].num_scryed_tiles > 0 or not Enum.empty?(@state.named_scryed_tiles)} />
      <.live_component module={RiichiAdvancedWeb.DeclareYakuComponent}
        id="declare-yaku"
        game_state={@game_state}
        viewer={@viewer}
        yakus={Rules.get(@state.rules_ref, "declarable_yaku", [])}
        :if={@state.players[@seat].declared_yaku == []} />
      <div class="display-wall-hover game-bottom-element" :if={Rules.get(@state.rules_ref, "display_wall", false)} phx-click="noop"><%= t(@lang, "Show wall") %></div>
      <.live_component module={RiichiAdvancedWeb.DisplayWallComponent}
        id="display-wall"
        game_state={@game_state}
        viewer={@viewer}
        seat={@seat}
        kyoku={@state.kyoku}
        wall={@state.wall}
        dead_wall={@state.dead_wall}
        atop_wall={@state.atop_wall}
        wall_length={length(Rules.get(@state.rules_ref, "wall", []))}
        dice={@state.dice}
        dice_roll={Enum.sum(@state.dice)}
        wall_index={@state.wall_index}
        dead_wall_index={@state.dead_wall_index}
        revealed_tiles={@state.revealed_tiles}
        reserved_tiles={@state.reserved_tiles}
        drawn_reserved_tiles={@state.drawn_reserved_tiles}
        available_seats={@state.available_seats}
        :if={Rules.get(@state.rules_ref, "display_wall", false)} />
      <div class={["big-text"]} :if={@loading && Rules.has_key?(@state.rules_ref, "show_waits")}><%= t(@lang, "Loading...") %></div>
      <div class="display-am-hand-hover game-bottom-element" :if={Rules.get(@state.rules_ref, "show_nearest_american_hand", false)}></div>
      <div class="display-am-hand-container" :if={Rules.get(@state.rules_ref, "show_nearest_american_hand", false)}>
        <% open_definitions = Rules.get(@state.rules_ref, "open_win_definition", []) %>
        <%= for {am_match_definition, _shanten, arranged_hand} <- @state.players[@seat].cache.closest_american_hands do %>
          <div class="display-am-hand" :if={arranged_hand}>
            <%= for tile <- arranged_hand do %>
              <div class={Utils.get_tile_class(tile)}></div>
            <% end %>
            <%= if am_match_definition in open_definitions do %>
              <div class="display-am-hand-type"><%= t(@lang, "x") %></div>
            <% else %>
              <div class="display-am-hand-type"><%= t(@lang, "c") %></div>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class={["big-text"]} :if={@loading}><%= t(@lang, "Loading...") %></div>
      <%= if RiichiAdvanced.GameState.Debug.debug_status() or Rules.get(@state.rules_ref, "debug_status", false) do %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <div class="status-text" :for={status <- player.status}><%= status %></div>
          <div class="status-text" :for={{name, value} <- player.counters}><%= "#{name}: #{value}" %></div>
          <div class="status-text" :for={button_name <- player.buttons}><%= "[#{button_name}]" %></div>
        </div>
      <% else %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <%= for status <- player.status, status in Rules.get(@state.rules_ref, "shown_statuses_public", []) or (seat == @viewer and status in Rules.get(@state.rules_ref, "shown_statuses", [])) do %>
            <div class="status-text"><%= status %></div>
          <% end %>
          <%= for {name, value} <- player.counters, name in Rules.get(@state.rules_ref, "shown_statuses_public", []) or (seat == @viewer and name in Rules.get(@state.rules_ref, "shown_statuses", [])) do %>
            <div class="status-text"><%= "#{name}: #{value}" %></div>
          <% end %>
        </div>
      <% end %>
      <%= if @visible_waits != nil and @show_waits_index != nil and Rules.has_key?(@state.rules_ref, "show_waits") do %>
        <%= if Map.get(@visible_waits, @show_waits_index, :loading) == :loading do %>
          <div class="visible-waits-container">
            <div class="visible-waits visible-waits-loading">
              Calculating waits...
            </div>
          </div>
        <% else %>
          <% waits = Map.get(@visible_waits, @show_waits_index, []) %>
          <div class="visible-waits-container" :if={not Enum.empty?(waits)}>
            <% has_label = Enum.any?(waits, fn {_wait, _num, label} -> label != nil end) %>
            <div class={["visible-waits"] ++ if has_label do ["spaced"] else [] end}>
              <%= for {wait, num, label} <- waits do %>
                <div class="visible-wait">
                  <div class="visible-wait-num"><%= num %></div>
                  <div class="visible-wait-label" :if={label != nil}><%= label %></div>
                  <div class={Utils.get_tile_class(wait, 0, %{}, if num == 0 do ["inactive"] else [] end)}><%= Phoenix.HTML.raw RiichiAdvancedWeb.HandComponent.debug_tile(wait) %></div>
                </div>
              <% end %>
              &nbsp;=&nbsp;<%= waits |> Enum.map(fn {_wait, num, _label} -> num end) |> Enum.sum() %>
            </div>
          </div>
        <% end %>
      <% end %>
      <div class="tutorial-overlay" :if={@tutorial_state != nil}>
        <.live_component module={RiichiAdvancedWeb.TutorialOverlayComponent}
          id="tutorial-overlay"
          game_state={@game_state}
          ruleset={@ruleset}
          lang={@lang}
          waiting_for_click={@tutorial_state.waiting_for_click}
          play_scene={&send(self(), {:play_scene, &1})}
          await_click={&send(self(), {:await_click, &1})}
          force_event={&send(self(), {:force_event, &1, &2, &3})} />
      </div>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.CenterpieceStatusBarComponent}
          id="centerpiece-status-bar"
          tiles_left={length(@state.wall) - @state.wall_index}
          honba={@state.honba}
          riichi_sticks={Utils.try_integer(@state.pot / max(1, Rules.get(@state.rules_ref, "score_calculation", %{}) |> Map.get("riichi_value", 1)))}
          display_riichi_sticks={@display_riichi_sticks}
          display_honba={@display_honba} />
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" log_button={true} lang={@lang} />
      </div>
      <.live_component module={RiichiAdvancedWeb.RulesPopoverComponent} id="rules-popover" rules_text={@state.rules_text} rules_text_order={@state.rules_text_order} lang={@lang} />
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} messages_state={@messages_state} lang={@lang} />
      <div class="ruleset game-bottom-element">
        <div class="ruleset-text"><%= t(@lang, "Ruleset:") %></div>
        <textarea readonly><%= Rules.get(@state.rules_ref, :ruleset_json) %></textarea>
      </div>
    </div>
    """
  end

  defp get_button_name(_rules_ref, "skip"), do: "Skip"
  defp get_button_name(rules_ref, name) do
    buttons = Rules.get(rules_ref, "buttons", %{})
    get_in(buttons[name]["display_name"]) || "Button"
  end
  defp get_auto_button_name(rules_ref, name) do
    auto_buttons = Rules.get(rules_ref, "auto_buttons", %{})
    get_in(auto_buttons[name]["display_name"]) || ""
  end

end