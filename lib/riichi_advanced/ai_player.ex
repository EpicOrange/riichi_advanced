defmodule RiichiAdvanced.AIPlayer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: args[:name])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:your_turn, %{player: player}}, state) do
    state = %{ state | player: player }
    # pick a random tile
    index = Enum.random(1..length(player.hand)) - 1
    tile = Enum.at(player.hand, index)
    IO.puts("#{state.seat}: It's my turn to play a tile! #{inspect(player.hand)} / chose: #{inspect(tile)}")
    Process.sleep(2000)
    RiichiAdvanced.GlobalState.run_actions([["play_tile", tile, index], ["advance_turn"]], %{seat: state.seat})
    {:noreply, state}
  end

  def handle_info({:buttons, %{player: player}}, state) do
    state = %{ state | player: player }
    # pick a random button
    button_name = Enum.random(player.buttons)
    IO.puts("#{state.seat}: It's my turn to press buttons! #{inspect(player.buttons)} / chose: #{button_name}")
    Process.sleep(200)
    RiichiAdvanced.GlobalState.press_button(state.seat, button_name)
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
    IO.puts("#{state.seat}: It's my turn to press call buttons! #{inspect(player.call_buttons)} / chose: #{inspect(called_tile)} #{inspect(call_choice)}")
    Process.sleep(200)
    RiichiAdvanced.GlobalState.run_actions([], %{seat: state.seat, call_name: player.call_name, call_choice: call_choice, called_tile: called_tile})
    {:noreply, state}
  end
end