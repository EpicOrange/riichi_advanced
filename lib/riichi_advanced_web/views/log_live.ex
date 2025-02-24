defmodule RiichiAdvancedWeb.LogLive do
  alias RiichiAdvanced.GameState.Game, as: Game
  alias RiichiAdvanced.GameState.Choice, as: Choice
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:log_id, params["log_id"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:game_state, nil)
    |> assign(:log_control_state, nil)
    |> assign(:messages, [])
    |> assign(:state, %Game{})
    |> assign(:log, nil)
    |> assign(:log_json, "")
    |> assign(:seat, :east)
    |> assign(:shimocha, :south)
    |> assign(:toimen, :west)
    |> assign(:kamicha, :north)
    |> assign(:viewer, :spectator)
    |> assign(:display_riichi_sticks, false)
    |> assign(:display_honba, false)
    |> assign(:loading, true)
    |> assign(:marking, false)
    |> assign(:revealed_tiles, nil)

    # liveviews mount twice
    if socket.root_pid != nil do

      # read in the log
      log_json = case File.read(Application.app_dir(:riichi_advanced, "/priv/static/logs/#{socket.assigns.log_id <> ".json"}")) do
        {:ok, log_json} -> log_json
        {:error, _err}  -> nil
      end

      # decode the log json
      log = try do
        case Jason.decode(log_json) do
          {:ok, log} -> log
          {:error, err} ->
            IO.puts("WARNING: Failed to read log file at character position #{err.position}!\nRemember that trailing commas are invalid!")
            %{}
        end
      rescue
        ArgumentError -> 
          IO.puts("WARNING: Log \"#{socket.assigns.log_id}\" doesn't exist!")
          %{}
      end

      ruleset = Map.get(log["rules"], "ruleset", "riichi")
      mods = Map.get(log["rules"], "mods", [])

      socket = socket
      |> assign(:ruleset, ruleset)
      |> assign(:room_code, Ecto.UUID.generate())
      |> assign(:log, log)
      |> assign(:log_json, log_json)

      if ruleset == "custom" and Map.has_key?(log["rules"], "ruleset_json") do
        # for custom logs, fetch the ruleset from the log and load it into ets before starting log supervisor
        RiichiAdvanced.ETSCache.put(socket.assigns.room_code, log["rules"]["ruleset_json"], :cache_rulesets)
        RiichiAdvanced.ETSCache.put(socket.assigns.room_code <> "_walker", log["rules"]["ruleset_json"], :cache_rulesets)
      end

      # start a new game process
      log_spec = {RiichiAdvanced.LogSupervisor, room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, mods: mods, name: Utils.via_registry("log", socket.assigns.ruleset, socket.assigns.room_code)}
      {game_state, log_control_state} = case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, log_spec) do
        {:ok, _pid} ->
          IO.puts("Starting log session #{socket.assigns.room_code}")
          [{game_state, _}] = Utils.registry_lookup("game_state", socket.assigns.ruleset, socket.assigns.room_code)
          GenServer.cast(game_state, {:initialize_game, Enum.at(log["kyokus"], 0)})
          GenServer.call(game_state, {:put_log_seeking_mode, true})
          [{log_control_state, _}] = Utils.registry_lookup("log_control_state", socket.assigns.ruleset, socket.assigns.room_code)
          GenServer.cast(log_control_state, {:put_log, log})
          GenServer.cast(log_control_state, {:start_walk, 0, 100})
          {game_state, log_control_state}
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting log session #{socket.assigns.room_code}")
          IO.inspect(error)
          {nil, nil}
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started log session #{socket.assigns.room_code}")
          [{game_state, _}] = Utils.registry_lookup("game_state", socket.assigns.ruleset, socket.assigns.room_code)
          [{log_control_state, _}] = Utils.registry_lookup("log_control_state", socket.assigns.ruleset, socket.assigns.room_code)
          {game_state, log_control_state}
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.room_code)


      # init a new player and get the current state
      {state, seat, spectator} = GenServer.call(game_state, {:spectate, socket.assigns.session_id})

      socket = socket
      |> assign(:game_state, game_state)
      |> assign(:log_control_state, log_control_state)
      |> assign(:state, state)
      |> assign(:seat, seat)
      |> assign(:viewer, if spectator do :spectator else seat end)
      |> assign(:display_riichi_sticks, Map.get(state.rules, "display_riichi_sticks"))
      |> assign(:display_honba, Map.get(state.rules, "display_honba"))
      |> assign(:loading, false)
      |> assign(:marking, false)

      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          %{text: "Viewing log for a"},
          %{bold: true, text: socket.assigns.ruleset},
          %{text: "game"},
        ] ++ if state.mods != nil and not Enum.empty?(state.mods) do
          [%{text: "with mods"}] ++ Enum.map(state.mods, fn mod -> %{bold: true, text: ModLoader.get_mod_name(mod)} end)
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
    <div id="container" phx-hook="ClickListener">
      <%= if Map.has_key?(@state.rules, "custom_style") do %>
        <.live_component module={RiichiAdvancedWeb.CustomStyleComponent} id="custom-tiles" style={@state.rules["custom_style"]}/>
      <% end %>
      <.live_component module={RiichiAdvancedWeb.HandComponent}
        id={"hand #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        revealed?={true}
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
        called_tile={nil}
        call_choice={nil}
        play_tile={fn _ix -> :ok end}
        hover={fn _ix -> :ok end}
        hover_off={fn _ix -> :ok end}
        reindex_hand={fn _from, _to -> :ok end}
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
        dead_hand_buttons={false}
        display_round_marker={Map.get(@state.rules, "display_round_marker", true)}
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
        revealed_tiles={@state.revealed_tiles}
        reserved_tiles={@state.reserved_tiles}
        drawn_reserved_tiles={@state.drawn_reserved_tiles}
        available_seats={@state.available_seats}
        :if={Map.get(@state.rules, "display_wall", false)} />
      <.live_component module={RiichiAdvancedWeb.LogControlComponent}
        id="log-control"
        state={@state}
        log={@log}
        log_control_state={@log_control_state} />
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

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}")
    {:noreply, socket}
  end

  def handle_event("log", _assigns, socket) do
    # log button pressed
    socket = push_event(socket, "copy-log", %{log: socket.assigns.log_json})
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("button_clicked", %{"name" => name}, socket) do
    GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, name})
    {:noreply, socket}
  end

  def handle_event("auto_button_toggled", %{"name" => name, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.game_state, {:toggle_auto_button, socket.assigns.seat, name, not enabled})
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"tile" => called_tile, "name" => call_name, "choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Utils.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, choice: %Choice{ name: call_name, chosen_call_choice: call_choice, chosen_called_tile: Utils.to_tile(called_tile) }}})
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"name" => call_name, "choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Utils.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, choice: %Choice{ name: call_name, chosen_call_choice: call_choice, chosen_called_tile: nil }}})
    {:noreply, socket}
  end

  def handle_event("saki_card_clicked", %{"choice" => choice}, socket) do
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, choice: choice}})
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
    GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, :east})
    GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, :south})
    GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, :west})
    GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, :north})
    socket = assign(socket, :timer, 0)
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

      socket = assign(socket, :state, state)
      |> assign(:revealed_tiles, RiichiAdvanced.GameState.get_revealed_tiles(state))
      |> assign(:marking, RiichiAdvanced.GameState.Marking.needs_marking?(state, socket.assigns.seat))

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
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", just_called: false)
    {:noreply, socket}
  end

  def handle_info({:reset_draw_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", just_drew: false)
    {:noreply, socket}
  end

  def handle_info({:reset_discard_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.PondComponent, id: "pond #{relative_seat}", just_discarded: false)
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

end
