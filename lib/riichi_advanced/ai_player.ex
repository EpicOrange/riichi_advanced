defmodule RiichiAdvanced.AIPlayer do
  use GenServer

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: init_state[:name])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:your_turn, %{player: player}}, state) do
    state = %{ state | player: player }
    playable_hand = player.hand
      |> Enum.with_index()
      |> Enum.filter(fn {tile, _i} -> GenServer.call(state.game_state, {:is_playable, state.seat, tile, :hand}) end)
    playable_draw = player.draw
      |> Enum.with_index()
      |> Enum.filter(fn {tile, _i} -> GenServer.call(state.game_state, {:is_playable, state.seat, tile, :draw}) end)
      |> Enum.map(fn {tile, i} -> {tile, i + length(player.hand)} end)
    playables = playable_hand ++ playable_draw

    if not Enum.empty?(playables) do
      # pick a random tile
      # {tile, index} = Enum.random(playables)
      # pick the first playable tile
      # {tile, index} = Enum.at(playables, 0)
      # pick the last playable tile (the draw)
      {_tile, index} = Enum.at(playables, -1)
      # IO.puts(" >> #{state.seat}: It's my turn to play a tile! #{inspect(playables)} / chose: #{inspect(tile)}")
      Process.sleep(1500)
      GenServer.cast(state.game_state, {:play_tile, state.seat, index})
    end
    {:noreply, state}
  end

  def handle_info({:buttons, %{player: player}}, state) do
    state = %{ state | player: player }
    # pick a random button
    # button_name = Enum.random(player.buttons)
    # pick the first button
    button_name = Enum.at(player.buttons, 1)
    # IO.puts(" >> #{state.seat}: It's my turn to press buttons! #{inspect(player.buttons)} / chose: #{button_name}")
    Process.sleep(500)
    GenServer.cast(state.game_state, {:press_button, state.seat, button_name})
    {:noreply, state}
  end

  def handle_info({:call_buttons, %{player: player}}, state) do
    state = %{ state | player: player }
    # pick a random call
    called_tile = player.call_buttons
      |> Map.keys()
      |> Enum.filter(fn tile -> not Enum.empty?(player.call_buttons[tile]) end)
      |> Enum.random()
    call_choice = Enum.random(player.call_buttons[called_tile])
    # IO.puts(" >> #{state.seat}: It's my turn to press call buttons! #{inspect(player.call_buttons)} / chose: #{inspect(called_tile)} #{inspect(call_choice)}")
    Process.sleep(500)
    GenServer.cast(state.game_state, {:run_deferred_actions, %{seat: state.seat, call_name: player.call_name, call_choice: call_choice, called_tile: called_tile}})
    {:noreply, state}
  end
end