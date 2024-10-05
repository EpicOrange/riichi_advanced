defmodule RiichiAdvancedWeb.GameLive do
  use RiichiAdvancedWeb, :live_view

  defp to_revealed_tiles(state) do
    revealed_tiles = for tile_spec <- state.revealed_tiles do
      {_, tile} = List.keyfind(state.reserved_tiles, tile_spec, 0, {tile_spec, Utils.to_tile(tile_spec)})
      tile
    end
    revealed_tiles ++ Enum.map(length(revealed_tiles)+1..state.max_revealed_tiles//1, fn _ -> :"1x" end)
  end

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:session_id, params["id"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, params["nickname"])
    |> assign(:seat_param, params["seat"])
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

    last_mods = case RiichiAdvanced.ETSCache.get({socket.assigns.ruleset, socket.assigns.session_id}, [], :cache_mods) do
      [mods] -> mods
      []     -> []
    end

    # liveviews mount twice; we only want to init a new player on the second mount
    if socket.root_pid != nil do
      # start a new game process, if it doesn't exist already
      game_spec = {RiichiAdvanced.GameSupervisor, session_id: socket.assigns.session_id, ruleset: socket.assigns.ruleset, mods: last_mods, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", socket.assigns.ruleset, socket.assigns.session_id)}}}
      game_state = case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec) do
        {:ok, _pid} ->
          IO.puts("Starting game session #{socket.assigns.session_id}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.session_id))
          game_state
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting game session #{socket.assigns.session_id}")
          IO.inspect(error)
          nil
        {:error, {:already_started, _pid}} ->
          IO.puts("Already started game session #{socket.assigns.session_id}")
          [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", socket.assigns.ruleset, socket.assigns.session_id))
          game_state
      end
      # subscribe to state updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.session_id)
      # init a new player and get the current state
      [state, seat, shimocha, toimen, kamicha, spectator] = GenServer.call(game_state, {:new_player, socket})
      socket = socket
      |> assign(:game_state, game_state)
      |> assign(:state, state)
      |> assign(:seat, seat)
      |> assign(:shimocha, shimocha)
      |> assign(:toimen, toimen)
      |> assign(:kamicha, kamicha)
      |> assign(:viewer, if spectator do :spectator else seat end)
      |> assign(:display_riichi_sticks, Map.has_key?(state.rules, "display_riichi_sticks") && state.rules["display_riichi_sticks"])
      |> assign(:display_honba, Map.has_key?(state.rules, "display_honba") && state.rules["display_honba"])
      |> assign(:loading, false)
      |> assign(:marking, GenServer.call(game_state, {:needs_marking?, seat}))

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
          %{bold: true, text: socket.assigns.session_id}
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
      <.live_component module={RiichiAdvancedWeb.HandComponent}
        id={"hand #{Utils.get_relative_seat(@seat, seat)}"}
        game_state={@game_state}
        revealed?={@viewer == seat || player.hand_revealed}
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
        play_tile={&send(self(), {:play_tile, &1})}
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
        tiles_left={length(@state.wall) - @state.wall_index - length(@state.drawn_reserved_tiles) - @state.dead_wall_index}
        kyoku={@state.kyoku}
        honba={@state.honba}
        riichi_sticks={@state.riichi_sticks}
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
        <div class="buttons">
          <%= if not Enum.empty?(@state.marking[@seat]) do %>
            <button class="button" phx-cancellable-click="clear_marked_objects">Clear</button>
            <button class="button" phx-cancellable-click="cancel_marked_objects">Cancel</button>
          <% else %>
            <%= if not Enum.empty?(@state.players[@seat].call_buttons) do %>
              <button class="button" phx-cancellable-click="cancel_call_buttons">Cancel</button>
            <% else %>
              <button class="button" phx-cancellable-click="button_clicked" phx-value-name={name} :for={name <- @state.players[@seat].buttons}><%= GenServer.call(@game_state, {:get_button_display_name, name}) %></button>
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
                    <div class={["tile", called_tile]}></div>
                    <div class="call-button-separator"></div>
                  <% end %>
                  <%= for choice <- choices do %>
                    <button class="call-button" phx-cancellable-click="call_button_clicked" phx-value-name={@state.players[@seat].call_name} phx-value-tile={called_tile} phx-value-choice={Enum.join(choice, ",")}>
                    <%= for tile <- choice do %>
                      <div class={["tile", tile]}></div>
                    <% end %>
                    </button>
                  <% end %>
                <% else %>
                  <%= for choice <- choices do %>
                    <button class="call-button" phx-cancellable-click="saki_card_clicked" phx-value-choice={choice}>
                    <%= for tile <- choice do %>
                      <div class={["saki-card", @state.saki.version, tile]}></div>
                    <% end %>
                    </button>
                  <% end %>
                <% end %>
              </div>
            <% end %>
          <% end %>
        </div>
      <% end %>
      <div class="revealed-tiles">
        <div class={["tile", tile]} :for={tile <- to_revealed_tiles(@state)}></div>
      </div>
      <div class={["big-text"]} :if={@loading}>Loading...</div>
      <%= if RiichiAdvanced.GameState.Debug.debug_status() do %>
        <div class={["status-line", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @state.players}>
          <div class="status-text" :for={status <- player.status}><%= status %></div>
        </div>
      <% end %>
      <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu_buttons" />
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @state.ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def skip_or_discard_draw(socket) do
    # if draw, discard it
    # otherwise, if buttons, skip
    player = socket.assigns.state.players[socket.assigns.seat]
    if socket.assigns.seat == socket.assigns.state.turn && not Enum.empty?(player.draw) do
      index = length(player.hand)
      GenServer.cast(socket.assigns.game_state, {:play_tile, socket.assigns.seat, index})
    else
      if "skip" in player.buttons do
        GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, "skip"})
      end
    end
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/lobby/#{socket.assigns.ruleset}/#{socket.assigns.session_id}?nickname=#{Map.get(socket.assigns, :nickname, "")}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    skip_or_discard_draw(socket)
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    skip_or_discard_draw(socket)
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
    if socket.assigns.seat != :spectator do
      GenServer.cast(socket.assigns.game_state, {:ready_for_next_round, socket.assigns.seat})
    end
    socket = assign(socket, :timer, 0)
    {:noreply, socket}
  end

  def handle_info({:play_tile, index}, socket) do
    if socket.assigns.seat == socket.assigns.state.turn do
      GenServer.cast(socket.assigns.game_state, {:play_tile, socket.assigns.seat, index})
    end
    {:noreply, socket}
  end
  def handle_info({:reindex_hand, from, to}, socket) do
    GenServer.cast(socket.assigns.game_state, {:reindex_hand, socket.assigns.seat, from, to})
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
