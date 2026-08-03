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
    obvious_joker_map = tile_behavior.mappings
    |> Enum.flat_map(fn {joker, assigns} ->
      case MapSet.to_list(assigns) do
        [assign] -> if Utils.strip_attrs(assign) != :any do [{joker, assign}] else [] end
        _ -> []
      end
    end)
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

  # returns a stream of {obvious_joker_assignment, nonobvious_joker_assignment}
  # do Map.merge(obvious_joker_assignment, nonobvious_joker_assignment) to get all assignments
  def solve_for_jokers(mutex, smt_hand, smt_calls, smt_solver, rules_ref, tile_behavior) do
    # first grab the obvious jokers (the ones that map only to one value, basically red fives)
    obvious_joker_assignment = get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)
    {smt_hand, smt_calls} = replace_obvious_jokers({smt_hand, smt_calls}, obvious_joker_assignment)

    use_smt = Rules.get(rules_ref, "score_calculation", %{}) |> Map.get("use_smt", true)
    if use_smt and Enum.any?(Enum.uniq(smt_hand ++ Enum.concat(smt_calls)), &TileBehavior.is_joker?(&1, tile_behavior)) do
      # obtain all joker assignments (as a stream)
      RiichiAdvanced.SMT.match_hand_smt_v4(mutex, smt_solver, smt_hand, smt_calls, Rules.translate_match_definitions(rules_ref, ["win"]), tile_behavior)
    else Stream.concat([]) end
    # re-add the obvious jokers back into each assignment
    # also returns Stream.new([[obvious_joker_assignment]]) if stream was empty
    |> Stream.transform(
        fn -> true end,
        fn joker_assignment, _empty? -> {[{obvious_joker_assignment, joker_assignment}], false} end,
        fn empty? -> {if empty? do [{obvious_joker_assignment, %{}}] else [] end, nil} end,
        fn _ -> nil end
      )
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

    # get a mapping from call index (i) to smt hand index (ix)
    {call_i_to_ix, _} = for {{_name, call}, i} <- Enum.with_index(non_flower_calls), reduce: {%{}, length(hand) + 1} do
      {acc, ix} -> {Map.put(acc, i, ix), ix + length(call)}
    end

    assigned_non_flower_calls = non_flower_calls
    |> Enum.with_index()
    |> Enum.map(fn {{call_name, call}, i} ->
      call = call
      |> Enum.with_index()
      |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, Map.get(call_i_to_ix, i) + ix, tile) end)
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
