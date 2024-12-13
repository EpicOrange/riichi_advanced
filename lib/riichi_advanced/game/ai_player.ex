defmodule RiichiAdvanced.AIPlayer do
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Marking, as: Marking
  use GenServer

  @ai_speed 4

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: init_state[:name])
  end

  def init(state) do
    state = Map.put(state, :initialized, false)
    state = Map.put(state, :shanten, 6)
    state = Map.put(state, :preselected_flower, nil)
    if Debug.debug_fast_ai() do
      :timer.apply_after(100, Kernel, :send, [self(), :initialize])
    else
      :timer.apply_after(2500, Kernel, :send, [self(), :initialize])
    end
    {:ok, state}
  end

  defp choose_playable_tile(tiles, playables, player, wall, visible_tiles, win_definition) do
    if not Enum.empty?(playables) do
      # rank each playable tile by the ukeire it gives for the next shanten step
      # TODO as well as heuristics provided by the ruleset
      hand = player.hand ++ player.draw
      calls = player.calls
      ordering = player.tile_ordering
      ordering_r = player.tile_ordering_r
      tile_aliases = player.tile_aliases
      # use ukeire (if we don't have wildcard jokers)
      use_ukeire = map_size(player.tile_aliases) < 34
      best_playables = if use_ukeire do
        playable_waits = playables
        |> Enum.filter(fn {tile, _ix} -> Enum.any?(tiles, &Utils.same_tile(tile, &1)) end)
        |> Enum.map(fn {tile, ix} ->
          if win_definition != nil do
            {tile, ix, Riichi.get_waits_and_ukeire(hand -- [tile], calls, win_definition, wall, visible_tiles, ordering, ordering_r, tile_aliases, true)}
          else {tile, ix, %{}} end
        end)

        # prefer highest ukeire
        ukeires = Enum.map(playable_waits, fn {tile, ix, waits} -> {tile, ix, Map.values(waits) |> Enum.sum()} end)
        max_ukeire = ukeires
        |> Enum.map(fn {_tile, _ix, outs} -> outs end)
        |> Enum.max(&>=/2, fn -> 0 end)
        best_playables_by_ukeire = for {tile, ix, outs} <- ukeires, outs == max_ukeire do {tile, ix} end
        best_playables_by_ukeire
      else playables end

      # prefer outer discards
      {yaochuuhai, rest} = Enum.split_with(best_playables, fn {tile, _ix} -> Riichi.is_yaochuuhai?(tile) end)
      {tiles28, rest} = Enum.split_with(rest, fn {tile, _ix} -> Riichi.is_num?(tile, 2) || Riichi.is_num?(tile, 8) end) 
      {tiles37, rest} = Enum.split_with(rest, fn {tile, _ix} -> Riichi.is_num?(tile, 3) || Riichi.is_num?(tile, 7) end) 
      for playable_tiles <- [yaochuuhai, tiles28, tiles37, rest], reduce: nil do
        nil -> if not Enum.empty?(playable_tiles) do Enum.random(playable_tiles) else nil end
        ret -> ret
      end
    else nil end
  end

  defp choose_discard(state, player, playables, wall, visible_tiles) do
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
    ]
    win_definitions = [
      state.shanten_definitions.win,
      state.shanten_definitions.tenpai,
      state.shanten_definitions.iishanten,
      state.shanten_definitions.ryanshanten
    ]
    shanten_definitions = Enum.zip(shanten_definitions, win_definitions) |> Enum.with_index()
    # skip tenpai check if 2-shanten, skip tenpai and 1-shanten check if 3-shanten
    shanten_definitions = case state.shanten do
      2 -> shanten_definitions |> Enum.drop(1)
      3 -> shanten_definitions |> Enum.drop(2)
      _ -> shanten_definitions
    end

    # check if tenpai
    {ret, shanten} = for {{shanten_definition, win_definition}, i} <- shanten_definitions, reduce: {nil, 6} do
      {nil, _} ->
        ret = Riichi.get_unneeded_tiles(hand, calls, shanten_definition, ordering, ordering_r, tile_aliases)
        |> choose_playable_tile(playables, player, wall, visible_tiles, win_definition)
        # if ret != nil do
        #   IO.puts(" >> #{state.seat}: I'm currently #{i}-shanten!")
        # end
        {ret, i}
      ret -> ret
    end

    if ret == nil do # shanten > 3
      ret = Riichi.get_disconnected_tiles(hand, ordering, ordering_r, tile_aliases)
      |> choose_playable_tile(playables, player, wall, visible_tiles, nil)
      {ret, 6}
    else {ret, shanten} end
  end

  defp get_mark_choices(source, players, revealed_tiles, num_scryed_tiles, wall) do
    if source in Marking.special_keys() do
      []
    else
      case source do
        :hand          -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.hand ++ p.draw, &{seat, source, &1}) |> Enum.with_index() end)
        :call          -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.calls, &{seat, source, &1}) |> Enum.with_index() end)
        :discard       -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.pond, &{seat, source, &1}) |> Enum.with_index() end)
        :aside         -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.aside, &{seat, source, &1}) |> Enum.with_index() end)
        :revealed_tile -> revealed_tiles |> Enum.map(&{nil, source, &1}) |> Enum.with_index()
        :scry          -> wall |> Enum.take(num_scryed_tiles) |> Enum.map(&{nil, source, &1}) |> Enum.with_index()
        _              ->
          IO.puts("AI does not recognize the mark source #{inspect(source)}")
          {nil, nil, nil}
      end
    end
  end

  defp get_minefield_discard_danger(minefield_tiles, waits, wall, visible_tiles, tile, ordering, ordering_r) do
    # really dumb heuristic for now
    genbutsu = Utils.strip_attrs(visible_tiles -- minefield_tiles)
    suji = Riichi.genbutsu_to_suji(genbutsu, ordering, ordering_r)
    seen_count = Enum.count(visible_tiles, & &1 == tile)
    centralness = cond do
      Riichi.is_num?(tile, 2) -> 1
      Riichi.is_num?(tile, 3) -> 2
      Riichi.is_num?(tile, 4) -> 3
      Riichi.is_num?(tile, 5) -> 3
      Riichi.is_num?(tile, 6) -> 3
      Riichi.is_num?(tile, 7) -> 2
      Riichi.is_num?(tile, 8) -> 1
      true                    -> 0
    end
    # true & higher numbers = don't discard
    {tile not in genbutsu, tile in waits, tile not in suji, -seen_count, centralness}
  end

  def handle_info(:initialize, state) do
    state = Map.put(state, :initialized, true)
    GenServer.cast(state.game_state, :notify_ai)
    {:noreply, state}
  end

  def handle_info({:your_turn, params}, state) do
    t = System.os_time(:millisecond)
    %{player: player, wall: wall, visible_tiles: visible_tiles} = params
    if state.initialized do
      if GenServer.call(state.game_state, {:can_discard, state.seat}) do
        state = %{ state | player: player }
        playable_hand = player.hand
        |> Enum.with_index()
        playable_draw = player.draw
        |> Enum.with_index()
        |> Enum.map(fn {tile, i} -> {tile, i + length(player.hand)} end)
        playables = playable_hand ++ playable_draw
        |> Enum.filter(fn {tile, _i} -> GenServer.call(state.game_state, {:is_playable, state.seat, tile}) end)

        if not Enum.empty?(playables) do
          # pick a random tile
          # {_tile, index} = Enum.random(playables)
          # pick the first playable tile
          # {_tile, index} = Enum.at(playables, 0)
          # pick the last playable tile (the draw)
          # {_tile, index} = Enum.at(playables, -1)
          # use our rudimentary AI for discarding
          # IO.puts(" >> #{state.seat}: Hand: #{inspect(Utils.sort_tiles(player.hand ++ player.draw))}")
          {{tile, index}, shanten} = if Debug.debug() do
            {Enum.at(playables, -1), 6}
          else
            case choose_discard(state, player, playables, wall, visible_tiles) do
              {nil, _} ->
                # IO.puts(" >> #{state.seat}: Couldn't find a tile to discard! Doing tsumogiri instead")
                {Enum.at(playables, -1), 6} # tsumogiri, or last playable tile
              t -> t
            end
          end
          state = Map.put(state, :shanten, shanten)
          # IO.puts(" >> #{state.seat}: It's my turn to play a tile! #{inspect(playables)} / chose: #{inspect(tile)}")
          elapsed_time = System.os_time(:millisecond) - t
          wait_time = trunc(1200 / @ai_speed)
          if elapsed_time < wait_time do
            Process.sleep(wait_time - elapsed_time)
          end

          # if we're about to discard a joker/flower, call it instead
          tile = Utils.strip_attrs(tile)
          button_name = cond do
            "flower" in player.buttons -> "flower"
            "joker" in player.buttons -> "joker"
            true -> nil
          end
          choice = if button_name != nil do
            {:call, choices} = player.button_choices[button_name]
            Enum.find(choices[nil], fn [choice] -> Utils.same_tile(choice, tile) end)
          else nil end
          state = if choice != nil do
            GenServer.cast(state.game_state, {:press_button, state.seat, button_name})
            Map.put(state, :preselected_flower, tile)
          else
            GenServer.cast(state.game_state, {:play_tile, state.seat, index})
            state
          end
          {:noreply, state}
        else
          IO.puts(" >> #{state.seat}: It's my turn to play a tile, but there are no tiles I can play")
          {:noreply, state}
        end
      else
        IO.puts(" >> #{state.seat}: You said it's my turn to play a tile, but I am not in a state in which I can discard")
        {:noreply, state}
      end
    else
      # reschedule this for after we initialize
      :timer.apply_after(1000, Kernel, :send, [self(), {:your_turn, params}])
      {:noreply, state}
    end
  end

  def handle_info({:buttons, %{player: player, turn: turn}}, state) do
    t = System.os_time(:millisecond)
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
          # "daiminkan" in player.buttons -> "daiminkan"
          # "pon" in player.buttons -> "pon"
          # "chii" in player.buttons -> "chii"
          "anfuun" in player.buttons -> "anfuun"
          "flower" in player.buttons -> "flower"
          "pei" in player.buttons -> "pei"
          "start_flower" in player.buttons -> "start_flower"
          "start_no_flower" in player.buttons -> "start_no_flower"
          "continue_charleston" in player.buttons -> "continue_charleston"
          "am_quint" in player.buttons -> "am_quint"
          "am_kong" in player.buttons -> "am_kong"
          # "am_pung" in player.buttons -> "am_pung"
          "am_joker_swap" in player.buttons -> "am_joker_swap"
          "extra_turn" in player.buttons -> "extra_turn"
          "skip" in player.buttons -> "skip"
          true -> Enum.random(player.buttons)
        end
      end
      # IO.puts(" >> #{state.seat}: It's my turn to press buttons! #{inspect(player.buttons)} / chose: #{button_name}")
      elapsed_time = System.os_time(:millisecond) - t
      wait_time = trunc(500 / @ai_speed)
      if elapsed_time < wait_time do
        Process.sleep(wait_time - elapsed_time)
      end
      if button_name == "skip" && state.seat == turn && Enum.empty?(player.deferred_actions) do
        GenServer.cast(state.game_state, {:ai_ignore_buttons, state.seat})
      else
        GenServer.cast(state.game_state, {:press_button, state.seat, button_name})
      end
      state = Map.put(state, :preselected_flower, nil)
      {:noreply, state}
    else
      # reschedule this for after we initialize
      :timer.apply_after(1000, Kernel, :send, [self(), {:buttons, %{player: player, turn: turn}}])
      {:noreply, state}
    end
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
        {called_tile, call_choice} = if state.preselected_flower != nil do
          {nil, [state.preselected_flower]}
        else
          {called_tile, Enum.random(player.call_buttons[called_tile])}
        end
        # IO.puts(" >> #{state.seat}: It's my turn to press call buttons! #{inspect(player.call_buttons)} / chose: #{inspect(called_tile)} #{inspect(call_choice)}")
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:press_call_button, state.seat, call_choice, called_tile})
      else
        [choice] = Enum.random(player.call_buttons["saki"])
        # IO.puts(" >> #{state.seat}: It's my turn to choose a saki card! #{inspect(player.call_buttons)} / chose: #{inspect(choice)}")
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:press_saki_card, state.seat, choice})
      end
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:mark_tiles, %{player: player, players: players, visible_tiles: visible_tiles, revealed_tiles: revealed_tiles, wall: wall, marked_objects: marked_objects}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      IO.puts(" >> #{state.seat}: It's my turn to mark tiles!")
      # for each source, generate all possible choices and pick one of them
      Process.sleep(trunc(500 / @ai_speed)) 
      choices = marked_objects
      |> Enum.reject(fn {source, mark_info} -> source in Marking.special_keys() || (mark_info != nil && length(mark_info.marked) >= mark_info.needed) end)
      |> Enum.flat_map(fn {source, _mark_info} -> get_mark_choices(source, players, revealed_tiles, player.num_scryed_tiles, wall) end)
      |> Enum.filter(fn {{seat, source, _obj}, i} -> GenServer.call(state.game_state, {:can_mark?, state.seat, seat, i, source}) end)
      |> Enum.shuffle()

      {state, choices} = if state.ruleset == "minefield" do
        cond do
          Marking.is_marking?(marked_objects, :hand) ->
            # initial hand
            state = if not Map.has_key?(state, :minefield_hand) || Map.get(state, :minefield_tiles, []) != player.hand do
              minefield_hand = GenServer.call(state.game_state, {:get_best_minefield_hand, state.seat, state.shanten_definitions.win}, 30000)
              minefield_waits = Riichi.get_waits(player.hand, [], state.shanten_definitions.win, wall, player.tile_ordering, player.tile_ordering_r, player.tile_aliases, true)
              state
              |> Map.put(:minefield_tiles, player.hand)
              |> Map.put(:minefield_hand, minefield_hand)
              |> Map.put(:minefield_waits, minefield_waits)
            else state end
            remaining_tiles = state.minefield_hand -- Enum.map(Marking.get_marked(marked_objects, :hand), fn {tile, _seat, _ix} -> tile end)
            {state, Enum.filter(choices, fn {{_seat, _source, tile}, _i} -> tile in remaining_tiles end)}
          Marking.is_marking?(marked_objects, :aside) ->
            # discard
            choice = Enum.min_by(choices, fn {{_seat, _source, tile}, _i} -> get_minefield_discard_danger(state.minefield_tiles, state.minefield_waits, wall, visible_tiles, tile, player.tile_ordering, player.tile_ordering_r) end, &<=/2, fn -> nil end)
            {state, if choice == nil do [] else [choice] end}
          true -> {state, choices}
        end
      else {state, choices} end

      case choices do
        [{{seat, source, _obj}, i} | _] -> GenServer.cast(state.game_state, {:mark_tile, state.seat, seat, i, source})
        _ ->
          IO.puts(" >> #{state.seat}: Unfortunately I cannot mark anything")
          IO.puts(" >> #{state.seat}: My choices were: #{inspect(choices)}")
          IO.puts(" >> #{state.seat}: My marking state was: #{inspect(marked_objects)}")
          GenServer.cast(state.game_state, {:clear_marked_objects, state.seat})
      end
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:declare_yaku, %{player: player}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      IO.puts(" >> #{state.seat}: It's my turn to declare yaku!")
      GenServer.cast(state.game_state, {:declare_yaku, state.seat, ["Riichi"]})
      {:noreply, state}
    else
      {:noreply, state}
    end
  end
end