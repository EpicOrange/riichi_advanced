defmodule RiichiAdvanced.AIPlayer do
  use GenServer

  @ai_speed 4

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: init_state[:name])
  end

  def init(state) do
    state = Map.put(state, :initialized, false)
    state = Map.put(state, :shanten, 6)
    if RiichiAdvanced.GameState.Debug.debug_fast_ai() do
      :timer.apply_after(100, Kernel, :send, [self(), :initialize])
    else
      :timer.apply_after(3000, Kernel, :send, [self(), :initialize])
    end
    {:ok, state}
  end

  def choose_playable_tile(tiles, playables) do
    # prefer outer discards
    {yaochuuhai, rest} = Enum.split_with(tiles, &Riichi.is_yaochuuhai?/1)
    {tiles28, rest} = Enum.split_with(rest, &Riichi.is_num?(&1, 2) || Riichi.is_num?(&1, 8)) 
    {tiles37, rest} = Enum.split_with(rest, &Riichi.is_num?(&1, 3) || Riichi.is_num?(&1, 7)) 
    for tiles <- [yaochuuhai, tiles28, tiles37, rest], reduce: nil do
      nil ->
        playable_tiles = Enum.filter(playables, fn {tile, _ix} -> Enum.any?(tiles, &Utils.same_tile(tile, &1)) end)
        if not Enum.empty?(playable_tiles) do Enum.random(playable_tiles) else nil end
      ret -> ret
    end
  end

  def choose_discard(state, player, playables) do
    hand = player.hand ++ player.draw
    calls = player.calls
    ordering = player.tile_ordering
    ordering_r = player.tile_ordering_r
    tile_aliases = player.tile_aliases
    shanten_definitions = [
      state.shanten_definitions.tenpai,
      state.shanten_definitions.iishanten,
      state.shanten_definitions.ryanshanten,
      state.shanten_definitions.sanshanten
    ] |> Enum.with_index()
    # skip tenpai check if 2-shanten, skip tenpai and 1-shanten check if 3-shanten
    shanten_definitions = case state.shanten do
      2 -> shanten_definitions |> Enum.drop(1)
      3 -> shanten_definitions |> Enum.drop(2)
      _ -> shanten_definitions
    end

    # check if tenpai
    {ret, shanten} = for {shanten_definition, i} <- shanten_definitions, reduce: {nil, 6} do
      {nil, _} ->
        ret = Riichi.get_unneeded_tiles(hand, calls, shanten_definition, ordering, ordering_r, tile_aliases)
        |> choose_playable_tile(playables)
        # if ret != nil do
        #   IO.puts(" >> #{state.seat}: I'm currently #{i}-shanten!")
        # end
        {ret, i}
      ret -> ret
    end

    if ret == nil do # shanten > 3
      ret = Riichi.get_disconnected_tiles(hand, ordering, ordering_r, tile_aliases)
      |> choose_playable_tile(playables)
      {ret, 6}
    else {ret, shanten} end
  end

  def handle_info(:initialize, state) do
    state = Map.put(state, :initialized, true)
    GenServer.cast(state.game_state, :notify_ai)
    {:noreply, state}
  end

  def handle_info({:your_turn, %{player: player}}, state) do
    if state.initialized && GenServer.call(state.game_state, {:can_discard, state.seat}) do
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
        # {_tile, index} = Enum.random(playables)
        # pick the first playable tile
        # {_tile, index} = Enum.at(playables, 0)
        # pick the last playable tile (the draw)
        # {_tile, index} = Enum.at(playables, -1)
        # use our rudimentary AI for discarding
        # IO.puts(" >> #{state.seat}: Hand: #{inspect(Utils.sort_tiles(player.hand ++ player.draw))}")
        {{tile, index}, shanten} = case choose_discard(state, player, playables) do
          {nil, _} ->
            # IO.puts(" >> #{state.seat}: Couldn't find a tile to discard! Doing tsumogiri instead")
            Enum.at(playables, -1) # tsumogiri
          t -> t
        end
        # IO.puts(" >> #{state.seat}: It's my turn to play a tile! #{inspect(playables)} / chose: #{inspect(tile)}")
        Process.sleep(trunc(1200 / @ai_speed))
        GenServer.cast(state.game_state, {:play_tile, state.seat, index})
        {:noreply, Map.put(state, :shanten, shanten)}
      else
        IO.puts(" >> #{state.seat}: It's my turn to play a tile, but there are no tiles I can play")
        {:noreply, state}
      end
    else
      IO.puts(" >> #{state.seat}: You said it's my turn to play a tile, but I am not in a state in which I can discard")
      {:noreply, state}
    end
  end

  def handle_info({:buttons, %{player: player}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      # pick a random button
      # button_name = Enum.random(player.buttons)
      # pick the first button
      # button_name = Enum.at(player.buttons, 0)
      # pick the last button
      # button_name = Enum.at(player.buttons, -1)

      button_name = if "void_manzu" in player.buttons do
        # count suits, pick the minimum suit
        hand = player.hand ++ player.draw
        num_manzu = hand |> Enum.filter(&Riichi.is_manzu?/1) |> length()
        num_pinzu = hand |> Enum.filter(&Riichi.is_pinzu?/1) |> length()
        num_souzu = hand |> Enum.filter(&Riichi.is_souzu?/1) |> length()
        minimum = min(num_manzu, num_pinzu) |> min(num_souzu)
        cond do
          num_manzu == minimum -> "void_manzu"
          num_pinzu == minimum -> "void_pinzu"
          num_souzu == minimum -> "void_souzu"
        end
      else
        # pick these (in order of precedence)
        cond do
          "ron" in player.buttons -> "ron"
          "tsumo" in player.buttons -> "tsumo"
          "hu" in player.buttons -> "hu"
          "zimo" in player.buttons -> "zimo"
          "riichi" in player.buttons -> "riichi"
          "ankan" in player.buttons -> "ankan"
          "flower" in player.buttons -> "flower"
          "skip" in player.buttons -> "skip"
          true -> Enum.random(player.buttons)
        end
      end
      # IO.puts(" >> #{state.seat}: It's my turn to press buttons! #{inspect(player.buttons)} / chose: #{button_name}")
      Process.sleep(trunc(500 / @ai_speed))
      GenServer.cast(state.game_state, {:press_button, state.seat, button_name})
    end
    {:noreply, state}
  end

  def handle_info({:call_buttons, %{player: player}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      # pick a random call
      called_tile = player.call_buttons
        |> Map.keys()
        |> Enum.filter(fn tile -> not Enum.empty?(player.call_buttons[tile]) end)
        |> Enum.random()
      if called_tile != "saki" do
        call_choice = Enum.random(player.call_buttons[called_tile])
        # IO.puts(" >> #{state.seat}: It's my turn to press call buttons! #{inspect(player.call_buttons)} / chose: #{inspect(called_tile)} #{inspect(call_choice)}")
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:run_deferred_actions, %{seat: state.seat, call_name: player.call_name, call_choice: call_choice, called_tile: called_tile}})
      else
        [choice] = Enum.random(player.call_buttons["saki"])
        # IO.puts(" >> #{state.seat}: It's my turn to choose a saki card! #{inspect(player.call_buttons)} / chose: #{inspect(choice)}")
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:run_deferred_actions, %{seat: state.seat, choice: choice}})
      end
    end
    {:noreply, state}
  end

  def handle_info({:mark_tiles, %{player: player, marked_objects: marked_objects}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      IO.puts(" >> #{state.seat}: It's my turn to mark tiles!")
      # for each source, generate all possible choices and pick n of them
      # note: we only support marking our own hand and discards, for now
      # TODO support marking other players' hand and/or discards
      Process.sleep(trunc(500 / @ai_speed))
      if Map.has_key?(marked_objects, :hand) do
        player.hand ++ player.draw
        |> Enum.with_index()
        |> Enum.filter(fn {_tile, i} -> GenServer.call(state.game_state, {:can_mark?, state.seat, state.seat, i, :hand}) end)
        |> Enum.shuffle()
        |> Enum.take(marked_objects.hand.needed)
        |> Enum.each(fn {_tile, i} -> GenServer.cast(state.game_state, {:mark_tile, state.seat, state.seat, i, :hand}) end)
      end
      if Map.has_key?(marked_objects, :discard) do
        player.pond
        |> Enum.with_index()
        |> Enum.filter(fn {_tile, i} -> GenServer.call(state.game_state, {:can_mark?, state.seat, state.seat, i, :discard}) end)
        |> Enum.shuffle()
        |> Enum.take(marked_objects.discard.needed)
        |> Enum.each(fn {_tile, i} -> GenServer.cast(state.game_state, {:mark_tile, state.seat, state.seat, i, :discard}) end)
      end
    end
    {:noreply, state}
  end
end