defmodule RiichiAdvanced.RoomState do
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils
  use GenServer

  defmodule RoomPlayer do
    defstruct [
      nickname: nil,
      id: "",
      session_id: nil,
      seat: nil
    ]
  end

  defmodule Room do
    @initial_textarea Delta.Op.insert("{}")
    def initial_textarea, do: @initial_textarea
    defstruct [
      # params
      ruleset: nil,
      ruleset_json: nil,
      room_code: nil,
      # pids
      supervisor: nil,
      exit_monitor: nil,

      # control variables
      error: nil,

      # state
      rules: nil,
      seats: %{},
      available_seats: [],
      players: %{},
      shuffle: false,
      private: true,
      starting: false,
      started: false,
      display_name: "",
      mods: %{},
      categories: [],
      tutorial_link: nil,
      textarea: [@initial_textarea],
      textarea_deltas: [[@initial_textarea]],
      textarea_delta_uuids: [[]],
      textarea_version: 0,
    ]
  end

  def start_link(init_data) do
    IO.puts("Room supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %Room{
        room_code: Keyword.get(init_data, :room_code),
        ruleset: Keyword.get(init_data, :ruleset)
      },
      name: Keyword.get(init_data, :name))
  end

  def init(state) do
    IO.puts("Room state PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room", state.ruleset, state.room_code))
    [{exit_monitor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("exit_monitor_room", state.ruleset, state.room_code))

    # read in the ruleset
    ruleset_json = ModLoader.get_ruleset_json(state.ruleset, state.room_code)
    config = ModLoader.get_config_json(state.ruleset, state.room_code)

    # parse the ruleset now, in order to get the list of eligible mods
    {state, rules} = try do
      case Jason.decode(RiichiAdvanced.ModLoader.strip_comments(ruleset_json)) do
        {:ok, rules} -> {state, rules}
        {:error, err} ->
          state = show_error(state, "WARNING: Failed to read rules file at character position #{err.position}!\nRemember that trailing commas are invalid!")
          {state, %{}}
      end
    rescue
      ArgumentError ->
        state = show_error(state, "WARNING: Ruleset \"#{state.ruleset}\" doesn't exist!")
        {state, %{}}
    end

    {mods, categories} = for {item, i} <- Map.get(rules, "available_mods", []) |> Enum.with_index(), reduce: {[], []} do
      {result, categories} -> cond do
        is_map(item) -> {[item |> Map.put("index", i) |> Map.put("category", Enum.at(categories, 0, nil)) | result], categories}
        is_binary(item) -> {result, [item | categories]}
      end
    end
    categories = Enum.reverse(categories)

    available_mods = Enum.map(mods, & &1["id"])
    starting_mods = case RiichiAdvanced.ETSCache.get({state.ruleset, state.room_code}, [], :cache_mods) do
      [mods] -> mods
      []     -> Map.get(rules, "default_mods", [])
    end
    |> Enum.filter(& &1 in available_mods)
    |> Enum.uniq()

    # calculate available_seats
    available_seats = case Map.get(rules, "num_players", 4) do
      1 -> [:east]
      2 -> [:east, :west]
      3 -> [:east, :south, :west]
      4 -> [:east, :south, :west, :north]
    end
    # put params and process ids into state
    state = Map.merge(state, %Room{
      available_seats: available_seats,
      seats: Map.new(available_seats, &{&1, nil}),
      ruleset: state.ruleset,
      ruleset_json: ruleset_json,
      room_code: state.room_code,
      rules: rules,
      error: state.error,
      supervisor: supervisor,
      exit_monitor: exit_monitor,
      display_name: Map.get(rules, "display_name", state.ruleset),
      mods: mods |> Map.new(fn mod -> {mod["id"], %{
        enabled: mod["id"] in starting_mods,
        index: mod["index"],
        name: mod["name"],
        desc: mod["desc"],
        category: mod["category"],
        order: Map.get(mod, "order", 0),
        class: mod["class"],
        deps: Map.get(mod, "deps", []),
        conflicts: Map.get(mod, "conflicts", [])
      }} end),
      categories: categories,
      tutorial_link: if state.ruleset == "custom" do
        "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/documentation.md"
      else
        Map.get(rules, "tutorial_link", nil)
      end,
      textarea: if state.ruleset == "custom" do
        [Delta.Op.insert(ruleset_json)]
      else
        [Delta.Op.insert(config)]
      end,
    })

    # if a game is running, remove the occupied seats from the menu
    existing_room_players = case Registry.lookup(:game_registry, Utils.to_registry_name("game_state", state.ruleset, state.room_code)) do
      [{game_state, _}] -> GenServer.call(game_state, :get_room_players)
      _ -> %{}
    end
    state = Map.update!(state, :seats, &Map.merge(&1, existing_room_players))

    # check if a lobby exists. if so, notify the lobby that this room now exists
    case Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", state.ruleset, "")) do
      [{lobby_state, _}] -> GenServer.cast(lobby_state, {:update_room_state, state.room_code, state})
      _                  -> nil
    end

    {:ok, state}
  end

  def put_seat(state, seat, val), do: Map.update!(state, :seats, &Map.put(&1, seat, val))
  def update_seat(state, seat, fun), do: Map.update!(state, :seats, &Map.update!(&1, seat, fun))
  def update_seats(state, fun), do: Map.update!(state, :seats, &Map.new(&1, fn {seat, player} -> {seat, fun.(player)} end))
  def update_seats_by_seat(state, fun), do: Map.update!(state, :seats, &Map.new(&1, fn {seat, player} -> {seat, fun.(seat, player)} end))
  
  def show_error(state, message) do
    state = Map.update!(state, :error, fn err -> if err == nil do message else err <> "\n\n" <> message end end)
    state = broadcast_state_change(state)
    state
  end

  def get_enabled_mods(state) do
    Map.get(state, :mods, %{})
    |> Enum.filter(fn {_mod, opts} -> opts.enabled end)
    |> Enum.sort_by(fn {_mod, opts} -> {opts.order, opts.index} end)
    |> Enum.map(fn {mod, _opts} -> mod end)
  end

  def toggle_mod(state, mod_name, enabled) do
    state = put_in(state.mods[mod_name].enabled, enabled)
    if enabled do
      # enable dependencies and disable conflicting mods
      state = for dep <- state.mods[mod_name].deps, Map.has_key?(state.mods, dep), reduce: state do
        state -> put_in(state.mods[dep].enabled, true)
      end
      for conflict <- state.mods[mod_name].conflicts, Map.has_key?(state.mods, conflict), reduce: state do
        state -> put_in(state.mods[conflict].enabled, false)
      end
    else
      # disable dependent mods
      for {dep, opts} <- state.mods, mod_name in opts.deps, reduce: state do
        state -> put_in(state.mods[dep].enabled, false)
      end
    end
  end

  def toggle_category(state, category_name) do
    mods = Enum.filter(state.mods, fn {_mod_name, mod} -> mod.category == category_name end)
    enable = Enum.all?(mods, fn {_mod_name, mod} -> not mod.enabled end)
    for {mod_name, mod} <- mods, mod.enabled != enable, reduce: state do
      state -> toggle_mod(state, mod_name, enable)
    end
  end

  def reset_mods_to_default(state) do
    default_mods = Map.get(state.rules, "default_mods", [])
    for {mod_name, _mod} <- state.mods, reduce: state do
      state -> put_in(state.mods[mod_name].enabled, mod_name in default_mods)
    end
  end

  def broadcast_state_change(state) do
    # IO.puts("broadcast_state_change called")
    RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> "-room:" <> state.room_code, "state_updated", %{"state" => state})
    state
  end

  def broadcast_textarea_change(state, {from_version, version, uuids, deltas}) do
    # IO.puts("broadcast_textarea_change called")
    if version > from_version do
      RiichiAdvancedWeb.Endpoint.broadcast(state.ruleset <> "-room:" <> state.room_code, "textarea_updated", %{"from_version" => from_version, "version" => version, "uuids" => uuids, "deltas" => deltas})
    end
    state
  end

  def handle_call({:new_player, socket}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, socket.id})
    nickname = if socket.assigns.nickname != "" do socket.assigns.nickname else "player" <> String.slice(socket.id, 10, 4) end
    state = put_in(state.players[socket.id], %RoomPlayer{nickname: nickname, id: socket.id, session_id: socket.assigns.session_id})
    IO.puts("Player #{socket.id} joined room #{state.room_code} for ruleset #{state.ruleset}")
    state = broadcast_state_change(state)
    {:reply, [state], state}
  end

  def handle_call({:delete_player, socket_id}, _from, state) do
    state = update_seats(state, fn player -> if player == nil or player.id == socket_id do nil else player end end)
    {_, state} = pop_in(state.players[socket_id])
    IO.puts("Player #{socket_id} exited #{state.room_code} for ruleset #{state.ruleset}")
    state = if Enum.empty?(state.players) do
      # all players have left, shutdown
      # check if a lobby exists. if so, notify the lobby that this room no longer exists
      case Registry.lookup(:game_registry, Utils.to_registry_name("lobby_state", state.ruleset, "")) do
        [{lobby_state, _}] -> GenServer.cast(lobby_state, {:delete_room, state.room_code})
        _                  -> nil
      end
      IO.puts("Stopping room #{state.room_code} for ruleset #{state.ruleset}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.RoomSessionSupervisor, state.supervisor)
      state
    else
      state = broadcast_state_change(state)
      state
    end
    {:reply, :ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  # collaborative textarea

  def handle_call(:get_textarea, _from, state) do
    {:reply, {state.textarea_version, state.textarea}, state}
  end

  def handle_call({:update_textarea, client_version, uuids, client_deltas}, _from, state) do
    version_diff = state.textarea_version - client_version
    missed_deltas = Enum.take(state.textarea_deltas, version_diff)
    missed_delta_uuids = Enum.take(state.textarea_delta_uuids, version_diff)
    others_deltas = Enum.zip(missed_deltas, missed_delta_uuids)
    |> Enum.reject(fn {_delta, uuid_list} -> Enum.any?(uuid_list, fn uuid -> uuid in uuids end) end)
    |> Enum.map(fn {delta, _uuid_list} -> delta end)

    client_delta = Enum.at(client_deltas, -1, [])
    transformed_delta = others_deltas |> Enum.reverse() |> Enum.reduce(client_delta, &Delta.transform(&1, &2, true))
    returned_deltas = [transformed_delta | missed_deltas] |> Enum.reverse()
    # IO.puts("""
    #   #{client_version} => #{state.textarea_version+1}
    #   Given the client delta #{inspect(client_delta)}
    #   and the missed deltas #{inspect(missed_deltas)}
    #   where others contributed #{inspect(others_deltas)}
    #   we transform the client delta into #{inspect(transformed_delta)}
    #   and return #{inspect(returned_deltas)}
    # """)

    returned_uuids = [uuids | missed_delta_uuids] |> Enum.reverse()
    state = if not Enum.empty?(client_delta) do
      state = Map.update!(state, :textarea_version, & &1 + 1)
      state = Map.update!(state, :textarea_deltas, &[transformed_delta | &1])
      state = Map.update!(state, :textarea_delta_uuids, &[uuids | &1])
      state = Map.update!(state, :textarea, &Delta.compose(&1, transformed_delta))
      state
    else state end
    change = {client_version, state.textarea_version, returned_uuids, returned_deltas}
    state = broadcast_textarea_change(state, change)
    if state.textarea_version > 100 do
      GenServer.cast(self(), :delta_compression)
    end
    {:reply, :ok, state}
  end



  def handle_cast(:delta_compression, state) do
    state = Map.put(state, :textarea_version, 0)
    compressed = state.textarea_deltas
    |> Enum.reverse()
    |> Delta.compose_all()
    state = Map.put(state, :textarea_deltas, [compressed])
    state = Map.update!(state, :textarea_delta_uuids, fn uuids -> [uuids |> Enum.take(99) |> Enum.concat()] end)
    state = Map.put(state, :textarea, compressed)
    change = {-1, 0, state.textarea_delta_uuids, state.textarea_deltas}
    state = broadcast_textarea_change(state, change)
    {:noreply, state}
  end

  def handle_cast({:sit, socket_id, session_id, seat}, state) do
    state = if state.seats[seat] == nil or state.seats[seat].session_id == session_id do
      # first, get up
      state = update_seats(state, fn player -> if player == nil or player.id == socket_id do nil else player end end)
      # then sit
      state = put_in(state.players[socket_id].seat, seat)
      state = put_seat(state, seat, state.players[socket_id])
      IO.puts("Player #{socket_id} sat in seat #{seat}")
      state
    else state end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_private, enabled}, state) do
    state = Map.put(state, :private, enabled)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_shuffle_seats, enabled}, state) do
    state = Map.put(state, :shuffle, enabled)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_mod, mod_name, enabled}, state) do
    state = toggle_mod(state, mod_name, enabled)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:toggle_category, category_name}, state) do
    state = toggle_category(state, category_name)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:reset_mods_to_default, state) do
    state = reset_mods_to_default(state)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:get_up, socket_id}, state) do
    state = update_seats(state, fn player -> if player == nil or player.id == socket_id do nil else player end end)
    state = put_in(state.players[socket_id].seat, nil)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:start_game, state) do
    state = Map.put(state, :starting, true)
    state = broadcast_state_change(state)
    {mods, config} = if state.ruleset == "custom" do
      ruleset_json = Enum.at(state.textarea, 0)["insert"]
      # 2MB char limit on ruleset_json
      if ruleset_json != nil and byte_size(ruleset_json) <= 2 * 1024 * 1024 do
        RiichiAdvanced.ETSCache.put(state.room_code, ruleset_json, :cache_rulesets)
      end
      {[], nil}
    else
      config = Enum.at(state.textarea, 0)["insert"]
      if config != nil do
        RiichiAdvanced.ETSCache.put({state.ruleset, state.room_code}, config, :cache_configs)
      end
      {get_enabled_mods(state), config}
    end
    reserved_seats = Map.new(state.players, fn {_id, player} -> {player.seat, player.session_id} end)
    game_spec = {RiichiAdvanced.GameSupervisor, room_code: state.room_code, ruleset: state.ruleset, mods: mods, config: config, private: state.private, reserved_seats: reserved_seats, name: {:via, Registry, {:game_registry, Utils.to_registry_name("game", state.ruleset, state.room_code)}}}
    state = case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec) do
      {:ok, _pid} ->
        IO.puts("Starting #{if state.private do "private" else "public" end} game session #{state.room_code}")
        # shuffle seats
        state = if state.shuffle do
          Map.update!(state, :seats, fn seats -> Map.keys(seats) |> Enum.zip(Map.values(seats) |> Enum.shuffle()) |> Map.new() end)
        else state end
        state = Map.put(state, :started, true)
        [{game_state, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", state.ruleset, state.room_code))
        GenServer.cast(game_state, {:initialize_game, nil})
        state
      {:error, {:shutdown, error}} ->
        IO.puts("Error when starting game session #{state.room_code}")
        IO.inspect(error)
        state = Map.put(state, :starting, false)
        state
      {:error, {:already_started, _pid}} ->
        IO.puts("Already started game session #{state.room_code}")
        state = Map.put(state, :started, true)
        state
    end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast(:dismiss_error, state) do
    state = Map.put(state, :error, nil)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

end
