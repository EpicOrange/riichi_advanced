defmodule RiichiAdvanced.JokerSolver do
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
  def determine_winning_tile(state, seat, win_source) do
    winning_tiles = get_winning_tiles(state, seat, win_source)
    winning_tile = if MapSet.size(winning_tiles) == 1 do Enum.at(winning_tiles, 0) else nil end
    winning_tile
  end
  def construct_winning_hand(winning_tile, hand, calls) do
    hand ++ Enum.flat_map(calls, &Utils.call_to_tiles/1) ++ if winning_tile != nil do [winning_tile] else [] end
  end
  def get_smt_hand_calls(state, seat, winning_tile) do
    smt_hand = state.players[seat].hand ++ if winning_tile != nil do [winning_tile] else [] end
    smt_calls = state.players[seat].calls
    |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    |> Enum.map(&Utils.call_to_tiles/1)
    {smt_hand, smt_calls}
  end
  # get an assignment for the obvious jokers (the ones with only one assignable value)
  def get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls) do
    # first get a map [single-value joker => the tile it maps to]
    obvious_joker_map = TileBehavior.tile_mappings(tile_behavior)
    |> Enum.flat_map(fn {joker, [assign]} -> [{joker, assign}]; _ -> [] end)
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
  def solve_for_jokers({smt_hand, smt_calls}, smt_solver, rules_ref, tile_behavior, winning_tile) do
    # first grab the obvious jokers (the ones that map only to one value, basically red fives)
    obvious_joker_assignment = get_obvious_joker_assignment(tile_behavior, smt_hand, smt_calls)
    {smt_hand, smt_calls} = replace_obvious_jokers({smt_hand, smt_calls}, obvious_joker_assignment)

    use_smt = Rules.get(rules_ref, "score_calculation", %{}) |> Map.get("use_smt", true)
    ret = if use_smt and Enum.any?(smt_hand ++ Enum.concat(smt_calls), &TileBehavior.is_joker?(&1, tile_behavior)) do
      # obtain all joker assignments (as a stream)
      RiichiAdvanced.SMT.match_hand_smt_v3(smt_solver, smt_hand, smt_calls, Rules.translate_match_definitions(rules_ref, ["win"]), tile_behavior)
    else Stream.concat([[%{}]]) end
    # re-add the obvious jokers back into each assignment
    |> Stream.map(&Map.merge(obvious_joker_assignment, &1))
    ret
    # TODO can we somehow check if the stream is empty, and return Stream.new([[obvious_joker_assignment]]) if so?
  end

  def apply_joker_assignment(hand, calls, joker_assignment) do
    {flower_calls, non_flower_calls} = Enum.split_with(calls, fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    assigned_hand = hand |> Enum.with_index() |> Enum.map(fn {tile, ix} -> Map.get(joker_assignment, ix, tile) end)
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
    # if the winning tile is a joker, the following gets its assignment
    assigned_winning_tile = Map.get(joker_assignment, length(hand), nil)
    assigned_winning_hand = assigned_hand ++ Enum.flat_map(assigned_calls, &Utils.call_to_tiles/1) ++ if assigned_winning_tile != nil do [assigned_winning_tile] else [] end
    {assigned_hand, assigned_calls, assigned_winning_hand, assigned_winning_tile}
  end

  def evaluate_joker_assignment(state, %{seat: seat, winning_tile: winning_tile, win_source: win_source, is_dealer: is_dealer}, joker_assignment) do
    score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
    highest_scoring_yaku_only = Map.get(score_rules, "highest_scoring_yaku_only", false)

    # replace 5z in joker assignment with 0z if 0z is present in the game
    # TODO remove this once the framed_5z mod is applied to every relevant ruleset
    # joker_assignment = if Map.has_key?(tile_behavior.tile_freqs, :"0z") do
    #   Map.new(joker_assignment, fn {ix, tile} -> {ix, if tile == :"5z" do :"0z" else tile end} end)
    # else joker_assignment end

    # get a joker-replaced version of hand, calls, winning_hand, winning_tile
    %{hand: hand, calls: calls, tile_behavior: tile_behavior} = state.players[seat]
    {assigned_hand, assigned_calls, assigned_winning_hand, assigned_winning_tile}
      = apply_joker_assignment(hand, calls, joker_assignment)
    # replace the winning tile with whatever the joker assignment says it is
    state = if assigned_winning_tile != nil do
      update_winning_tile(state, seat, win_source, fn _ -> assigned_winning_tile end)
    else state end

    # run before_scoring actions
    state = Actions.trigger_event(state, "before_scoring", %{seat: seat, win_source: win_source})

    # get winning tile, after before_scoring does its thing
    winning_tiles = get_winning_tiles(state, seat, win_source)

    # obtain yaku and minipoints
    {yaku, minipoints, new_winning_tile} = Scoring.get_best_yaku_from_lists(state, Map.get(score_rules, "yaku_lists", []), seat, winning_tiles, win_source)
    {yaku2, _minipoints, _new_winning_tile} = if Map.has_key?(score_rules, "yaku2_lists") do
      Scoring.get_best_yaku_from_lists(state, Map.get(score_rules, "yaku2_lists", []), seat, winning_tiles, win_source)
    else {[], minipoints, new_winning_tile} end
    if Debug.print_wins() do
      assigned_winning_hand = state.players[seat].cache.winning_hand
      IO.puts("checking assignment, hand: #{inspect(assigned_winning_hand)}, tile: #{inspect(new_winning_tile)}, yaku: #{inspect(yaku)}, yaku2: #{inspect(yaku2)}")
    end

    # winning tile is nil if you won with e.g. 14 tiles in hand tenhou
    # or if it's sichuan bloody rules and you won takame of your tenpai hand
    # in the first case, move winning tile from hand to draw
    # in the second case, nothing to take out, so do nothing
    winning_tile = if winning_tile == nil and new_winning_tile != nil do
      case Match.try_remove_all_tiles(hand, [new_winning_tile], tile_behavior) do
        [] -> new_winning_tile
        [remainder | _] -> Enum.at(hand -- remainder, 0)
      end
    else winning_tile end

    # score yaku
    yaku = if not Enum.empty?(yaku) and highest_scoring_yaku_only do [Enum.max_by(yaku, fn {_name, value} -> value end)] else yaku end
    yaku2 = if not Enum.empty?(yaku2) and highest_scoring_yaku_only do [Enum.max_by(yaku2, fn {_name, value} -> value end)] else yaku2 end
    {score, points, points2, score_name} = Scoring.score_yaku(state, seat, yaku, yaku2, is_dealer, win_source == :draw, minipoints)
    if Debug.print_wins() do
      IO.puts("score: #{inspect(score)}, points: #{inspect(points)}, points2: #{inspect(points2)}, minipoints: #{inspect(minipoints)}, score_name: #{inspect(score_name)}")
    end

    %{
      state: state,
      winning_tile: winning_tile,
      joker_assignment: joker_assignment,
      winning_tile: winning_tile,
      yaku: yaku,
      yaku2: yaku2,
      score: score,
      points: points,
      points2: points2,
      minipoints: minipoints,
      score_name: score_name
    }
  end
  def get_highest_scoring_evaluation(evaluations, get_worst_instead \\ false) do
    Enum.max_by(evaluations,
      fn %{score: score, points: points, points2: points2, minipoints: minipoints, yaku: yaku, yaku2: yaku2} ->
        {score, points, points2, minipoints, -length(yaku), -length(yaku2)}
      end,
      if get_worst_instead do &<=/2 else &>=/2 end,
      fn -> nil end # empty stream
    )
  end











  # # calculates the optimal joker assignment in terms of points
  # # returns that assignment, as well as the calculated yaku, minipoints, etc
  # @spec calculate_optimal_joker_assignment(WinSpec.t()) :: map()
  # def calculate_optimal_joker_assignment(%WinSpec{
  #     score_rules: score_rules,
  #     winning_seat: winning_seat,
  #     win_source: win_source,
  #     winning_tile: winning_tile,
  #     winning_hand: winning_hand,
  #     dealer_seat: dealer_seat,
  #     opponents: opponents}) do
  #   # push a message if it takes more than 0.5 seconds to solve
  #   notify_task = Task.async(fn -> :timer.sleep(500); push_message(state, [%{text: "Running joker solver..."}]) end)
  #   # find the maximum score obtainable across all joker assignments
  #   winner_details = Task.async_stream(
  #     Scoring.solve_for_jokers(state, seat, winning_tile),
  #     &calculate_winner_details_task(state, %{
  #       seat: seat,
  #       winning_tile: winning_tile,
  #       win_source: win_source,
  #       is_dealer: is_dealer?(seat, state.kyoku, state.available_seats)
  #     }, &1),
  #     timeout: :infinity, ordered: false
  #   )
  #   |> Stream.map(fn {:ok, res} -> res end)
  #   |> get_best_winner_details(win_source == :worst_discard)
  #   winner_details = if winner_details == nil do
  #     # perhaps it's a special hand not supported by the smt solver,
  #     # in any case, we got no assignment from the solver,
  #     # so score the hand as is (with no joker assignment)
  #     calculate_winner_details_task(state, context, %{})
  #   else winner_details end

  #   # kill the 0.5s timer if it's still sleeping
  #   if Task.yield(notify_task, 0) == nil do
  #     Task.shutdown(notify_task, :brutal_kill)
  #   end

  #   winner_details
  # end



end

# more fleshed out implementation notes
# 
# each win has some easy things to calculate, and some hard things. easy things:
# - seat that won (the one with the winning hand)
# - won_by: :discard, :draw, or :call
# - pao_map
# - available_seats
# - dealer_seat
# - pot, honba
# - score_rules
# hard things:
# - yaku and yaku2 (requires evaluating jokers)
# - minipoints (is its own thing)

# these are currently handled by Scoring.calculate_winner_details.
# this function is extremely stateful, and does:
# - [OK] using passed in win_source, determines which tile was used to win (winning tile)
# - [NO] sets global winning_hand variable to (hand + calls + winning tile)
# - [OK] check if we're dealer (also handle ryuumonbuchi touka "i score as if i'm dealer" power)
# - [OK] for bloody end, save all opponents, to know from whom payments are coming from
# - [OK] launch smt solver async to get all possible joker assignments. if none was found, then just leave in the jokers
# - [OK] otherwise, replace jokers with their assigned identities, and score the hand
# - [NO] run before_scoring (also very stateful), saving hand and calls before doing so
# - [OK] output all the information ever into a huge object, the winner object, and return it

# the [NO] lines cannot be copypasted over, since they are stateful, but most things can be done here
# in particular, we can make a function that does all the stuff between the two NO lines
# 
# this means we need to make a function that:
# - is passed in %WinSpec{winning_seat, win_source, winning_tile, the hand and calls, dealer seat, bloody end opponents
# - launches smt solver if needed
# - does a joker replacement
# - scores the hand
# - returns the {score, etc} of the ideal joker assignment



# temp implementation notes
#
#   structure for payments:
#   - each payment is from one player to another (multiple payments possible)
#   - the list of payments is determined after yaku processing (pao needs yaku knowledge)
#   - there may be multiple payments from A to B (e.g. daisangen pao + non-daisangen ron)
#   - some sakicards reverse payments, so negative payments are possible
#   - when displayed, payments should always be positive
#   - when displayed, payments should have some history attached to it
#   - the base score is calculated based on (payment relationship, minipoints, yaku)
#   - ... * some multiplier (passed in, e.g. tsumo 2x/1x vs ron 6x/4x)
#   - ... + some penalty (passed in, e.g. MCR 8 points, honba value)
#   
#   so it's a 2 phase process
#   - first phase figures out all the arrows (who pays whom) with no score attached
#     - to do this, we need to know:
#     - win_source (ron, tsumo, chankan)
#     - who dealt the last tile (last_discarder)
#     - who drew the last tile (winner)
#     - sakicards stuff (e.g. ezaki doesn't pay tsumos)
#     - the pot is also a valid target (to/from)
#     - (this calculates the multiplier + penalty, using game state and hand)
#     - payment situations once you have base score down:
#       - ron OR chankan OR tsumo pao (W <- L) = 4x base score, 6x if dealer
#       - tsumo OR hu OR nagashi (W <- LLL) = 2x base score if dealer, 1x base score if nondealer
#       - double ron/chankan (WW <- L) = 4x base score each, 6x if dealer
#       - triple ron/chankan (WWW <- L) = 4x base score each, 6x if dealer
#       - ron pao (W <- LL) = 2x base score each
#       - ryuukyoku (W <- LLL, WW <- LL, WWW <- L) = 3000/#Ls each?

#   - second phase takes in first phase DAG + yaku + minipoints, and outputs:
#     - score_yaku => delta_scores
#     - calculation history for each arrow
#       - only insert entries into this via some display_payment_step action?
#       - combine multiedge arrows into one, to be separated by <hr>








