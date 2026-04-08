defmodule RiichiAdvanced.GameState.JokerSolver do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  import RiichiAdvanced.GameState

  # TODO type these
  def is_dealer?(seat, kyoku, available_seats) do
    Riichi.get_east_player_seat(kyoku, available_seats) == seat
  end
  # smt hand = hand with winning tile appended to the end
  # smt calls = flattened calls that aren't flowers
  def get_smt_hand_calls(hand, calls, winning_tile) do
    smt_hand = hand ++ [winning_tile]
    smt_calls = calls
    |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    |> Enum.map(&Utils.call_to_tiles/1)
    {smt_hand, smt_calls}
  end
  # get an assignment for the obvious jokers (the ones with only one assignable value)
  def get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls) do
    # first get a map [single-value joker => the tile it maps to]
    obvious_joker_map = TileBehavior.tile_mappings(tile_behavior)
    |> Enum.flat_map(fn {joker, [assign]} -> if Utils.strip_attrs(assign) != :any do [{joker, assign}] else [] end; _ -> [] end)
    |> Map.new()
    # return a map %{index => tile}
    # do this by iterating over the whole hand and replacing with the first joker match
    Enum.with_index(smt_hand ++ Enum.concat(smt_calls))
    |> Enum.flat_map(fn {tile, ix} ->
      case Enum.find(obvious_joker_map, fn {from, _to} -> Utils.same_tile(tile, from) end) do
        nil        -> []
        {from, to} ->
          # replace this tile
          base = if Utils.strip_attrs(to) == :any do tile else to end
          attrs = (Utils.get_attrs(tile) ++ Utils.get_attrs(to)) -- Utils.get_attrs(from)
          [{ix, Utils.add_attr(base, attrs)}]
      end
    end)
    |> Map.new()
  end
  def replace_obvious_jokers({smt_hand, smt_calls}, obvious_joker_assignment) do
      # replace smt hand/calls with obvious jokers (the ones that map only to one value, basically red fives)
      # so the smt solver doesn't solve for those
      {[smt_hand | smt_calls], _} = for group <- [smt_hand | smt_calls], reduce: {[], 0} do
        {acc, start_ix} ->
          {acc ++ [for {tile, ix} <- Enum.with_index(group) do
            Map.get(obvious_joker_assignment, start_ix + ix, tile)
          end], start_ix + length(group)}
      end
      {smt_hand, smt_calls}
  end
  def solve_for_jokers(mutex, smt_hand, smt_calls, smt_solver, rules_ref, tile_behavior) do
    # first grab the obvious jokers (the ones that map only to one value, basically red fives)
    obvious_joker_assignment = get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)
    {smt_hand, smt_calls} = replace_obvious_jokers({smt_hand, smt_calls}, obvious_joker_assignment)

    use_smt = Rules.get(rules_ref, "score_calculation", %{}) |> Map.get("use_smt", true)
    ret = if use_smt and Enum.any?(Enum.uniq(smt_hand ++ Enum.concat(smt_calls)), &TileBehavior.is_joker?(&1, tile_behavior)) do
      # obtain all joker assignments (as a stream)
      RiichiAdvanced.SMT.match_hand_smt_v4(mutex, smt_solver, smt_hand, smt_calls, Rules.translate_match_definitions(rules_ref, ["win"]), tile_behavior)
    else Stream.concat([[%{}]]) end
    # re-add the obvious jokers back into each assignment
    |> Stream.map(&Map.merge(obvious_joker_assignment, &1))
    ret
    # TODO can we somehow check if the stream is empty, and return Stream.new([[obvious_joker_assignment]]) if so?
  end

  # input is original hand and calls, and original winning tile
  # in the case of tenhou, pass in the smt hand instead
  def apply_joker_assignment(hand, calls, winning_tile, joker_assignment) do
    {flower_calls, non_flower_calls} = Enum.split_with(calls, fn
      {call_name, _call} -> call_name in Riichi.flower_names()
      _                  -> false
    end)
    assigned_hand = hand
    |> Enum.with_index()
    |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, ix, tile) end)

    assigned_non_flower_calls = non_flower_calls
    |> Enum.with_index()
    |> Enum.map(fn {{call_name, call}, i} ->
      call = call
      |> Enum.with_index()
      |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, length(hand) + 1 + 3*i + ix, tile) end)
      {call_name, call}
    end)
    assigned_calls = flower_calls ++ assigned_non_flower_calls
    # length(hand) is where the solver puts the winning tile
    # if the winning tile is a joker, the following gets its assignment,
    # otherwise it just takes the hand's last tile
    assigned_winning_tile = Map.get(joker_assignment, length(hand), winning_tile)
    assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ if assigned_winning_tile != nil do [assigned_winning_tile] else [] end
    {assigned_hand, assigned_calls, assigned_winning_hand, assigned_winning_tile}
  end

  def evaluate_joker_assignment(state, cxt, joker_assignment) do
    %{
      seat: seat,
      smt_hand: smt_hand,
      win_source: win_source,
      winning_tile: winning_tile,
    } = cxt
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    highest_scoring_yaku_only = Map.get(score_rules, "highest_scoring_yaku_only", false)

    # replace 5z in joker assignment with 0z if 0z is present in the game
    # TODO remove this once the framed_5z mod is applied to every relevant ruleset
    # joker_assignment = if Map.has_key?(tile_behavior.tile_freqs, :"0z") do
    #   Map.new(joker_assignment, fn {ix, tile} -> {ix, if tile == :"5z" do :"0z" else tile end} end)
    # else joker_assignment end

    # use the joker assignment to obtain winner's {hand, calls} with jokers replaced by their assignments
    {assigned_hand, assigned_calls, assigned_winning_hand, assigned_winning_tile} = apply_joker_assignment(state.players[seat].hand, state.players[seat].calls, winning_tile, joker_assignment)

    # replace the winner's hand/calls temporarily (for yaku evaluation)
    state = update_player(state, seat, &%{ &1 | hand: assigned_hand, calls: assigned_calls, cache: %{ &1.cache | winning_hand: assigned_winning_hand } })

    # also replace the actual winning tile within state
    state = if assigned_winning_tile != nil do
      update_winning_tile(state, seat, win_source, fn _ -> assigned_winning_tile end)
    else
      IO.puts("WARNING: no assigned_winning_tile for a win! hand: #{inspect(smt_hand)}, joker_assignment: #{inspect(joker_assignment)}")
      state
    end

    # run before_scoring only after replacing those tiles
    # this is because before_scoring might add attributes to hand, which will be used for yaku calculation
    # also you need non-joker tiles in order to calculate fu and such here
    state = Actions.trigger_event(state, "before_scoring", cxt)

    # fetch the new hand, calls, and winning tile
    %{hand: assigned_hand, calls: assigned_calls} = state.players[seat]
    assigned_winning_tile = get_winning_tile(state, seat, win_source)
    if assigned_winning_tile == nil do
      IO.puts("[WARNING] evaluate_joker_assignment: the winning tile must exist, but got nil")
    end
    assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ [assigned_winning_tile]

    # obtain yaku and minipoints from this state
    {yaku, minipoints} = Scoring.get_yaku_from_lists(state, Map.get(score_rules, "yaku_lists", []), seat, assigned_winning_tile, win_source)
    {yaku2, _minipoints} = if Map.has_key?(score_rules, "yaku2_lists") do
      Scoring.get_yaku_from_lists(state, Map.get(score_rules, "yaku2_lists", []), seat, assigned_winning_tile, win_source)
    else {[], 0} end
    if Debug.print_wins() do
      assigned_winning_hand = state.players[seat].cache.winning_hand
      IO.puts("checking assignment, hand: #{inspect(assigned_winning_hand)}, tile: #{inspect(winning_tile)}, yaku: #{inspect(yaku)}, yaku2: #{inspect(yaku2)}")
    end

    yaku = if not Enum.empty?(yaku) and highest_scoring_yaku_only do [Enum.max_by(yaku, fn {_name, value} -> value end)] else yaku end
    yaku2 = if not Enum.empty?(yaku2) and highest_scoring_yaku_only do [Enum.max_by(yaku2, fn {_name, value} -> value end)] else yaku2 end
    yaku = Enum.map(yaku, fn {name, value} -> {translate(state, name), value} end)
    yaku2 = Enum.map(yaku2, fn {name, value} -> {translate(state, name), value} end)
    points = Enum.map(yaku ++ yaku2, fn {_name, value} -> value end) |> Enum.reduce([], &Scoring.add_yaku_values/2)

    # this bit is to support old scoring system, TODO remove
    yaku2_overrides = not Enum.empty?(yaku2) and Map.get(score_rules, "yaku2_overrides_yaku1", false)
    yaku = if yaku2_overrides do yaku2 else yaku end

    {state, Map.merge(cxt, %{
      yaku: yaku,
      yaku2: yaku2,
      minipoints: minipoints,
      points: Utils.get_from_points_list(points, score_rules["point_name"]),
      points2: Utils.get_from_points_list(points, score_rules["point2_name"]),
      total_points: points,
      joker_assignment: joker_assignment,
      winning_tile: assigned_winning_tile,
      assigned_hand: assigned_hand,
      assigned_calls: assigned_calls,
      assigned_winning_hand: assigned_winning_hand,
    })}
  end
  
  def get_highest_scoring_evaluation(evaluations, get_worst_instead \\ false) do
    Enum.max_by(evaluations,
      fn %{score: score, points: points, points2: points2, minipoints: minipoints, yaku: yaku, yaku2: yaku2} ->
        {score, points, points2, minipoints, -length(yaku), -length(yaku2)}
        # |> IO.inspect(label: inspect(yaku))
      end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end

end
