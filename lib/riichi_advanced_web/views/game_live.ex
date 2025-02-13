defmodule RiichiAdvancedWeb.GameLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Game, as: Game
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:room_code, params["room_code"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:seat_param, params["seat"])
    |> assign(:tutorial_sequence_name, params["sequence"])
    |> assign(:game_state, nil)
    |> assign(:messages, [])
    |> assign(:state, %Game{})
    |> assign(:seat, :east)
    |> assign(:shimocha, nil)
    |> assign(:toimen, nil)
    |> assign(:kamicha, nil)
    |> assign(:viewer, :spectator)
    |> assign(:display_riichi_sticks, false)
    |> assign(:display_honba, false)
    |> assign(:loading, true)
    |> assign(:marking, false)
    |> assign(:visible_waits, nil)
    |> assign(:revealed_tiles, nil)
    |> assign(:visible_waits_hand, nil)
    |> assign(:show_waits_index, nil)
    |> assign(:hovered_called_tile, nil)
    |> assign(:hovered_call_choice, nil)
    |> assign(:playable_indices, [])
    |> assign(:preplayed_index, nil)
    |> assign(:hide_buttons, false) # used to hide buttons on the client side after clicking one
    # used for tutorials
    |> assign(:last_forced_events, nil)
    |> assign(:next_tutorial_scenes, nil)
    |> assign(:waiting_for_click, false)
    |> assign(:return_to_editor, false)

    socket = if socket.assigns.tutorial_sequence_name != nil do
      assign(socket, :room_code, Ecto.UUID.generate())
    else socket end

    last_mods = case RiichiAdvanced.ETSCache.get({socket.assigns.ruleset, socket.assigns.room_code}, [], :cache_mods) do
      [mods] -> mods
      []     -> []
    end
    last_config = case RiichiAdvanced.ETSCache.get({socket.assigns.ruleset, socket.assigns.room_code}, nil, :cache_configs) do
      [config] -> config
      _        -> nil
    end

    # liveviews mount twice; we only want to init a new player on the second mount
    if socket.root_pid != nil do
      # check if we're a tutorial; if so, load its config instead
      socket = setup_tutorial(socket)
      mods = if Map.has_key?(socket.assigns, :tutorial_sequence) do Map.get(socket.assigns.tutorial_sequence, "mods", []) else last_mods end
      config = if Map.has_key?(socket.assigns, :tutorial_sequence) do Map.get(socket.assigns.tutorial_sequence, "config", nil) else last_config end
      config = if is_map(config) do Jason.encode!(config) else config end

      # start a new game process, if it doesn't exist already
      game_spec = {RiichiAdvanced.GameSupervisor, room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, mods: mods, config: config, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", socket.assigns.ruleset, socket.assigns.room_code)}}}
      game_state = case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec) do
        {:ok, _pid} ->
          IO.puts("Starting game session #{socket.assigns.room_code}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.room_code))
          GenServer.cast(game_state, {:initialize_game, nil})
          game_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting game session #{socket.assigns.room_code}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started game session #{socket.assigns.room_code}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.room_code))
          game_state
      end

      # block events if we're a tutorial
      if Map.has_key?(socket.assigns, :tutorial_sequence) do
        GenServer.call(game_state, {:force_event, [], true})
      end

      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.room_code)
      # init a new player and get the current state
      {state, seat, spectator} = GenServer.call(game_state, {:new_player, socket})
      socket = socket
      |> assign(:game_state, game_state)
      |> assign(:state, state)
      |> assign(:seat, seat)
      |> assign(:viewer, if spectator do :spectator else seat end)
      |> assign(:display_riichi_sticks, Map.get(state.rules, "display_riichi_sticks", false))
      |> assign(:display_honba, Map.get(state.rules, "display_honba", false))
      |> assign(:loading, false)
      |> assign(:marking, RiichiAdvanced.GameState.Marking.needs_marking?(state, seat))

      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          %{text: "Entered a "},
          %{bold: true, text: socket.assigns.ruleset},
          %{text: "game, room code"},
          %{bold: true, text: socket.assigns.room_code}
        ] ++ if state.mods != nil and not Enum.empty?(state.mods) do
          [%{text: "with mods"}] ++ Enum.map(state.mods, fn mod -> %{bold: true, text: mod} end)
        else [] end})
        socket
      else socket end
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div id="container" class={[@ruleset == "minefield" && "minefield"]} phx-hook="ClickListener">
      <%= if Map.has_key?(@state.rules, "tile_images") do %>
        <.live_component module={RiichiAdvancedWeb.CustomTilesComponent} id="custom-tiles" tiles={@state.rules["tile_images"]}/>
      <% end %>
      <input id="mobile-zoom-checkbox" type="checkbox" class="mobile-zoom-checkbox" phx-update="ignore">
      <label for="mobile-zoom-checkbox"></label>
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
        preplayed_index={@preplayed_index}
        dead_hand_buttons={Map.get(@state.rules, "dead_hand_buttons", false)}
        dead_hand?={"dead_hand" in @state.players[seat].status}
        play_tile={&send(self(), {:play_tile, &1})}
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
        four_rows?={Map.get(@state.rules, "four_rows_discards", false)}
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
        display_round_marker={Map.get(@state.rules, "display_round_marker", true)}
        ai_thinking={@state.players[seat].ai_thinking}
        :for={{seat, player} <- @state.players} />
      <.live_component module={RiichiAdvancedWeb.BigTextComponent}
        id={"big-text #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        seat={seat}
        relative_seat={Utils.get_relative_seat(@seat, seat)}
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
        riichi_sticks={Utils.try_integer(@state.pot / max(1, (get_in(@state.rules["score_calculation"]["riichi_value"]) || 1)))}
        riichi={Map.new(@state.players, fn {seat, player} -> {seat, player.riichi_stick} end)}
        score={Map.new(@state.players, fn {seat, player} -> {seat, player.score} end)}
        display_riichi_sticks={@display_riichi_sticks}
        display_honba={@display_honba}
        score_e_notation={Map.get(@state.rules, "score_e_notation", false)}
        available_seats={@state.available_seats}
        is_bot={Map.new([:east, :south, :west, :north], fn seat -> {seat, is_pid(Map.get(@state, seat))} end)} />
      <%= if @state.visible_screen != nil do %>
        <.live_component module={RiichiAdvancedWeb.WinWindowComponent} id="win-window" game_state={@game_state} seat={@seat} winner={Map.get(@state.winners, Enum.at(@state.winner_seats, @state.winner_index), nil)} timer={@state.timer} visible_screen={@state.visible_screen}/>
        <.live_component module={RiichiAdvancedWeb.ScoreWindowComponent} id="score-window" game_state={@game_state} seat={@seat} players={@state.players} winners={@state.winners} delta_scores={@state.delta_scores} delta_scores_reason={@state.delta_scores_reason} timer={@state.timer} visible_screen={@state.visible_screen} available_seats={@state.available_seats}/>
        <.live_component module={RiichiAdvancedWeb.EndWindowComponent} id="end-window" game_state={@game_state} seat={@seat} players={@state.players} visible_screen={@state.visible_screen}/>
      <% end %>
      <%= if @state.error != nil do %>
        <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@game_state} seat={@seat} players={@state.players} error={@state.error}/>
      <% end %>
      <%= if @viewer != :spectator do %>
        <div class="buttons" :if={not @hide_buttons and @state.players[@seat].declared_yaku != []}>
          <%= if @marking and not Enum.empty?(@state.marking[@seat]) do %>
            <button class="button" phx-cancellable-click="clear_marked_objects" :if={RiichiAdvanced.GameState.Marking.num_objects_needed(@state.marking[@seat]) > 1}>Clear</button>
            <button class="button" phx-cancellable-click="cancel_marked_objects" :if={Keyword.get(@state.marking[@seat], :cancellable)}>Cancel</button>
          <% else %>
            <%= if not Enum.empty?(@state.players[@seat].call_buttons) do %>
              <%= if Enum.all?(@state.players[@seat].call_buttons, fn {called_tile, _choices} -> called_tile != "saki" end) do %>
                <button class="button" phx-cancellable-click="cancel_call_buttons">Cancel</button>
              <% end %>
            <% else %>
              <%= for {button, button_name} <- Enum.map(@state.players[@seat].buttons, fn button -> {button, if button == "skip" do "Skip" else Map.get(@state.rules["buttons"][button], "display_name", "Button") end} end) do %>
                <button class={["button", String.length(button_name) >= 40 && "small-text"]} phx-cancellable-click="button_clicked" phx-hover="hover_button" phx-hover-off="hover_off" phx-value-name={button}><%= button_name %></button>
              <% end %>
            <% end %>
          <% end %>
        </div>
        <div class="auto-buttons">
          <%= for {name, desc, checked} <- @state.players[@seat].auto_buttons do %>
            <input id={"auto-button-" <> name} type="checkbox" class="auto-button" phx-click="auto_button_toggled" phx-value-name={name} phx-value-enabled={if checked do "true" else "false" end} checked={checked}>
            <label for={"auto-button-" <> name} title={desc}><%= @state.rules["auto_buttons"][name]["display_name"] %></label>
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
        marking={@state.marking[@seat]}
        :if={@state.players[@seat].num_scryed_tiles > 0} />
      <.live_component module={RiichiAdvancedWeb.DeclareYakuComponent}
        id="declare-yaku"
        game_state={@game_state}
        viewer={@viewer}
        yakus={Map.get(@state.rules, "declarable_yaku", [])}
        :if={@state.players[@seat].declared_yaku == []} />
      <div class="display-wall-hover" :if={Map.get(@state.rules, "display_wall", false)}></div>
      <.live_component module={RiichiAdvancedWeb.DisplayWallComponent}
        id="display-wall"
        game_state={@game_state}
        viewer={@viewer}
        seat={@seat}
        kyoku={@state.kyoku}
        wall={@state.wall}
        dead_wall={@state.dead_wall}
        wall_length={length(Map.get(@state.rules, "wall", []))}
        die1={@state.die1}
        die2={@state.die2}
        dice_roll={@state.die1 + @state.die2}
        wall_index={@state.wall_index}
        dead_wall_index={@state.dead_wall_index}
        revealed_tiles={@state.revealed_tiles}
        reserved_tiles={@state.reserved_tiles}
        drawn_reserved_tiles={@state.drawn_reserved_tiles}
        available_seats={@state.available_seats}
        :if={Map.get(@state.rules, "display_wall", false)} />
      <div class={["big-text"]} :if={@loading}>Loading...</div>
      <div class="display-am-hand-hover" :if={Map.get(@state.rules, "show_nearest_american_hand", false)}></div>
      <div class="display-am-hand-container" :if={Map.get(@state.rules, "show_nearest_american_hand", false)}>
        <%= for {_am_match_definition, _shanten, arranged_hand} <- @state.players[@seat].cache.closest_american_hands do %>
          <div class="display-am-hand" :if={arranged_hand})>
            <%= for tile <- arranged_hand do %>
              <div class={Utils.get_tile_class(tile)}></div>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class={["big-text"]} :if={@loading}>Loading...</div>
      <%= if RiichiAdvanced.GameState.Debug.debug_status() or Map.get(@state.rules, "debug_status", false) do %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <div class="status-text" :for={status <- player.status}><%= status %></div>
          <div class="status-text" :for={{name, value} <- player.counters}><%= "#{name}: #{value}" %></div>
          <div class="status-text" :for={button_name <- player.buttons}><%= "[#{button_name}]" %></div>
        </div>
      <% else %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <%= for status <- player.status, status in Map.get(@state.rules, "shown_statuses_public", []) or (seat == @viewer and status in Map.get(@state.rules, "shown_statuses", [])) do %>
            <div class="status-text"><%= status %></div>
          <% end %>
          <%= for {name, value} <- player.counters, name in Map.get(@state.rules, "shown_statuses_public", []) or (seat == @viewer and name in Map.get(@state.rules, "shown_statuses", [])) do %>
            <div class="status-text"><%= "#{name}: #{value}" %></div>
          <% end %>
        </div>
      <% end %>
      <%= if @visible_waits != nil and @show_waits_index != nil and Map.get(@visible_waits, @show_waits_index, :loading) not in [:loading, %{}] do %>
        <div class="visible-waits-container">
          <div class="visible-waits">
            <%= for {wait, num} <- Enum.sort_by(Map.get(@visible_waits, @show_waits_index, %{}), fn {wait, _num} -> Constants.sort_value(wait) end) do %>
              <div class="visible-wait">
                <div class="visible-wait-num"><%= num %></div>
                <div class={Utils.get_tile_class(wait, 0)}></div>
              </div>
            <% end %>
            &nbsp;=&nbsp;<%= Map.get(@visible_waits, @show_waits_index, %{}) |> Enum.map(fn {_wait, num} -> num end) |> Enum.sum() %>
          </div>
        </div>
      <% end %>
      <div class="tutorial-overlay" :if={@tutorial_sequence_name != nil}>
        <.live_component module={RiichiAdvancedWeb.TutorialOverlayComponent}
          id="tutorial-overlay"
          game_state={@game_state}
          ruleset={@ruleset}
          waiting_for_click={@waiting_for_click}
          play_scene={&send(self(), {:play_scene, &1})}
          await_click={&send(self(), {:await_click, &1})}
          force_event={&send(self(), {:force_event, &1, &2, &3})} />
      </div>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.CenterpieceStatusBarComponent}
          id="centerpiece-status-bar"
          tiles_left={length(@state.wall) - @state.wall_index}
          honba={@state.honba}
          riichi_sticks={Utils.try_integer(@state.pot / max(1, (get_in(@state.rules["score_calculation"]["riichi_value"]) || 1)))}
          display_riichi_sticks={@display_riichi_sticks}
          display_honba={@display_honba} />
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" log_button={true} />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def skip_or_discard_draw(socket) do
    # do a clientside can_discard check here
    if RiichiAdvanced.GameState.Actions.can_discard(socket.assigns.state, socket.assigns.seat, true) do
      # if draw, discard it
      # otherwise, if buttons, skip
      player = socket.assigns.state.players[socket.assigns.seat]
      if socket.assigns.seat == socket.assigns.state.turn and not Enum.empty?(player.draw) do
        send(self(), {:play_tile, length(player.hand)})
      else
        if "skip" in player.buttons do
          GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, "skip"})
        end
      end
    end
  end

  def get_visible_waits(socket, index) do
    hand = socket.assigns.state.players[socket.assigns.seat].hand
    socket = if hand != socket.assigns.visible_waits_hand do
      socket
      |> assign(:visible_waits, nil)
      |> assign(:visible_waits_hand, nil)
    else socket end
    visible_waits = socket.assigns.visible_waits || %{}
    if not Map.has_key?(visible_waits, index) do
      # async call; gets handled below in :set_visible_waits
      GenServer.cast(socket.assigns.game_state, {:get_visible_waits, self(), socket.assigns.seat, index})
      assign(socket, :visible_waits, Map.put(visible_waits, index, :loading))
    else socket end
  end

  defp setup_tutorial(socket) do
    if Map.get(socket.assigns, :tutorial_sequence_name) != nil do
      {sequence_json, return_to_editor} = 
        case File.read(Application.app_dir(:riichi_advanced, "/priv/static/tutorials/#{socket.assigns.tutorial_sequence_name}.json")) do
          {:ok, sequence_json} -> {sequence_json, false}
          {:error, _err}       ->
            # try loading custom ruleset from cache
            case RiichiAdvanced.ETSCache.get({socket.assigns.ruleset, socket.assigns.tutorial_sequence_name}, [], :cache_sequences) do
              [sequence_json] -> {sequence_json, true}
              _ -> {"{}", true}
            end
        end

      socket = assign(socket, :return_to_editor, return_to_editor)

      # decode the sequence json
      tutorial_sequence = try do
        case Jason.decode(RiichiAdvanced.ModLoader.strip_comments(sequence_json)) do
          {:ok, sequence} -> sequence
          {:error, err} ->
            IO.puts("Erroring json:")
            IO.inspect(sequence_json)
            IO.puts("WARNING: Failed to read sequence file at character position #{err.position}!\nRemember that trailing commas are invalid!")
            %{}
        end
      rescue
        ArgumentError -> 
          IO.puts("WARNING: Sequence \"#{socket.assigns.tutorial_sequence_name}\" doesn't exist!")
          %{}
      end

      socket = assign(socket, :tutorial_sequence, tutorial_sequence)

      actions = Map.get(tutorial_sequence["scenes"], "start", [])
      send_update(RiichiAdvancedWeb.TutorialOverlayComponent, id: "tutorial-overlay", actions: actions)

      socket
    else socket end
  end

  defp trigger_next_tutorial_scene(socket, choice) do
    next_tutorial_scene = if is_integer(choice) do Enum.at(socket.assigns.next_tutorial_scenes, choice) else choice end
    actions = if next_tutorial_scene == :resume do
      :resume
    else
      Map.get(socket.assigns.tutorial_sequence["scenes"], next_tutorial_scene, [])
    end
    GenServer.call(socket.assigns.game_state, {:force_event, [], true}) # first block events
    send_update(RiichiAdvancedWeb.TutorialOverlayComponent, id: "tutorial-overlay", actions: actions)
    socket = assign(socket, :next_tutorial_scenes, nil)
    socket
  end

  defp navigate_back(socket) do
    if Map.has_key?(socket.assigns, :tutorial_sequence) do
      if socket.assigns.return_to_editor do
        push_navigate(socket, to: ~p"/tutorial_creator?ruleset=#{socket.assigns.ruleset}&seat=#{socket.assigns.seat_param}&tutorial_id=#{socket.assigns.tutorial_sequence_name}&nickname=#{socket.assigns.nickname}")
      else
        push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}")
      end
    else
      push_navigate(socket, to: ~p"/room/#{socket.assigns.ruleset}/#{socket.assigns.room_code}?nickname=#{socket.assigns.nickname}")
    end
  end

  def handle_event("back", _assigns, socket) do
    {:noreply, navigate_back(socket)}
  end

  def handle_event("log", _assigns, socket) do
    log = GenServer.call(socket.assigns.game_state, :get_log)
    socket = push_event(socket, "copy-log", %{log: log})
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    if not Map.has_key?(socket.assigns, :tutorial_sequence) do
      skip_or_discard_draw(socket)
    end
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    if not Map.has_key?(socket.assigns, :tutorial_sequence) do
      skip_or_discard_draw(socket)
    end
    {:noreply, socket}
  end

  def handle_event("button_clicked", %{"name" => name}, socket) do
    GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, name})
    socket = assign(socket, :hovered_called_tile, nil)
    socket = assign(socket, :hovered_call_choice, nil)
    socket = if not Map.has_key?(socket.assigns, :tutorial_sequence) do
      assign(socket, :hide_buttons, true)
    else socket end
    {:noreply, socket}
  end

  def handle_event("auto_button_toggled", %{"name" => name, "enabled" => enabled}, socket) do
    if not Map.has_key?(socket.assigns, :tutorial_sequence) do
      enabled = enabled == "true"
      GenServer.cast(socket.assigns.game_state, {:toggle_auto_button, socket.assigns.seat, name, not enabled})
    end
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"tile" => called_tile, "choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Utils.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:press_call_button, socket.assigns.seat, call_choice, Utils.to_tile(called_tile)})
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Utils.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:press_call_button, socket.assigns.seat, call_choice, nil})
    {:noreply, socket}
  end

  def handle_event("saki_card_clicked", %{"choice" => choice}, socket) do
    GenServer.cast(socket.assigns.game_state, {:press_saki_card, socket.assigns.seat, choice})
    {:noreply, socket}
  end

  def handle_event("cancel_call_buttons", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, {:cancel_call_buttons, socket.assigns.seat})
    {:noreply, socket}
  end

  def handle_event("clear_marked_objects", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, {:clear_marked_objects, socket.assigns.seat})
    {:noreply, socket}
  end

  def handle_event("cancel_marked_objects", _assigns, socket) do
    GenServer.cast(socket.assigns.game_state, {:reset_marking, socket.assigns.seat})
    {:noreply, socket}
  end

  def handle_event("ready_for_next_round", _assigns, socket) do
    if socket.assigns.seat != :spectator do
      GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, socket.assigns.seat})
    end
    socket = assign(socket, :timer, 0)
    {:noreply, socket}
  end

  def handle_event("hover_button", %{"name" => name}, socket) do
    player = socket.assigns.state.players[socket.assigns.viewer]
    {called_tile, call_choice} = case Map.get(player.button_choices, name, nil) do
      {:call, choices} ->
        if choices != nil do
          choices = choices
          |> Enum.filter(fn {_called_tile, call_choice} -> not Enum.empty?(call_choice) end)
          case choices do
            [{called_tile, [call_choice]}] -> {called_tile, call_choice}
            _                              -> {nil, nil}
          end
        else {nil, nil} end
      _ -> {nil, nil}
    end
    socket = assign(socket, :hovered_called_tile, called_tile)
    is_upgrade = get_in(socket.assigns.state.rules, ["buttons", name, "upgrades"]) != nil
    socket = assign(socket, :hovered_call_choice, if is_upgrade do nil else call_choice end)
    {:noreply, socket}
  end

  def handle_event("hover_off", _assigns, socket) do
    socket = assign(socket, :hovered_called_tile, nil)
    socket = assign(socket, :hovered_call_choice, nil)
    {:noreply, socket}
  end

  def handle_event("declare_dead_hand", %{"seat" => seat}, socket) do
    if socket.assigns.seat == socket.assigns.state.turn do
      dead_seat = case seat do
        "east"  -> :east
        "south" -> :south
        "west"  -> :west
        "north" -> :north
      end
      GenServer.cast(socket.assigns.game_state, {:declare_dead_hand, socket.assigns.seat, dead_seat})
    end
    {:noreply, socket}
  end

  def handle_event("tutorial_overlay_clicked", _assigns, socket) do
    if socket.assigns.waiting_for_click do
      socket = assign(socket, :waiting_for_click, false)
      if Debug.debug_tutorial() do
        IO.puts("\nresuming tutorial actions due to click\n")
      end
      socket = trigger_next_tutorial_scene(socket, 0)
      {:noreply, socket}
    else {:noreply, socket} end
  end

  def handle_info(:back, socket) do
    {:noreply, navigate_back(socket)}
  end

  def handle_info({:play_tile, index}, socket) do
    if socket.assigns.seat == socket.assigns.state.turn do
      socket = assign(socket, :visible_waits, %{})
      socket = assign(socket, :show_waits_index, nil)
      socket = if not Map.has_key?(socket.assigns, :tutorial_sequence) do
        assign(socket, :preplayed_index, index)
      else socket end
      GenServer.cast(socket.assigns.game_state, {:play_tile, socket.assigns.seat, index})
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:hover, index}, socket) do
    socket = get_visible_waits(socket, index)
    socket = assign(socket, :show_waits_index, index)
    {:noreply, socket}
  end

  def handle_info(:hover_off, socket) do
    socket = assign(socket, :show_waits_index, nil)
    {:noreply, socket}
  end

  def handle_info({:play_scene, next_scene}, socket) do
    socket = trigger_next_tutorial_scene(socket, next_scene)
    |> IO.inspect()
    {:noreply, socket}
  end

  def handle_info({:await_click, next_scene}, socket) do
    socket = assign(socket, :next_tutorial_scenes, [next_scene])
    socket = assign(socket, :waiting_for_click, true)
    {:noreply, socket}
  end

  def handle_info({:force_event, next_scenes, events, blocking}, socket) do
    GenServer.call(socket.assigns.game_state, {:force_event, events, blocking})
    if Debug.debug_tutorial() do
      IO.puts("#{if blocking do "Forcing" else "Awaiting" end} events #{inspect(events)}")
    end
    socket = assign(socket, :last_forced_events, events)
    socket = assign(socket, :next_tutorial_scenes, next_scenes)
    {:noreply, socket}
  end

  def handle_info({:reindex_hand, from, to}, socket) do
    GenServer.cast(socket.assigns.game_state, {:reindex_hand, socket.assigns.seat, from, to})
    socket = assign(socket, :visible_waits, %{})
    socket = assign(socket, :show_waits_index, nil)
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) do
      # animate new calls
      num_calls_before = Map.new(socket.assigns.state.players, fn {seat, player} -> {seat, length(player.calls)} end)
      num_calls_after = Map.new(state.players, fn {seat, player} -> {seat, length(player.calls)} end)
      Enum.each(Map.keys(num_calls_before), fn seat ->
        if num_calls_after[seat] > num_calls_before[seat] do
          relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
          send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", num_new_calls: num_calls_after[seat] - num_calls_before[seat])
        end
      end)

      # animate played tiles
      Enum.each(state.players, fn {seat, player} ->
        if player.last_discard != nil do
          {tile, index} = player.last_discard
          relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
          send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", hand: player.hand ++ player.draw, played_tile: tile, played_tile_index: index)
        end
      end)

      # get next tutorial scene
      socket = if Map.has_key?(socket.assigns, :tutorial_sequence) do
        if socket.assigns.next_tutorial_scenes != nil and not socket.assigns.waiting_for_click and state.forced_events == [] and state.last_event in socket.assigns.last_forced_events do
          if Debug.debug_tutorial() do
            IO.puts("\nresuming tutorial actions due to forced_events == [] and last event == #{inspect(state.last_event)}\n")
          end
          i = Enum.find_index(socket.assigns.last_forced_events, & &1 == state.last_event)
          trigger_next_tutorial_scene(socket, i)
        else socket end
      else socket end

      socket = socket
      |> assign(:state, state)
      |> assign(:playable_indices, state.players[socket.assigns.seat].cache.playable_indices)
      |> assign(:preplayed_index, nil)
      |> assign(:revealed_tiles, RiichiAdvanced.GameState.get_revealed_tiles(state))
      |> assign(:marking, RiichiAdvanced.GameState.Marking.needs_marking?(state, socket.assigns.seat))
      |> assign(:hide_buttons, false)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "play_sound", payload: %{"seat" => seat, "path" => path}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and (seat == nil or seat == socket.assigns.viewer) do
      socket = push_event(socket, "play-sound", %{path: path})
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:reset_hand_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", hand: socket.assigns.state.players[seat].hand, played_tile: nil, played_tile_index: nil)
    {:noreply, socket}
  end

  def handle_info({:reset_call_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", just_called: nil, just_upgraded: nil, just_called_flower: nil)
    {:noreply, socket}
  end

  def handle_info({:reset_draw_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", just_drew: false, hand: socket.assigns.state.players[seat].hand, played_tile: nil, played_tile_index: nil)
    {:noreply, socket}
  end

  def handle_info({:reset_discard_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.PondComponent, id: "pond #{relative_seat}", just_discarded: false)
    {:noreply, socket}
  end

  def handle_info({:set_visible_waits, hand, index, waits}, socket) do
    socket = socket
    |> assign(:visible_waits, Map.put(socket.assigns.visible_waits, index, waits))
    |> assign(:visible_waits_hand, hand)
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

end
