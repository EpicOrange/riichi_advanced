defmodule RiichiAdvancedWeb.LogLive do
  use RiichiAdvancedWeb, :live_view

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:log_id, params["id"])
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
      |> assign(:session_id, "log") # debug
      # |> assign(:session_id, socket.id)
      |> assign(:log, log)
      |> assign(:log_json, log_json)

      # start a new game process
      log_spec = {RiichiAdvanced.LogSupervisor, session_id: socket.assigns.session_id, ruleset: socket.assigns.ruleset, mods: mods, name: {:via, Registry, {:game_registry, Utils.to_registry_name("log", socket.assigns.ruleset, socket.assigns.session_id)}}}
      {game_state, log_control_state} = case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, log_spec) do
        {:ok, _pid} ->
          IO.puts("Starting log session #{socket.assigns.session_id}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.session_id))
          GenServer.cast(game_state, {:initialize_game, Enum.at(log["kyokus"], 0)})
          GenServer.call(game_state, {:put_log_seeking_mode, true})
          [{log_control_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("log_control_state", socket.assigns.ruleset, socket.assigns.session_id))
          GenServer.cast(log_control_state, {:put_log, log})
          GenServer.cast(log_control_state, {:start_walk, 0, 100})
          {game_state, log_control_state}
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting log session #{socket.assigns.session_id}")
          IO.inspect(error)
          {nil, nil}
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started log session #{socket.assigns.session_id}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.session_id))
          [{log_control_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("log_control_state", socket.assigns.ruleset, socket.assigns.session_id))
          {game_state, log_control_state}
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.session_id)


      # init a new player and get the current state
      [state, seat, shimocha, toimen, kamicha, spectator] = GenServer.call(game_state, {:spectate, socket})

      socket = socket
      |> assign(:game_state, game_state)
      |> assign(:log_control_state, log_control_state)
      |> assign(:state, state)
      |> assign(:seat, seat)
      |> assign(:shimocha, shimocha)
      |> assign(:toimen, toimen)
      |> assign(:kamicha, kamicha)
      |> assign(:viewer, if spectator do :spectator else seat end)
      |> assign(:display_riichi_sticks, Map.has_key?(state.rules, "display_riichi_sticks") && state.rules["display_riichi_sticks"])
      |> assign(:display_honba, Map.has_key?(state.rules, "display_honba") && state.rules["display_honba"])
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
        ] ++ if state.mods != nil && not Enum.empty?(state.mods) do
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
    <div id="container" phx-hook="ClickListener">
      <%= if Map.has_key?(@state.rules, "tile_images") do %>
        <.live_component module={RiichiAdvancedWeb.CustomTilesComponent} id="custom-tiles" tiles={@state.rules["tile_images"]}/>
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
        tiles_left={length(@state.wall) - @state.wall_index - length(@state.drawn_reserved_tiles)}
        kyoku={@state.kyoku}
        honba={@state.honba}
        riichi_sticks={Utils.try_integer(@state.pot / (get_in(@state.rules["score_calculation"]["riichi_value"]) || 1000))}
        riichi={Map.new(@state.players, fn {seat, player} -> {seat, player.riichi_stick} end)}
        score={Map.new(@state.players, fn {seat, player} -> {seat, player.score} end)}
        display_riichi_sticks={@display_riichi_sticks}
        display_honba={@display_honba}
        is_bot={Map.new([:east, :south, :west, :north], fn seat -> {seat, is_pid(Map.get(@state, seat))} end)} />
      <%= if @state.visible_screen != nil do %>
        <.live_component module={RiichiAdvancedWeb.WinWindowComponent} id="win-window" game_state={@game_state} seat={@seat} winners={@state.winners} winner_index={@state.winner_index} timer={@state.timer} visible_screen={@state.visible_screen}/>
        <.live_component module={RiichiAdvancedWeb.ScoreWindowComponent} id="score-window" game_state={@game_state} seat={@seat} players={@state.players} winners={@state.winners} delta_scores={@state.delta_scores} delta_scores_reason={@state.delta_scores_reason} timer={@state.timer} visible_screen={@state.visible_screen}/>
        <.live_component module={RiichiAdvancedWeb.EndWindowComponent} id="end-window" game_state={@game_state} seat={@seat} players={@state.players} visible_screen={@state.visible_screen}/>
      <% end %>
      <%= if @state.error != nil do %>
        <.live_component module={RiichiAdvancedWeb.ErrorWindowComponent} id="error-window" game_state={@game_state} seat={@seat} players={@state.players} error={@state.error}/>
      <% end %>
      <%= if @viewer != :spectator do %>
        <div class="buttons" :if={@state.players[@seat].declared_yaku != []}>
          <%= if @marking && not Enum.empty?(@state.marking[@seat]) do %>
            <button class="button" phx-cancellable-click="clear_marked_objects">Clear</button>
            <button class="button" phx-cancellable-click="cancel_marked_objects">Cancel</button>
          <% else %>
            <%= if not Enum.empty?(@state.players[@seat].call_buttons) do %>
              <button class="button" phx-cancellable-click="cancel_call_buttons">Cancel</button>
            <% else %>
              <button class="button" phx-cancellable-click="button_clicked" phx-hover="hover_button" phx-hover-off="hover_off" phx-value-name={name} :for={name <- @state.players[@seat].buttons}><%= GenServer.call(@game_state, {:get_button_display_name, name}) %></button>
            <% end %>
          <% end %>
        </div>
        <div class="auto-buttons">
          <%= for {name, checked} <- @state.players[@seat].auto_buttons do %>
            <input id={"auto-button-" <> name} type="checkbox" class="auto-button" phx-click="auto_button_toggled" phx-value-name={name} phx-value-enabled={if checked do "true" else "false" end} checked={checked}>
            <label for={"auto-button-" <> name}><%= GenServer.call(@game_state, {:get_auto_button_display_name, name}) %></label>
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
                    <button class="call-button" phx-cancellable-click="call_button_clicked" phx-value-name={@state.players[@seat].call_name} phx-value-tile={Utils.strip_attrs(called_tile)} phx-value-choice={Enum.join(Utils.strip_attrs(choice), ",")}>
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
        revealed_tiles={@state.revealed_tiles}
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
        kyoku={@state.kyoku}
        wall={@state.wall}
        dead_wall={@state.dead_wall}
        die1={@state.die1}
        die2={@state.die2}
        dice_roll={@state.die1 + @state.die2}
        wall_index={@state.wall_index}
        revealed_tiles={@state.revealed_tiles}
        dead_wall_offset={@state.dead_wall_offset}
        reserved_tiles={@state.reserved_tiles}
        drawn_reserved_tiles={@state.drawn_reserved_tiles}
        :if={Map.get(@state.rules, "display_wall", false)} />
      <.live_component module={RiichiAdvancedWeb.LogControlComponent}
        id="log-control"
        state={@state}
        log={@log}
        log_control_state={@log_control_state} />
      <div class={["big-text"]} :if={@loading}>Loading...</div>
      <%= if RiichiAdvanced.GameState.Debug.debug_status() do %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <div class="status-text" :for={status <- player.status}><%= status %></div>
          <div class="status-text" :for={{name, value} <- player.counters}><%= "#{name}: #{value}" %></div>
        </div>
      <% else %>
        <%= if @state.players[@viewer] != nil do %>
          <div class={["status-line", "self"]}>
            <%= for status <- @state.players[@viewer].status, status in Map.get(@state.rules, "shown_statuses", []) do %>
              <div class="status-text"><%= status %></div>
            <% end %>
          </div>
        <% end %>
      <% end %>
      <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu_buttons" log_button={true} />
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/")
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
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, call_name: call_name, call_choice: call_choice, called_tile: Utils.to_tile(called_tile)}})
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"name" => call_name, "choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Utils.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, call_name: call_name, call_choice: call_choice, called_tile: nil}})
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
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.session_id) do
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
      |> assign(:marking, RiichiAdvanced.GameState.Marking.needs_marking?(state, socket.assigns.seat))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "play_sound", payload: %{"seat" => seat, "path" => path}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.session_id) && (seat == nil || seat == socket.assigns.viewer) do
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
