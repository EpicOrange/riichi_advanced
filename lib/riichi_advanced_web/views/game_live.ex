# all interactive bits that won't matter in log view
defmodule RiichiAdvancedWeb.GameLive.InteractionState do
  defstruct [
    selected_index: nil,
    hovered_called_tile: nil,
    hovered_call_choice: nil,
    playable_indices: [],
    preplayed_index: nil,
    hide_buttons: false, # used to hide buttons on the client side after clicking one
    visible_waits: nil,
    visible_waits_hand: nil,
    show_waits_index: nil
  ]
end

defmodule RiichiAdvancedWeb.GameLive.Tutorial do
  defstruct [
    sequence_name: nil,
    sequence: nil,
    return_to_editor: false,
    next_scenes: nil,
    waiting_for_click: false,
    last_forced_events: nil,
    force_event: nil,
  ]
  alias __MODULE__
  alias RiichiAdvanced.GameState.Debug
  alias RiichiAdvanced.ModLoader
  require Logger

  def setup_tutorial(nil), do: nil
  def setup_tutorial(sequence_name) do
    # read the tutorial file
    # return_to_editor just means we must have loaded it from the editor (the tutorial _file_ doesn't exist)
    # this only changes the back button to go back to the editor instead
    {sequence_json, return_to_editor} = 
      case File.read(Application.app_dir(:riichi_advanced, "/priv/static/tutorials/#{sequence_name}.json")) do
        {:ok, sequence_json} -> {sequence_json, false}
        {:error, _err}       ->
          # try loading custom ruleset from cache
          {:ok, sequence_json} = RiichiAdvanced.Cache.get({:cache_sequences, sequence_name}, "{}")
          {sequence_json, true}
      end

    # decode the sequence json
    sequence = try do
      case Jason.decode(ModLoader.strip_comments(sequence_json)) do
        {:ok, sequence} -> sequence
        {:error, err} ->
          Logger.error("Erroring json:")
          Logger.error(inspect(sequence_json))
          Logger.error("WARNING: Failed to read sequence file at character position #{err.position}!\nRemember that trailing commas are invalid!")
          %{}
      end
    rescue
      ArgumentError -> 
        IO.puts("WARNING: Sequence \"#{sequence_name}\" doesn't exist!")
        %{}
    end

    update_tutorial(Map.get(sequence["scenes"], "start", []))

    %Tutorial{
      sequence: sequence,
      return_to_editor: return_to_editor,
    }
  end

  def trigger_next_scene(state, choice) do
    state.force_event.([], true) # first block events
    next_scene = if is_integer(choice) do Enum.at(state.next_scenes, choice) else choice end
    if next_scene != :resume do
      Map.get(state.sequence["scenes"], next_scene, [])
    else :resume end
    |> update_tutorial()
    state = put_in(state.next_scenes, nil)
    state
  end

  def await_click(state, next_scene) do
    state = put_in(state.next_scenes, [next_scene])
    state = put_in(state.waiting_for_click, true)
    state
  end

  def handle_click(state) when not state.waiting_for_click, do: state
  def handle_click(state) do
    if Debug.debug_tutorial() do IO.puts("\nresuming tutorial actions due to click\n") end
    put_in(state.waiting_for_click, false)
    |> RiichiAdvancedWeb.GameLive.Tutorial.trigger_next_scene(0)
  end

  def force_event(state, next_scenes, events, blocking?) do
    state.force_event.(events, blocking?)
    if Debug.debug_tutorial() do IO.puts("#{if blocking? do "Forcing" else "Awaiting" end} events #{inspect(events)}") end
    state = put_in(state.next_scenes, next_scenes)
    state = put_in(state.last_forced_events, events)
    state
  end

  def receive_update(state, last_event) do
    if state.next_scenes != nil and not state.waiting_for_click and last_event in state.last_forced_events do
      if Debug.debug_tutorial() do
        IO.puts("\nresuming tutorial actions due to forced_events == [] and last event == #{inspect(last_event)}\n")
      end
      i = Enum.find_index(state.last_forced_events, & &1 == last_event)
      Tutorial.trigger_next_scene(state, i)
    else state end
  end

  defp update_tutorial(actions) do
    Phoenix.LiveView.send_update(RiichiAdvancedWeb.TutorialOverlayComponent, id: "tutorial-overlay", actions: actions)
  end
end

defmodule RiichiAdvancedWeb.GameLive do
  alias RiichiAdvanced.GameState.Debug
  alias RiichiAdvanced.GameState.Game
  alias RiichiAdvanced.GameState.Rules
  alias RiichiAdvanced.Match
  alias RiichiAdvanced.ModLoader
  alias RiichiAdvanced.Utils
  alias RiichiAdvancedWeb.GameLive.InteractionState
  alias RiichiAdvancedWeb.GameLive.Tutorial
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  use RiichiAdvancedWeb, :live_view
  import RiichiAdvancedWeb.GameComponents

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:room_code, params["room_code"])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:seat_param, params["seat"])
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:game_state, nil)
    |> assign(:messages, [])
    |> assign(:messages_state, nil)
    |> assign(:state, %Game{})
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
    |> assign(:waiting_on_timer, false)
    |> assign(:prev_timer, 0)
    |> assign(:tutorial_state, nil)
    |> assign(:interaction_state, %InteractionState{})

    # liveviews mount twice; we only want to init a new player on the second mount
    # also do not init anything if the node is currently draining for cutover
    if connected?(socket) and not :persistent_term.get(:drain, false) do
      # check if we're a tutorial; if so, load its mods/config instead
      socket = assign(socket, :tutorial_state, Tutorial.setup_tutorial(params["sequence"]))
      socket = if socket.assigns.tutorial_state != nil do
        assign(socket, :room_code, Ecto.UUID.generate())
      else socket end
      {mods, config} = case socket.assigns.tutorial_state do
        nil ->
          # not a tutorial, load mods/config as normal
          {:ok, last_mods} = RiichiAdvanced.Cache.get({:cache_mods, socket.assigns.ruleset, socket.assigns.room_code}, [])
          {:ok, last_config} = RiichiAdvanced.Cache.get({:cache_configs, socket.assigns.ruleset, socket.assigns.room_code}, nil)
          {last_mods, last_config}
        %{sequence: sequence} ->
          # fetch tutorial's mods/configs instead
          mods = Map.get(sequence, "mods", [])
          |> Enum.map(&case &1 do
            %{"name" => name, "config" => config} -> %{name: name, config: config}
            mod -> mod
          end)
          config = Map.get(sequence, "config", {})
          {mods, config}
      end
      config = if is_map(config) do Jason.encode!(config) else config end

      # subscribe to state updates
      # make sure to do this before starting a game process!
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.room_code)

      # start a new game process, if it doesn't exist already
      init_actions = [
        ["init_player", socket.assigns.session_id, socket.assigns.seat_param],
        ["fetch_messages", socket.assigns.session_id],
        ["initialize_game"]
      ]
      init_actions = if socket.assigns.tutorial_state != nil do
        [["initialize_tutorial"] | init_actions] # block events if we're a tutorial
      else init_actions end
      args = [room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, mods: mods, config: config, init_actions: init_actions, name: Utils.via_registry("game", socket.assigns.ruleset, socket.assigns.room_code)]
      game_spec = Supervisor.child_spec(%{
        id: {RiichiAdvanced.GameSupervisor, socket.assigns.ruleset, socket.assigns.room_code},
        start: {RiichiAdvanced.GameSupervisor, :start_link, [args]}
      }, restart: :temporary)
      case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec) do
        {:ok, _pid} ->
          IO.puts("Starting game session #{socket.assigns.room_code}")
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting game session #{socket.assigns.room_code}")
          IO.inspect(error)
        {:error, {:already_started, _pid}} ->
          [{game_state, _}] = Utils.registry_lookup("game_state", socket.assigns.ruleset, socket.assigns.room_code)
          IO.puts("Already started game session #{socket.assigns.room_code} #{inspect(game_state)}")
          GenServer.cast(game_state, {:init_player, socket.assigns.session_id, socket.assigns.seat_param})
          GenServer.cast(game_state, {:fetch_messages, socket.assigns.session_id})
      end

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def update_tutorial_state(socket, f) do
    assign(socket, :tutorial_state, f.(socket.assigns.tutorial_state))
  end

  def update_interaction_state(socket, f) do
    assign(socket, :interaction_state, f.(socket.assigns.interaction_state))
  end

  def render(assigns) do
    ~H"""
    <.game_view
      state={@state}
      ruleset={@ruleset}
      seat={@seat}
      game_state={@game_state}
      viewer={@viewer}
      lang={@lang}
      display_riichi_sticks={@display_riichi_sticks}
      display_honba={@display_honba}
      waiting_on_timer={@waiting_on_timer}
      marking={@marking}
      revealed_tiles={@revealed_tiles}
      loading={@loading}
      tutorial_state={@tutorial_state}
      interaction_state={@interaction_state}
      messages={@messages}
      messages_state={@messages_state}>
    </.game_view>
    """
  end

  def skip_or_discard_draw(socket) do
    if socket.assigns.interaction_state.selected_index == nil do
      # do a clientside can_discard check here
      if RiichiAdvanced.GameState.Actions.can_discard(socket.assigns.state, socket.assigns.seat, true) do
        # if draw, discard it
        # otherwise, if buttons, skip
        player = socket.assigns.state.players[socket.assigns.seat]
        if socket.assigns.seat == socket.assigns.state.turn and not Enum.empty?(player.draw) do
          send(self(), {:play_tile, length(player.hand)})
          update_interaction_state(socket, &%{&1 | selected_index: :any})
        else
          if "skip" in player.buttons do
            GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, "skip"})
          end
          socket
        end
      else socket end
    else
      update_interaction_state(socket, &%{&1 | selected_index: nil})
    end
  end

  defp get_visible_waits(socket, index) do
    player = socket.assigns.state.players[socket.assigns.seat]
    hand = player.hand ++ player.draw
    socket = if hand != socket.assigns.interaction_state.visible_waits_hand do
      update_interaction_state(socket, &%{&1 | visible_waits: nil, visible_waits_hand: hand})
    else socket end
    visible_waits = socket.assigns.interaction_state.visible_waits || %{}
    if not Map.has_key?(visible_waits, index) do
      # first check if we even need this tile
      tenpai_definitions = Rules.translate_match_definitions(socket.assigns.state.rules_ref, "tenpai", true)
      if Enum.empty?(tenpai_definitions) || Match.needed_for_hand(hand, player.calls, Enum.at(hand, index), tenpai_definitions, player.tile_behavior) do
        update_interaction_state(socket, &%{&1 | visible_waits: Map.put(visible_waits, index, [])})
      else
        # async call; gets handled below in :set_visible_waits
        GenServer.cast(socket.assigns.game_state, {:get_visible_waits, self(), socket.assigns.seat, index})
        update_interaction_state(socket, &%{&1 | visible_waits: Map.put(visible_waits, index, :loading)})
      end
    else socket end
  end

  defp navigate_back(socket) do
    cond do
      socket.assigns.tutorial_state == nil -> push_navigate(socket, to: ~p"/room/#{socket.assigns.ruleset}/#{socket.assigns.room_code}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}&seat=#{socket.assigns.seat}")
      socket.assigns.tutorial_state.return_to_editor -> push_navigate(socket, to: ~p"/tutorial_creator?ruleset=#{socket.assigns.ruleset}&seat=#{socket.assigns.seat_param}&tutorial_id=#{socket.assigns.tutorial_state.sequence_name}&nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
      true -> push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    end
  end

  def handle_event("noop", _assigns, socket), do: {:noreply, socket}
  def handle_event("back", _assigns, socket), do: {:noreply, navigate_back(socket)}

  def handle_event("log", _assigns, socket) do
    log = GenServer.call(socket.assigns.game_state, :get_log)
    socket = push_event(socket, "copy-log", %{log: log})
    {:noreply, socket}
  end

  def handle_event("double_clicked", %{"classes" => classes}, socket) do
    ignore_click = "tile" in classes
    socket = if not ignore_click and socket.assigns.tutorial_state == nil do
      skip_or_discard_draw(socket)
    else socket end
    {:noreply, socket}
  end

  def handle_event("right_clicked", %{"classes" => classes}, socket) do
    ignore_click = "tile" in classes
    socket = if not ignore_click and socket.assigns.tutorial_state == nil do
      skip_or_discard_draw(socket)
    else socket end
    {:noreply, socket}
  end

  def handle_event("button_clicked", %{"name" => name}, socket) do
    GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, name})
    socket = update_interaction_state(socket, &%{&1 | hovered_called_tile: nil, hovered_call_choice: nil})
    socket = if socket.assigns.tutorial_state == nil do
      update_interaction_state(socket, &%{&1 | hide_buttons: true})
    else socket end
    {:noreply, socket}
  end

  def handle_event("auto_button_toggled", %{"name" => name, "enabled" => enabled}, socket) do
    if socket.assigns.tutorial_state == nil do
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
    socket = assign(socket, :waiting_on_timer, true)
    socket = assign(socket, :prev_timer, socket.assigns.state.timer)
    {:noreply, socket}
  end

  def handle_event("toggle_next_dealer", _assigns, socket) do
    status = socket.assigns.state.players[socket.assigns.seat].status
    GenServer.cast(socket.assigns.game_state, {:toggle_next_dealer, socket.assigns.seat, "renchan" in status})
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
    socket = update_interaction_state(socket, &%{&1 | hovered_called_tile: called_tile})
    buttons = Rules.get(socket.assigns.state.rules_ref, "buttons", %{})
    is_upgrade = get_in(buttons[name]["upgrades"]) != nil
    socket = update_interaction_state(socket, &%{&1 | hovered_call_choice: if is_upgrade do nil else call_choice end})
    {:noreply, socket}
  end

  def handle_event("hover_off", _assigns, socket) do
    socket = update_interaction_state(socket, &%{&1 | hovered_called_tile: nil, hovered_call_choice: nil})
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

  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}

  def handle_event("tutorial_overlay_clicked", _assigns, socket), do: {:noreply, update_tutorial_state(socket, &Tutorial.handle_click(&1))}

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info(:back, socket) do
    {:noreply, navigate_back(socket)}
  end

  def handle_info({:play_tile, index}, socket) do
    if socket.assigns.seat == socket.assigns.state.turn and socket.assigns.interaction_state.selected_index in [index, :any] do
      socket = update_interaction_state(socket, &%{&1 | visible_waits: %{}, show_waits_index: nil})
      socket = if socket.assigns.tutorial_state == nil do
        update_interaction_state(socket, &%{&1 | preplayed_index: index})
      else socket end
      GenServer.cast(socket.assigns.game_state, {:play_tile, socket.assigns.seat, index})
      socket = update_interaction_state(socket, &%{&1 | selected_index: nil})
      {:noreply, socket}
    else
      socket = update_interaction_state(socket, &%{&1 | selected_index: index})
      {:noreply, socket}
    end
  end

  def handle_info({:mark_tile, index, source}, socket) do
    GenServer.cast(socket.assigns.game_state, {:mark_tile, socket.assigns.viewer, socket.assigns.seat, index, source})
    socket = update_interaction_state(socket, &%{&1 | selected_index: nil})
    {:noreply, socket}
  end

  def handle_info({:unmark_tile, index, source}, socket) do
    GenServer.cast(socket.assigns.game_state, {:unmark_tile, socket.assigns.viewer, socket.assigns.seat, index, source})
    socket = update_interaction_state(socket, &%{&1 | selected_index: nil})
    {:noreply, socket}
  end

  def handle_info({:hover, index}, socket) do
    if index <= length(socket.assigns.state.players[socket.assigns.viewer].hand) do
      socket = get_visible_waits(socket, index)
      socket = update_interaction_state(socket, &%{&1 | show_waits_index: index})
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(:hover_off, socket) do
    socket = update_interaction_state(socket, &%{&1 | show_waits_index: nil})
    {:noreply, socket}
  end

  def handle_info({:reindex_hand, from, to}, socket) do
    GenServer.cast(socket.assigns.game_state, {:reindex_hand, socket.assigns.seat, from, to})
    socket = update_interaction_state(socket, &%{&1 | visible_waits: %{}, show_waits_index: nil})
    {:noreply, socket}
  end

  # tutorial stuff
  def handle_info({:play_scene, next_scene}, socket), do: {:noreply, update_tutorial_state(socket, &Tutorial.trigger_next_scene(&1, next_scene))}
  def handle_info({:await_click, next_scene}, socket), do: {:noreply, update_tutorial_state(socket, &Tutorial.await_click(&1, next_scene))}
  def handle_info({:force_event, next_scenes, events, blocking?}, socket), do: {:noreply, update_tutorial_state(socket, &Tutorial.force_event(&1, next_scenes, events, blocking?))}

  def handle_info(%{topic: topic, event: "initialize_player", payload: %{"session_id" => session_id, "game_state" => game_state, "state" => state, "seat" => seat, "spectator" => spectator}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and session_id != nil and socket.assigns.session_id == session_id do
      # subscribe to this game state's exit monitor and init messages
      GenServer.call(game_state, {:link_player_socket, socket.assigns.session_id, seat, spectator, socket.assigns.nickname})

      socket = socket
      |> assign(:game_state, game_state)
      |> assign(:state, state)
      |> assign(:seat, seat)
      |> assign(:viewer, if spectator do :spectator else seat end)
      |> assign(:display_riichi_sticks, Rules.get(state.rules_ref, "display_riichi_sticks", false))
      |> assign(:display_honba, Rules.get(state.rules_ref, "display_honba", false))
      |> assign(:marking, RiichiAdvanced.GameState.Marking.needs_marking?(state, seat))
      |> assign(:loading, false)

      # give tutorial a callback to force events
      socket = if socket.assigns.tutorial_state != nil do
        force_event = fn events, blocking? -> GenServer.call(game_state, {:force_event, events, blocking?}) end
        socket = assign(socket, :tutorial_state, %{ socket.assigns.tutorial_state | force_event: force_event })
        socket
      else socket end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "fetch_messages", payload: %{"session_id" => session_id}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and session_id != nil and socket.assigns.session_id == session_id do
      # fetch messages
      messages_init = RiichiAdvanced.MessagesState.link_player_socket(socket.root_pid, socket.assigns.session_id)
      socket = if Map.has_key?(messages_init, :messages_state) do
        socket = assign(socket, :messages_state, messages_init.messages_state)
        # subscribe to message updates
        Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.assigns.session_id)
        GenServer.cast(messages_init.messages_state, {:add_message, [
          if socket.assigns.state.mods != nil and not Enum.empty?(socket.assigns.state.mods) do
            %{
              text: "Entered a %{ruleset} game, room code %{room_code} with mods %{mods}",
              vars: %{
                ruleset: {:text, socket.assigns.ruleset, %{bold: true}},
                room_code: {:text, socket.assigns.room_code, %{bold: true}},
                mods: {:text, Enum.map_join(socket.assigns.state.mods, ", ", &ModLoader.get_mod_name/1), %{bold: true}}
              }
            }
          else
            %{
              text: "Entered a %{ruleset} game, room code %{room_code}",
              vars: %{
                ruleset: {:text, socket.assigns.ruleset, %{bold: true}},
                room_code: {:text, socket.assigns.room_code, %{bold: true}}
              }
            }
          end
        ]})
        socket
      else socket end
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) do
      # animate new calls
      num_calls_before = Map.new(socket.assigns.state.players, fn {seat, player} -> {seat, length(player.calls)} end)
      num_calls_after = Map.new(state.players, fn {seat, player} -> {seat, length(player.calls)} end)
      Enum.each(Map.keys(num_calls_before), fn seat ->
        if num_calls_after[seat] != nil and num_calls_after[seat] > num_calls_before[seat] do
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
      socket = if socket.assigns.tutorial_state != nil and Enum.empty?(state.forced_events) do
        update_tutorial_state(socket, &Tutorial.receive_update(&1, state.last_event))
      else socket end

      # reset waiting_on_timer to false if timer hits 0 or is higher than last timer
      socket = if state.timer == 0 or state.timer >= socket.assigns.prev_timer do
        assign(socket, :waiting_on_timer, false)
      else socket end

      socket = socket
      |> assign(:state, state)
      |> update_interaction_state(&%{&1 | playable_indices: state.players[socket.assigns.seat].cache.playable_indices, preplayed_index: nil, hide_buttons: false})
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
    if topic == "messages:" <> socket.assigns.session_id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "reset_visible_waits", payload: %{"seat" => seat}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and socket.assigns.seat == seat do
      # force reset waits, sent via clear_player_cache action
      socket = update_interaction_state(socket, &%{&1 | visible_waits: nil})
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

  # hand is hand ++ draw
  # tile is the tile that, when removed, yields the waits
  # waits is something like [{:"0s", 2, "Self-Draw"}, {:"5s", 0, "Self-Draw"}, {:"35s", 1, nil}]
  # assign that array to each index in hand equal to tile
  def handle_info({:set_visible_waits, hand, tile, waits}, socket) do
    socket = if hand != socket.assigns.interaction_state.visible_waits_hand do
      # IO.puts("Resetting waits because #{inspect(hand)} != cached #{inspect(socket.assigns.interaction_state.visible_waits_hand)}")
      update_interaction_state(socket, &%{&1 | visible_waits: %{}, visible_waits_hand: hand})
    else socket end
    new_visible_waits = hand
    |> Enum.with_index()
    |> Enum.filter(fn {t, _i} -> t == tile end)
    |> Enum.map(fn {_t, i} -> i end)
    |> Enum.reduce(socket.assigns.interaction_state.visible_waits, &Map.put(&2, &1, waits))
    socket =  update_interaction_state(socket, &%{&1 | visible_waits: new_visible_waits})
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

end
