defmodule LobbyPlayer do
  defstruct [
    nickname: nil,
    id: "",
    ready: false
  ]
  use Accessible
end

defmodule LobbyRoom do
  defstruct [
    room_code: nil,
    private: true
  ]
  use Accessible
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
  ]
  use Accessible
end


defmodule RiichiAdvanced.LobbyState do
  use GenServer

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
    [{supervisor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("lobby", state.ruleset, ""))
    [{exit_monitor, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("exit_monitor_lobby", state.ruleset, ""))

    # read in the ruleset
    ruleset_json = case File.read(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{state.ruleset <> ".json"}")) do
      {:ok, ruleset_json} -> ruleset_json
      {:error, _err}      -> nil
    end

    # put params, debouncers, and process ids into state
    state = Map.merge(state, %Lobby{
      ruleset: state.ruleset,
      ruleset_json: ruleset_json,
      error: state.error,
      supervisor: supervisor,
      exit_monitor: exit_monitor,
    })

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

  @tiles [
    "1m","2m","3m","4m","5m","6m","7m","8m","9m",
    "1p","2p","3p","4p","5p","6p","7p","8p","9p",
    "1s","2s","3s","4s","5s","6s","7s","8s","9s",
    "1z","2z","3z","4z","5z","6z","7z"
  ]
  def generate_room_name(state, tries_left \\ 1000) do
    if tries_left > 0 do
      room_name = Enum.join([Enum.random(@tiles), Enum.random(@tiles), Enum.random(@tiles)], " ")
      if Map.has_key?(state.rooms, room_name) do
        generate_room_name(state, tries_left - 1)
      else
        room_name
      end
    else nil end
  end

  def handle_call({:new_player, socket}, _from, state) do
    GenServer.call(state.exit_monitor, {:new_player, socket.root_pid, socket.id})
    nickname = if socket.assigns.nickname != "" do socket.assigns.nickname else "player" <> String.slice(socket.id, 10, 4) end
    state = put_in(state.players[socket.id], %LobbyPlayer{nickname: nickname, id: socket.id})
    IO.puts("Player #{socket.id} joined")
    state = broadcast_state_change(state)
    {:reply, [state], state}
  end

  def handle_call({:delete_player, socket_id}, _from, state) do
    {_, state} = pop_in(state.players[socket_id])
    IO.puts("Player #{socket_id} exited")
    state = if Enum.empty?(state.players) do
      # all players have left, shutdown
      IO.puts("Stopping lobby #{state.session_id}")
      DynamicSupervisor.terminate_child(RiichiAdvanced.LobbySessionSupervisor, state.supervisor)
      state
    else
      state = broadcast_state_change(state)
      state
    end
    {:reply, :ok, state}
  end

  def handle_call(:create_room, _from, state) do
    case generate_room_name(state) do
      nil       -> {:reply, :no_names_remaining, state}
      room_name ->
        state = Map.put(state.rooms, room_name, %LobbyRoom{})
        {:reply, {:ok, room_name}, state}
    end
  end

  def handle_cast({:enter_room, _socket_id, _room_name}, state) do
    # TODO
    # running_games = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", ruleset, session_id))
    # if Enum.empty?(running_games) do
    # else
    #   push_navigate(socket, to: ~p"/game/#{ruleset}/#{session_id}?nickname=#{nickname}")
    # end
    state = broadcast_state_change(state)
    {:noreply, state}
  end

end
