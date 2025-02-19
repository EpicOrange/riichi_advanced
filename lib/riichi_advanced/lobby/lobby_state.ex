defmodule RiichiAdvanced.LobbyState do
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils
  use GenServer

  defmodule LobbyPlayer do
    defstruct [
      nickname: nil,
      id: ""
    ]
  end

  defmodule LobbyRoom do
    defstruct [
      # seat => %RoomPlayer{}
      players: %{},
      mods: [],
      private: true,
      started: false
    ]
  end

  defmodule Lobby do
    defstruct [
      # params
      ruleset: nil,
      ruleset_json: nil,
      # pids
      supervisor: nil,
      exit_monitor: nil,

      # control variables
      error: nil,

      # state
      players: %{},
      rooms: %{},
      display_name: ""
    ]
  end

  def start_link(init_data) do
    IO.puts("Lobby supervisor PID is #{inspect(self())}")
    GenServer.start_link(
      __MODULE__,
      %Lobby{
        ruleset: Keyword.get(init_data, :ruleset)
      },
      name: Keyword.get(init_data, :name))
  end

  def init(state) do
    IO.puts("Lobby state PID is #{inspect(self())}")

    # lookup pids of the other processes we'll be using
    [{supervisor, _}] = Utils.registry_lookup("lobby", state.ruleset, "")
    [{exit_monitor, _}] = Utils.registry_lookup("exit_monitor_lobby", state.ruleset, "")

    # read in the ruleset

    ruleset_json = ModLoader.get_ruleset_json(state.ruleset)

    # parse the ruleset just to get the display name
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

    # put params and process ids into state
    state = Map.merge(state, %Lobby{
      ruleset: state.ruleset,
      ruleset_json: ruleset_json,
      display_name: Map.get(rules, "display_name", state.ruleset),
      error: state.error,
      supervisor: supervisor,
      exit_monitor: exit_monitor,
      rooms: %{}
    })

    # load all existing rooms
    room_prefix = Utils.to_registry_name("room", state.ruleset, "")
    room_codes = DynamicSupervisor.which_children(RiichiAdvanced.RoomSessionSupervisor)
    |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
    |> Enum.filter(fn name -> String.starts_with?(name, room_prefix) end)
    |> Enum.map(fn name -> String.replace_prefix(name, room_prefix, "") end)
    state = for room_code <- room_codes, reduce: state do
      state ->
        state = broadcast_new_room(state, room_code)
        [{room_state_pid, _}] = Utils.registry_lookup("room_state", state.ruleset, room_code)
        room_state = GenServer.call(room_state_pid, :get_state)
        put_in(state.rooms[room_code], %LobbyRoom{
          players: room_state.seats,
          mods: RiichiAdvanced.RoomState.get_enabled_mods(room_state),
          private: room_state.private
        })
    end

    # load all existing games
    game_prefix = Utils.to_registry_name("game", state.ruleset, "")
    game_codes = DynamicSupervisor.which_children(RiichiAdvanced.GameSessionSupervisor)
    |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
    |> Enum.filter(fn name -> String.starts_with?(name, game_prefix) end)
    |> Enum.map(fn name -> String.replace_prefix(name, game_prefix, "") end)
    state = for game_code <- game_codes, reduce: state do
      state ->
        state = broadcast_new_room(state, game_code)
        case Utils.registry_lookup("game_state", state.ruleset, game_code) do
          [{game_state_pid, _}] ->
            put_in(state.rooms[game_code], GenServer.call(game_state_pid, :get_lobby_room))
          _ -> state
        end
    end
    {:ok, state}
  end

  def show_error(state, message) do
    state = Map.update!(state, :error, fn err -> if err == nil do message else err <> "\n\n" <> message end end)
    state = broadcast_state_change(state)
    state
  end

  def broadcast_state_change(state) do
    # IO.puts("broadcast_state_change called")
    RiichiAdvancedWeb.Endpoint.broadcast("lobby:" <> state.ruleset, "state_updated", %{"state" => state})
    state
  end
  def broadcast_new_room(state, room_code) do
    RiichiAdvancedWeb.Endpoint.broadcast("lobby:" <> state.ruleset, "new_room", %{"name" => room_code})
    state
  end

  @tiles [
    "1m","2m","3m","4m","5m","6m","7m","8m","9m",
    "1p","2p","3p","4p","5p","6p","7p","8p","9p",
    "1s","2s","3s","4s","5s","6s","7s","8s","9s",
    "1z","2z","3z","4z","5z","6z","7z"
  ]
  def generate_room_name(state, tries_left \\ 1000) do
    if tries_left > 0 do
      room_name = Enum.join([Enum.random(@tiles), Enum.random(@tiles), Enum.random(@tiles)], ",")
      if Map.has_key?(state.rooms, room_name) do
        generate_room_name(state, tries_left - 1)
      else
        room_name
      end
    else nil end
  end

  def create_room(state) do
    case generate_room_name(state) do
      nil       -> :no_names_remaining
      room_code ->
        state = put_in(state.rooms[room_code], %LobbyRoom{})
        state = broadcast_state_change(state)
        state = broadcast_new_room(state, room_code)
        {:ok, state, room_code}
    end
  end

  def handle_call({:new_player, socket}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, socket.id})
    nickname = if socket.assigns.nickname != "" do socket.assigns.nickname else "player" <> String.slice(socket.id, 10, 4) end
    state = put_in(state.players[socket.id], %LobbyPlayer{nickname: nickname, id: socket.id})
    IO.puts("Player #{socket.id} joined lobby for #{state.ruleset}")
    state = broadcast_state_change(state)
    {:reply, [state], state}
  end

  def handle_call({:delete_player, socket_id}, _from, state) do
    {_, state} = pop_in(state.players[socket_id])
    IO.puts("Player #{socket_id} exited lobby for #{state.ruleset}")
    state = if Enum.empty?(state.players) do
      # all players have left, shutdown
      IO.puts("Stopping lobby for ruleset #{state.ruleset}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.LobbySessionSupervisor, state.supervisor)
      state
    else
      state = broadcast_state_change(state)
      state
    end
    {:reply, :ok, state}
  end

  def handle_call(:create_room, _from, state) do
    case create_room(state) do
      :no_names_remaining      -> {:reply, :no_names_remaining, state}
      {:ok, state, room_code} -> {:reply, {:ok, room_code}, state}
    end
  end

  def handle_cast({:update_room_state, room_code, room_state}, state) do
    state = put_in(state.rooms[room_code], %LobbyRoom{
      players: room_state.seats,
      mods: RiichiAdvanced.RoomState.get_enabled_mods(room_state),
      private: room_state.private,
      started: room_state.started
    })
    state = broadcast_state_change(state)
    {:noreply, state}
  end

  def handle_cast({:delete_room, room_code}, state) do
    {_, state} = pop_in(state.rooms[room_code])
    {:noreply, state}
  end
  
  def handle_cast(:dismiss_error, state) do
    state = Map.put(state, :error, nil)
    state = broadcast_state_change(state)
    {:noreply, state}
  end

end
