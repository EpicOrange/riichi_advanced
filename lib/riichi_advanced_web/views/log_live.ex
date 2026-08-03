defmodule RiichiAdvancedWeb.LogLive do
  alias RiichiAdvanced.GameState.Choice
  alias RiichiAdvanced.GameState.Game
  alias RiichiAdvanced.GameState.Rules
  alias RiichiAdvanced.ModLoader
  alias RiichiAdvanced.Utils
  alias RiichiAdvancedWeb.GameLive.InteractionState
  alias RiichiAdvancedWeb.GameLive.Tutorial
  use RiichiAdvancedWeb, :live_view
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.GameComponents

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:log_id, params["log_id"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:ruleset, "riichi")
    |> assign(:game_state, nil)
    |> assign(:log_control_state, nil)
    |> assign(:messages, [])
    |> assign(:messages_state, nil)
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
    |> assign(:waiting_on_timer, false)
    |> assign(:prev_timer, 0)
    |> assign(:tutorial_state, nil)
    |> assign(:interaction_state, %InteractionState{})

    # liveviews mount twice
    if connected?(socket) do

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
      config = Map.get(log["rules"], "config", nil)

      socket = socket
      |> assign(:ruleset, ruleset)
      |> assign(:room_code, Ecto.UUID.generate())
      |> assign(:log, log)
      |> assign(:log_json, log_json)

      if ruleset == "custom" and Map.has_key?(log["rules"], "ruleset_json") do
        # for custom logs, fetch the ruleset from the log and load it into cache before starting log supervisor
        RiichiAdvanced.Cache.put({:cache_rulesets, socket.assigns.room_code}, log["rules"]["ruleset_json"])
        RiichiAdvanced.Cache.put({:cache_rulesets, socket.assigns.room_code <> "_walker"}, log["rules"]["ruleset_json"])
      end

      # subscribe to state updates
      # make sure to do this before starting a game process!
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, socket.assigns.ruleset <> ":" <> socket.assigns.room_code)
      # start a new game process, if it doesn't exist already
      init_actions = [
        ["set_log_seeking_mode", true],
        ["fetch_messages", socket.assigns.session_id],
        ["initialize_game", socket.assigns.session_id, Enum.at(log["kyokus"], 0)]
      ]
      args = [room_code: socket.assigns.room_code, ruleset: socket.assigns.ruleset, mods: mods, config: config, init_actions: init_actions, log_id: socket.assigns.log_id, name: Utils.via_registry("log", socket.assigns.ruleset, socket.assigns.room_code)]
      log_spec = Supervisor.child_spec(%{
        id: {RiichiAdvanced.LogSupervisor, socket.assigns.ruleset, socket.assigns.room_code},
        start: {RiichiAdvanced.LogSupervisor, :start_link, [args]}
      }, restart: :temporary)
      case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, log_spec) do
        {:ok, _pid} ->
          IO.puts("Starting game session #{socket.assigns.room_code}")
        {:error, {:shutdown, error}} ->
          IO.puts("Error when starting game session #{socket.assigns.room_code}")
          IO.inspect(error)
        {:error, {:already_started, _pid}} ->
          [{game_state, _}] = Utils.registry_lookup("game_state", socket.assigns.ruleset, socket.assigns.room_code)
          IO.puts("Already started game session #{socket.assigns.room_code} #{inspect(game_state)}")
          GenServer.cast(game_state, {:init_player, socket.assigns.session_id, socket.assigns.seat_param})
      end

      {:ok, socket}
    else
      {:ok, socket}
    end
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
      <:log_control>
        <.live_component module={RiichiAdvancedWeb.LogControlComponent}
          id="log-control"
          state={@state}
          log={@log}
          log_control_state={@log_control_state} />
      </:log_control>
    </.game_view>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
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

  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "load_log_control_state", payload: %{"session_id" => session_id, "game_state" => game_state, "log_control_state" => log_control_state}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and session_id != nil and socket.assigns.session_id == session_id do
      socket = assign(socket, :game_state, game_state)
      socket = assign(socket, :log_control_state, log_control_state)
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
          %{text: "Viewing log for a"},
          %{bold: true, text: socket.assigns.ruleset},
          %{text: "game"},
        ] ++ if socket.assigns.state.mods != nil and not Enum.empty?(socket.assigns.state.mods) do
          [%{text: "with mods"}] ++ Enum.map(socket.assigns.state.mods, fn mod -> %{bold: true, text: ModLoader.get_mod_name(mod)} end)
        else [] end})
        socket
      else socket end
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "load_log_control_state", payload: %{"session_id" => session_id, "log_control_state" => log_control_state}}, socket) do
    if topic == (socket.assigns.ruleset <> ":" <> socket.assigns.room_code) and session_id != nil and socket.assigns.session_id == session_id do
      socket = assign(socket, :log_control_state, log_control_state)
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
        calls_before = Map.get(num_calls_before, seat) || 0
        calls_after = Map.get(num_calls_after, seat) || 0
        num_new_calls = calls_after - calls_before
        if num_new_calls > 0 do
          relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
          send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", num_new_calls: num_new_calls)
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
    if topic == "messages:" <> socket.assigns.session_id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{topic: topic, event: "reset_visible_waits", payload: %{"seat" => seat}}, socket) do
    {:noreply, socket}
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
