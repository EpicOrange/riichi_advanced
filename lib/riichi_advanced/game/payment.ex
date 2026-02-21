defmodule RiichiAdvanced.Payment do
  alias RiichiAdvanced.GameState, as: GameState
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Conditions, as: Conditions
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.PlayerCache, as: PlayerCache
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils

  @type seat() :: GameState.seat()
  @type win_source() :: GameState.win_source()
  @type modifier_op() :: :+ | :- | :* | :/ | :round_up | :round_down
  @type modifier() :: {modifier_op(), number() | nil, binary()}
  @type line_item() :: %{
    op: modifier_op() | := | nil,
    amount: number(),
    result: number(),
    reason: binary(),
  }

  defmodule Responsibility do
    @type seat() :: GameState.seat()
    @type modifier :: Payment.modifier()
    @type t :: %__MODULE__{
      from: seat() | :pot,
      to: seat() | :pot,
      yaku: list({binary(), number()}),
      minipoints: number(),
      modifiers: list(modifier())
    }
    defstruct [
      from: :pot, # who is responsible for paying the yaku+minipoints?
      to: :pot,   # who gets this payment?
      yaku: [],
      minipoints: 0,
      modifiers: [], # ordered list of {op, amount, reason}
    ]
  end
  defmodule Payment do
    @type seat() :: GameState.seat()
    @type modifier_op() :: Payment.modifier_op()
    @type line_item() :: Payment.line_item()
    @type t :: %__MODULE__{
      from: seat() | :pot,
      to: seat() | :pot,
      total: number(),
      line_items: list(line_item()),
    }
    defstruct [
      from: nil,
      to: nil,
      total: 0,
      line_items: [],
    ]
  end
  defmodule WinInfo do
    @type seat() :: GameState.seat()
    @type win_source() :: GameState.win_source()
    @type modifier :: Payment.modifier()
    @type t :: %__MODULE__{
      seat: seat(),
      won_by: {win_source(), seat()},
      yaku: list({binary(), number()}),
      minipoints: number(),
      pao_map: %{seat() => list(binary())},
      available_seats: list(seat()),
      modifiers: list(modifier())
    }
    defstruct [
      seat: :east,
      won_by: {:discard, :east},
      yaku: [], # {name, value} pairs
      minipoints: 0,
      pao_map: %{}, # %{seat => [yaku]} means `seat` must pay for `yaku`
      available_seats: [:east, :south, :west, :north],
      modifiers: [], # ordered list of {op, amount, reason}
    ]
  end
  defmodule DrawInfo do
    defstruct [
      tenpai: nil,
      nagashi: nil
    ]
  end

  @spec order_seats_from(list(seat()), seat()) :: list(seat())
  def order_seats_from(seats, starting_seat) do
    seats
    |> Enum.sort_by(fn seat -> Utils.get_relative_seat(starting_seat, seat)
      |> case do :shimocha -> 1; :toimen -> 2; :kamicha -> 3; _ -> 0; end
    end)
  end

  @spec determine_responsibilities(WinInfo.t(), seat(), number(), number(), number(), list(modifier())) :: list(Responsibility.t())
  def determine_responsibilities(winners, turn, pot \\ 0, honba \\ 0, honba_value \\ 100, modifiers \\ []) do
    ret = for win_info <- winners, reduce: [] do
      ret ->
        is_dealer? = win_info.seat == turn
        is_pao? = not Enum.empty?(win_info.pao_map)
        case win_info.won_by do
          {:discard, discarder_seat} ->
            # process all the pao yaku first (if any)
            {all_pao_yaku, ret} = if is_pao? do
              # we start from winner and go in turn order
              # note: if there are 2 pao players for the same yaku, both still pay half
              # (also note this cannot occur in standard riichi)
              {all_pao_yaku, ret} = for seat <- order_seats_from(win_info.available_seats, win_info.seat), reduce: {win_info.yaku, ret} do
                {all_pao_yaku, ret} -> case win_info.pao_map[seat] do
                  nil -> {all_pao_yaku, ret}
                  {pao_seat, pao_yaku} -> 
                    pao_win_info = %WinInfo{ win_info | won_by: {:discard, pao_seat}, yaku: pao_yaku, pao_map: %{}, modifiers: [{:/, 2, "Pao ron halving"}] }
                    first = Enum.empty?(ret)
                    ret = determine_responsibilities([pao_win_info], 0, if first do honba else 0 end, honba_value) ++ ret
                    {pao_yaku ++ all_pao_yaku, ret}
                end
              end
              # process pao yaku for discarder
              discarder_win_info = %WinInfo{ win_info | yaku: all_pao_yaku, pao_map: %{} }
              ret = determine_responsibilities([discarder_win_info], 0, 0, honba_value) ++ ret
              {all_pao_yaku, ret}
            else {[], []} end

            # then process non-pao yaku for discarder
            modifiers = modifiers ++
              if is_dealer? do [{:*, 6, "Dealer ron"}] else [{:*, 4, "Nondealer ron"}] end ++
              if is_pao? do [{:/, 2, "Pao ron halving"}] else [] end ++
              [{:round_up, 100, "Round up"}] ++
              if is_pao? do [] else [{:+, 3 * honba_value * honba, "Honba"}] end
            ret = [%Responsibility {
              from: discarder_seat,
              to: win_info.seat,
              yaku: win_info.yaku -- all_pao_yaku,
              minipoints: win_info.minipoints,
              modifiers: modifiers
            } | ret]

            ret
          {:draw, _seat} ->
            # if it's pao, it's the same as a direct hit ron but only for the pao yaku
            # if multiple players are pao, they all pay a full direct hit ron :)
            # (only first one pays honba though)
            {all_pao_yaku, ret} = if is_pao? do
              for seat <- order_seats_from(win_info.available_seats, win_info.seat), reduce: {win_info.yaku, ret} do
                {all_pao_yaku, ret} -> case win_info.pao_map[seat] do
                  nil -> {all_pao_yaku, ret}
                  {pao_seat, pao_yaku} -> 
                    pao_win_info = %WinInfo{ win_info | won_by: {:discard, pao_seat}, yaku: pao_yaku, pao_map: %{}, modifiers: [] }
                    first = Enum.empty?(ret)
                    ret = determine_responsibilities([pao_win_info], 0, if first do honba else 0 end, honba_value) ++ ret
                    {pao_yaku ++ all_pao_yaku, ret}
                end
              end
            else {[], []} end

            # regular tsumo payment for all the non-pao yaku
            ret = for seat <- win_info.available_seats -- [win_info.seat], reduce: ret do
              ret ->
                dealer_bonus = if is_dealer? or seat === turn do [{:*, 2, "Dealer"}] else [] end
                modifiers = dealer_bonus ++ [{:round_up, 100, "Round up"}]
                [%Responsibility {
                  from: seat,
                  to: win_info.seat,
                  yaku: win_info.yaku -- all_pao_yaku,
                  minipoints: win_info.minipoints,
                  modifiers: modifiers,
                } | ret]
            end
            ret
          {:call, caller_seat} ->
            # exactly the same as win by discard
            discard_win_info = %WinInfo{ win_info | won_by: {:discard, caller_seat} }
            ret = determine_responsibilities([discard_win_info], 0, honba, honba_value) ++ ret
            ret
      end
    end

    # first winner takes pot
    ret = if pot > 0 do
      first_winner = Map.keys(winners) |> order_seats_from(turn) |> Enum.at(0)
      [%Responsibility {
        from: :pot,
        to: first_winner,
        yaku: [],
        minipoints: 0,
        modifiers: [{:+, pot, "Riichi sticks"}],
      } | ret]
    else ret end
    ret
  end

  # main point of this is converting it into line items, in reverse order
  @type han_fu_opts :: %{
    binary() => list(list(number())),
    binary() => list(number()),
    binary() => list(binary()),
  }
  @han_fu_opts %{
    "limit_thresholds" => [
      [13, 0],
      [11, 0],
      [8, 0],
      [6, 0],
      [5, 0], [4, 40], [3, 70],
    ],
    "limit_scores" => [
      8000,
      6000,
      4000,
      3000,
      2000, 2000, 2000,
    ],
    "limit_names" => [
      "Kazoe Yakuman",
      "Sanbaiman",
      "Baiman",
      "Haneman",
      "Mangan", "Mangan", "Mangan",
    ],
  }
  @spec calculate_payment(Responsibility.t(), binary(), han_fu_opts()) :: Payment.t()
  def calculate_payment(resp, "han_fu", opts \\ @han_fu_opts) do
    # strategy "han_fu" uses the han fu formula with a couple options
    # han is just the sum of all yaku values
    han = resp.yaku
    |> Enum.map(fn {_yaku, value} -> value end)
    |> Enum.sum()
    line_items = [%{op: nil, amount: nil, result: han, reason: "Han"}]

    fu = resp.minipoints
    line_items = [%{op: nil, amount: nil, result: fu, reason: "Fu"} | line_items]

    # check limit hands to see if we need to fix base to some number
    %{"limit_thresholds" => limit_thresholds, "limit_scores" => limit_scores, "limit_names" => limit_names} = opts
      limit_index = Enum.find_index(limit_thresholds, fn [han_limit, fu_limit] -> han >= han_limit and fu >= fu_limit end)
    {base, line_items} = if limit_index != nil do
      base = Enum.at(limit_scores, limit_index, 0)
      name = Enum.at(limit_names, limit_index, "")
      line_items = [%{op: :=, amount: nil, result: base, reason: "#{name} base"} | line_items]
      {base, line_items}
    else
      base = 4 * fu * (2 ** han)
      line_items = [%{op: :=, amount: nil, result: base, reason: "Base"} | line_items]
      {base, line_items}
    end

    # apply all modifiers and include them as line items
    {total, line_items} = for {op, value, reason} <- resp.modifiers, reduce: {base, line_items} do
      {acc, line_items} ->
        acc = case op do
          :+          -> acc + value
          :-          -> acc - value
          :*          -> Utils.try_integer(acc * value)
          :/          -> Utils.try_integer(acc / value)
          :round_up   -> Utils.try_integer(ceil(acc / value) * value)
          :round_down -> Utils.try_integer(floor(acc / value) * value)
        end
        line_items = [%{op: op, amount: value, result: acc, reason: reason} | line_items]
        {acc, line_items}
    end

    line_items = [%{op: :=, amount: nil, result: total, reason: "Total"} | line_items]

    # return payment struct
    %Payment{
      from: resp.from,
      to: resp.to,
      total: total,
      line_items: line_items,
    }
  end
end

# could be:
# - ron OR chankan OR tsumo pao (W <- L) = 4x base score, 6x if dealer
# - tsumo OR hu (W <- LLL) = 2x base score if dealer, 1x if nondealer
# - ron pao (W <- LL) = 2x base score each
# - double ron/chankan (WW <- L) = 4x base score each, 6x if dealer
# - triple ron/chankan (WWW <- L) = 4x base score each, 6x if dealer
# not handled here:
# - ryuukyoku (W <- LLL, WW <- LL, WWW <- L) = 0x base score, some penalty
# - nagashi (W <- LLL) = 2x base score if dealer, 1x if nondealer

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
#     - 
#   - 
#   - 
#   

# definitely good helpers from scoring.ex

  # defp calculate_delta_scores_tsumo(state, winner, basic_score, is_dealer) do
  # defp calculate_delta_scores_for_single_winner(state, winner, collect_sticks) do
  # defp calculate_delta_scores_per_player(state, winners) do
  # def seat_scores_points(state, yaku_list_names, min_points, min_minipoints, seat, winning_tile, win_source) do
  # defp apply_ron_score_modifiers(state, winner, payer, basic_score) do

# probably entry point

  # def adjudicate_win_scoring(state) do
  # def adjudicate_draw_scoring(state) do

#   {state, delta_scores, delta_scores_reason, next_dealer} = Scoring.adjudicate_win_scoring(state)










