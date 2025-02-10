defmodule RiichiAdvanced.AIPlayer do
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use GenServer

  @ai_speed 4

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: init_state[:name])
  end

  def init(state) do
    state = Map.put(state, :initialized, false)
    state = Map.put(state, :shanten, -1)
    state = Map.put(state, :preselected_flower, nil)
    if Debug.debug_fast_ai() do
      :timer.apply_after(100, Kernel, :send, [self(), :initialize])
    else
      :timer.apply_after(2500, Kernel, :send, [self(), :initialize])
    end
    {:ok, state}
  end

  defp choose_playable_tile(_tiles, _state, playables, _visible_tiles, _win_definition) do
    if not Enum.empty?(playables) do
      # rank each playable tile by the ukeire it gives for the next shanten step
      # TODO as well as heuristics provided by the ruleset
      # hand = state.player.hand ++ state.player.draw
      # calls = state.player.calls
      # tile_behavior = state.player.tile_behavior
      best_playables = playables

      # TODO ukeire counting is really slow
      # because we need "exhaustive" to check for waits in Riichi.get_waits_and_ukeire
      # disable it for now

      # use_ukeire = Enum.empty?(tile_behavior.aliases)
      # best_playables = if use_ukeire do
      #   playable_waits = playables
      #   |> Enum.filter(fn {tile, _ix} -> Enum.any?(tiles, &Utils.same_tile(tile, &1)) end)
      #   |> Enum.map(fn {tile, ix} ->
      #     if win_definition != nil do
      #       {tile, ix, Riichi.get_waits_and_ukeire(hand -- [tile], calls, win_definition, state.wall, visible_tiles, tile_behavior, true)}
      #     else {tile, ix, %{}} end
      #   end)

      #   # prefer highest ukeire
      #   ukeires = Enum.map(playable_waits, fn {tile, ix, waits} -> {tile, ix, Map.values(waits) |> Enum.sum()} end)
      #   max_ukeire = ukeires
      #   |> Enum.map(fn {_tile, _ix, outs} -> outs end)
      #   |> Enum.max(&>=/2, fn -> 0 end)
      #   best_playables_by_ukeire = for {tile, ix, outs} <- ukeires, outs == max_ukeire do {tile, ix} end
      #   best_playables_by_ukeire
      # else playables end

      # prefer outer discards
      {yaochuuhai, rest} = Enum.split_with(best_playables, fn {tile, _ix} -> Riichi.is_yaochuuhai?(tile) end)
      {tiles28, rest} = Enum.split_with(rest, fn {tile, _ix} -> Riichi.is_num?(tile, 2) or Riichi.is_num?(tile, 8) end) 
      {tiles37, rest} = Enum.split_with(rest, fn {tile, _ix} -> Riichi.is_num?(tile, 3) or Riichi.is_num?(tile, 7) end) 
      for playable_tiles <- [yaochuuhai, tiles28, tiles37, rest], reduce: nil do
        nil -> if not Enum.empty?(playable_tiles) do Enum.random(playable_tiles) else nil end
        ret -> ret
      end
    else nil end
  end

  defp choose_discard(state, playables, visible_tiles) do
    hand = state.player.hand ++ state.player.draw
    calls = state.player.calls
    tile_behavior = state.player.tile_behavior
    shanten_definitions = [
      {-1, state.shanten_definitions.win},
      {0,  state.shanten_definitions.tenpai},
      {1,  state.shanten_definitions.iishanten},
      {2,  state.shanten_definitions.ryanshanten},
      {3,  state.shanten_definitions.sanshanten},
      {4,  state.shanten_definitions.suushanten},
      {5,  state.shanten_definitions.uushanten},
      {6,  state.shanten_definitions.roushanten}
    ]
    shanten_definitions = Enum.drop(shanten_definitions, max(0, min(state.shanten, length(shanten_definitions) - 1) - 1))
    {ret, shanten} = for {{i, shanten_definition}, {_j, win_definition}} <- Enum.zip(Enum.drop(shanten_definitions, 1), Enum.drop(shanten_definitions, -1)), reduce: {nil, 6} do
      {nil, _} ->
        ret = Riichi.get_unneeded_tiles(hand, calls, shanten_definition, tile_behavior)
        |> choose_playable_tile(state, playables, visible_tiles, win_definition)
        if Debug.debug_ai() and ret != nil do
          IO.puts(" >> #{state.seat}: I'm currently #{i}-shanten!")
        end
        {ret, i}
      ret -> ret
    end

    if ret == nil do # shanten > 6?
      ret = Riichi.get_disconnected_tiles(hand, tile_behavior)
      |> choose_playable_tile(state, playables, visible_tiles, nil)
      {ret, :infinity}
    else {ret, shanten} end
  end

  defp choose_american_discard(state, playables, closest_american_hands) do
    # get shanten
    shanten = closest_american_hands
    |> Enum.map(fn {_am_match_definition, pairing_r, _arranged_hand} -> 13 - map_size(pairing_r) end)
    |> Enum.min(&<=/2, fn -> :infinity end)
    # take only the best closest hands
    closest_american_hands = Enum.filter(closest_american_hands, fn {_am_match_definition, pairing_r, _arranged_hand} -> shanten == (13 - map_size(pairing_r)) end)
    # rank playables by how often they appear in closest hands
    usages = for {_am_match_definition, pairing_r, _arranged_hand} <- closest_american_hands, reduce: Map.new(playables, fn {_tile, i} -> {i, 0} end) do
      usages -> Map.merge(usages, Map.keys(pairing_r) |> Enum.frequencies(), fn _k, v1, v2 -> v1 + v2 end)
    end
    ret = playables
    |> Enum.min_by(fn {_tile, i} -> usages[i] end, &<=/2, fn -> nil end)
    if Debug.debug_ai() and ret != nil do
      IO.puts(" >> #{state.seat}: I'm currently #{shanten}-shanten!")
    end
    {ret, shanten}
  end

  defp get_mark_choices(state, source, players, revealed_tiles, num_scryed_tiles) do
    if source in Marking.special_keys() do
      []
    else
      case source do
        :hand          -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.hand ++ p.draw, &{seat, source, &1}) |> Enum.with_index() end)
        :calls         -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.calls, &{seat, source, &1}) |> Enum.with_index() end)
        :discard       -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.pond, &{seat, source, &1}) |> Enum.with_index() end)
        :aside         -> Enum.flat_map(players, fn {seat, p} -> Enum.map(p.aside, &{seat, source, &1}) |> Enum.with_index() end)
        :revealed_tile -> revealed_tiles |> Enum.map(&{nil, source, &1}) |> Enum.with_index()
        :scry          -> state.wall |> Enum.take(num_scryed_tiles) |> Enum.map(&{nil, source, &1}) |> Enum.with_index()
        _              ->
          IO.puts("AI does not recognize the mark source #{inspect(source)}")
          {nil, nil, nil}
      end
    end
  end

  defp get_minefield_discard_danger(minefield_tiles, waits, wall, doras, visible_tiles, tile, tile_behavior) do
    # really dumb heuristic for now
    genbutsu = Utils.strip_attrs(visible_tiles -- minefield_tiles)
    suji = Riichi.genbutsu_to_suji(genbutsu, tile_behavior)
    hidden_count = Enum.count(wall -- visible_tiles, & &1 == tile)
    centralness = Riichi.get_centralness(tile)
    # true & higher numbers = don't discard
    {tile not in genbutsu, tile in waits, tile not in suji, tile in doras, hidden_count, centralness}
  end

  def handle_info(:initialize, state) do
    state = Map.put(state, :initialized, true)
    GenServer.cast(state.game_state, :notify_ai)
    {:noreply, state}
  end

  def handle_info({:your_turn, params}, state) do
    t = System.os_time(:millisecond)
    %{player: player, visible_tiles: visible_tiles, closest_american_hands: closest_american_hands} = params
    if state.initialized do
      state = Map.put(state, :player, player)
      if GenServer.call(state.game_state, {:can_discard, state.seat}) do
        state = Map.put(state, :player, player)
        playable_hand = player.hand
        |> Enum.with_index()
        playable_draw = player.draw
        |> Enum.with_index()
        |> Enum.map(fn {tile, i} -> {tile, i + length(player.hand)} end)
        playables = playable_hand ++ playable_draw
        |> Enum.filter(fn {tile, _i} -> GenServer.call(state.game_state, {:is_playable, state.seat, tile}) end)

        non_voided_playables = cond do
          "void_manzu" in player.status -> Enum.filter(playables, fn {tile, _i} -> Riichi.is_manzu?(tile) end)
          "void_pinzu" in player.status -> Enum.filter(playables, fn {tile, _i} -> Riichi.is_pinzu?(tile) end)
          "void_souzu" in player.status -> Enum.filter(playables, fn {tile, _i} -> Riichi.is_souzu?(tile) end)
          true -> []
        end
        playables = if Enum.empty?(non_voided_playables) do playables else non_voided_playables end

        if not Enum.empty?(playables) do
          # pick a random tile
          # {_tile, index} = Enum.random(playables)
          # pick the first playable tile
          # {_tile, index} = Enum.at(playables, 0)
          # pick the last playable tile (the draw)
          # {_tile, index} = Enum.at(playables, -1)
          # use our rudimentary AI for discarding
          if Debug.debug_ai() do
            IO.puts(" >> #{state.seat}: Hand: #{inspect(Utils.sort_tiles(player.hand ++ player.draw))}")
          end
          GenServer.cast(state.game_state, {:ai_thinking, state.seat})
          {{tile, index}, shanten} = cond do
            Debug.debug() -> {Enum.at(playables, -1), :infinity} # tsumogiri
            state.ruleset == "american" ->
              case choose_american_discard(state, playables, closest_american_hands) do
                {nil, _} ->
                  if Debug.debug_ai() do
                    IO.puts(" >> #{state.seat}: Couldn't find a tile to discard! Doing tsumogiri instead")
                  end
                  {Enum.at(playables, -1), :infinity} # tsumogiri, or last playable tile
                t -> t
              end
            true ->
              case choose_discard(state, playables, visible_tiles) do
                {nil, _} ->
                  if Debug.debug_ai() do
                    IO.puts(" >> #{state.seat}: Couldn't find a tile to discard! Doing tsumogiri instead")
                  end
                  {Enum.at(playables, -1), :infinity} # tsumogiri, or last playable tile
                t -> t
              end
          end
          state = Map.put(state, :shanten, shanten)
          if Debug.debug_ai() do
            IO.puts(" >> #{state.seat}: It's my turn to play a tile! #{inspect(playables)} / chose: #{inspect(tile)}")
          end
          elapsed_time = System.os_time(:millisecond) - t
          wait_time = trunc(1200 / @ai_speed)
          if elapsed_time < wait_time do
            Process.sleep(wait_time - elapsed_time)
          else
            if Debug.debug_ai() do
              IO.puts(" >> #{state.seat}: Took #{System.os_time(:millisecond) - t} ms to come to a decision")
            end
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
          if Debug.debug_ai() do
            IO.puts(" >> #{state.seat}: It's my turn to play a tile, but there are no tiles I can play")
          end
          {:noreply, state}
        end
      else
        if Debug.debug_ai() do
          IO.puts(" >> #{state.seat}: You said it's my turn to play a tile, but I am not in a state in which I can discard")
        end
        {:noreply, state}
      end
    else
      # reschedule this for after we initialize
      :timer.apply_after(1000, Kernel, :send, [self(), {:your_turn, params}])
      {:noreply, state}
    end
  end

  def handle_info({:buttons, params}, state) do
    t = System.os_time(:millisecond)
    %{player: player, turn: turn, last_discard: last_discard} = params
    if state.initialized do
      state = Map.put(state, :player, player)
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
          "ron" in player.buttons and Match.match_hand(player.hand ++ [last_discard], player.calls, state.shanten_definitions.win, player.tile_behavior) -> "ron"
          "tsumo" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.win, player.tile_behavior) -> "tsumo"
          "hu" in player.buttons and Match.match_hand(player.hand ++ [last_discard], player.calls, state.shanten_definitions.win, player.tile_behavior) -> "hu"
          "zimo" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.win, player.tile_behavior) -> "zimo"
          "mahjong_discard" in player.buttons and Match.match_hand(player.hand ++ [last_discard], player.calls, state.shanten_definitions.win, player.tile_behavior) -> "mahjong_discard"
          "mahjong_draw" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.win, player.tile_behavior) -> "mahjong_draw"
          "mahjong_heavenly" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.win, player.tile_behavior) -> "mahjong_draw"
          "riichi" in player.buttons and Match.match_hand(player.hand ++ player.draw, player.calls, state.shanten_definitions.tenpai, player.tile_behavior) -> "riichi"
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
      if Debug.debug_ai() do
        IO.puts(" >> #{state.seat}: It's my turn to press buttons! #{inspect(player.buttons)} / chose: #{button_name}")
      end
      elapsed_time = System.os_time(:millisecond) - t
      wait_time = trunc(120 / @ai_speed)
      if button_name != "skip" do
        if elapsed_time < wait_time do
          Process.sleep(wait_time - elapsed_time)
        else
          if Debug.debug_ai() do
            IO.puts(" >> #{state.seat}: Took #{System.os_time(:millisecond) - t} ms to come to a decision")
          end
        end
      end
      if button_name == "skip" and state.seat == turn and Enum.empty?(player.deferred_actions) do
        GenServer.cast(state.game_state, {:ai_ignore_buttons, state.seat})
      else
        GenServer.cast(state.game_state, {:press_button, state.seat, button_name})
      end
      state = Map.put(state, :preselected_flower, nil)
      {:noreply, state}
    else
      # reschedule this for after we initialize
      :timer.apply_after(1000, Kernel, :send, [self(), {:buttons, params}])
      {:noreply, state}
    end
  end

  def handle_info({:call_buttons, %{player: player}}, state) do
    if state.initialized do
      state = Map.put(state, :player, player)
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
        if Debug.debug_ai() do
          IO.puts(" >> #{state.seat}: It's my turn to press call buttons! #{inspect(player.call_buttons)} / chose: #{inspect(called_tile)} #{inspect(call_choice)}")
        end
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:press_call_button, state.seat, call_choice, called_tile})
      else
        [choice] = Enum.random(player.call_buttons["saki"])
        if Debug.debug_ai() do
          IO.puts(" >> #{state.seat}: It's my turn to choose a saki card! #{inspect(player.call_buttons)} / chose: #{inspect(choice)}")
        end
        Process.sleep(trunc(500 / @ai_speed))
        GenServer.cast(state.game_state, {:press_saki_card, state.seat, choice})
      end
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:set_best_minefield_hand, minefield_tiles, minefield_hand}, state) do
    minefield_waits = Riichi.get_waits(minefield_hand, [], state.shanten_definitions.win, state.wall, state.player.tile_behavior, true)
    state = state
    |> Map.put(:minefield_tiles, minefield_tiles)
    |> Map.put(:minefield_hand, minefield_hand)
    |> Map.put(:minefield_waits, minefield_waits)
    {:noreply, state}
  end

  def handle_info({:mark_tiles, %{player: player, players: players, visible_tiles: visible_tiles, revealed_tiles: revealed_tiles, doras: doras, marked_objects: marked_objects, closest_american_hands: closest_american_hands}}, state) do
    if state.initialized do
      state = Map.put(state, :player, player)
      if Debug.debug_ai() do
        IO.puts(" >> #{state.seat}: It's my turn to mark tiles!")
      end
      # for each source, generate all possible choices and pick one of them
      Process.sleep(trunc(500 / @ai_speed)) 
      choices = marked_objects
      |> Enum.reject(fn {source, mark_info} -> source in Marking.special_keys() or (mark_info != nil and length(mark_info.marked) >= mark_info.needed) end)
      |> Enum.flat_map(fn {source, _mark_info} -> get_mark_choices(state, source, players, revealed_tiles, player.num_scryed_tiles) end)
      |> Enum.filter(fn {{seat, source, _obj}, i} -> GenServer.call(state.game_state, {:can_mark?, state.seat, seat, i, source}) end)
      |> Enum.shuffle()

      has_minefield_hand = if length(player.hand) == 34 do
        Map.get(state, :minefield_tiles, nil) == player.hand
      else Map.has_key?(state, :minefield_hand) end
      {state, choices} = case state.ruleset do
        "minefield" ->
          cond do
            Marking.is_marking?(marked_objects, :hand) and length(player.hand) == 34 ->
              # marking stage
              if has_minefield_hand do
                remaining_tiles = state.minefield_hand -- Enum.map(Marking.get_marked(marked_objects, :hand), fn {tile, _seat, _ix} -> tile end)
                {state, Enum.filter(choices, fn {{_seat, _source, tile}, _i} -> tile in remaining_tiles end)}
              else
                GenServer.cast(state.game_state, {:ai_thinking, state.seat})
                GenServer.cast(state.game_state, {:get_best_minefield_hand, state.seat, state.shanten_definitions.win})
                {state, []}
              end
            Marking.is_marking?(marked_objects, :aside) and length(player.hand) == 13 ->
              # discard stage
              choice = Enum.min_by(choices, fn {{_seat, _source, tile}, _i} -> get_minefield_discard_danger(state.minefield_tiles, state.minefield_waits, state.wall, doras, visible_tiles, tile, player.tile_behavior) end, &<=/2, fn -> nil end)
              {state, if choice == nil do [] else [choice] end}
            true -> {state, []}
          end
        "american" ->
          if Marking.is_marking?(marked_objects, :calls) do
            # we're swapping out a joker
            # check if any of our choices is a call
            if Enum.any?(choices, fn {{_seat, source, _obj}, _i} -> source == :calls end) do
              # select the call first
              {state, Enum.filter(choices, fn {{_seat, source, _obj}, _i} -> source == :calls end)}
            else
              # if we selected a call already, select the first valid tile
              {state, choices}
            end
          else
            # otherwise, we're selecting for charleston
            playables = Enum.map(choices, fn {{_seat, _source, obj}, i} -> {obj, i} end)
            case choose_american_discard(state, playables, closest_american_hands) do
              {nil, _} -> {state, []}
              {{_, i}, _} -> {state, Enum.filter(choices, fn {_, j} -> i == j end)}
            end
          end
        _ -> {state, choices}
      end

      if state.ruleset != "minefield" or has_minefield_hand do
        case choices do
          [{{seat, source, _obj}, i} | _] -> GenServer.cast(state.game_state, {:mark_tile, state.seat, seat, i, source})
          _ ->
            if Debug.debug_ai() do
              IO.puts(" >> #{state.seat}: Unfortunately I cannot mark anything")
              IO.puts(" >> #{state.seat}: My choices were: #{inspect(choices)}")
              IO.puts(" >> #{state.seat}: My marking state was: #{inspect(marked_objects)}")
              if state.ruleset == "minefield" do
                IO.puts(" >> #{state.seat}: My minefield hand was: #{inspect(state.minefield_hand)}")
              end
            end
            GenServer.cast(state.game_state, {:clear_marked_objects, state.seat})
        end
      end
      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:declare_yaku, %{player: player}}, state) do
    if state.initialized do
      state = %{ state | player: player }
      if Debug.debug_ai() do
        IO.puts(" >> #{state.seat}: It's my turn to declare yaku!")
      end
      GenServer.cast(state.game_state, {:declare_yaku, state.seat, ["Riichi"]})
      {:noreply, state}
    else
      {:noreply, state}
    end
  end
end