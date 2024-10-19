defmodule GameEvent do
  defstruct [
    seat: nil,
    event_type: nil,
    params: %{}
  ]
  use Accessible
end

defmodule RiichiAdvanced.GameState.Log do
  # alias RiichiAdvanced.GameState.Buttons, as: Buttons
  # import RiichiAdvanced.GameState

  def init_log(state) do
    state = Map.put(state, :log_state, %{
      log: [],
      kyokus: [],
      calls: Map.new(state.players, fn {seat, _player} -> {seat, nil} end)
    })
    state
  end

  def to_seat(seat) do
    case seat do
      :east  -> 0
      :south -> 1
      :west  -> 2
      :north -> 3
      _      -> nil
    end
  end

  def log(state, seat, event_type, params) do
    update_in(state.log_state.log, &[%GameEvent{ seat: to_seat(seat), event_type: event_type, params: params } | &1])
  end

  defp modify_last_draw_discard(state, fun) do
    ix = Enum.find_index(state.log_state.log, fn event -> event.event_type == :draw || event.event_type == :discard end)
    if ix != nil do
      update_in(state.log_state.log, &List.update_at(&1, ix, fun))
    else
      IO.inspect("Tried to update last draw/discard of log, but there is none")
      state
    end
  end

  def add_buttons(state) do
    possible_calls = for {seat, player} <- state.players do
      for {name, {:call, choices}} <- player.button_choices do
        for choice <- Map.values(choices) |> Enum.concat() do
          %{player: to_seat(seat), type: name, tiles: choice}
        end
      end |> Enum.concat()
    end |> Enum.concat()
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.put(event.params, :possible_calls, possible_calls) } end)
  end

  def add_call(state, seat, call_name, call_choice, called_tile) do
    tiles = Utils.strip_attrs(call_choice ++ if called_tile != nil do [called_tile] else [] end)
    call = %{player: to_seat(seat), type: call_name, tiles: tiles}
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.put(event.params, :call, call) } end)
  end

  def finalize_kyoku(state) do
    state = update_in(state.log_state.kyokus, fn kyokus -> [%{
      index: length(state.log_state.kyokus),
      haipai: state.haipai,
      players: Enum.map([:east, :south, :west, :north], fn dir -> %{
        points: state.players[dir].score,
        haipai: state.haipai[dir]
      } end),
      kyoku: state.kyoku,
      honba: state.honba,
      riichi_sticks: Integer.floor_div(state.pot, state.rules["score_calculation"]["riichi_value"]),
      doras: ["todo"],
      uras: ["todo"],
      kan_tiles: ["todo"],
      wall: state.wall |> Enum.drop(52) |> Enum.take(70),
      events: state.log_state.log
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(&format_event/1),
      result: for {seat, winner} <- state.winners do
        %{
          seat: to_seat(seat),
          pao: to_seat(winner.pao_seat),
          won_from: to_seat(winner.payer),
          hand: state.players[seat].winning_hand,
          tile: winner.winning_tile,
          yaku: Enum.map(winner.yaku, fn {name, value} -> [name, value] end),
          yakuman: Enum.map(winner.yakuman, fn {name, value} -> [name, value] end),
          han: winner.points,
          fu: winner.minipoints,
          yakuman_mult: winner.yakuman_mult,
          points: winner.score,
          delta_points: "todo"
        }
      end
    } | kyokus] end)
    state = put_in(state.log_state.log, [])
    state
  end

  # output functions

  defp format_event({event, ix}) do
    Map.merge(%{index: ix, player: event.seat, type: event.event_type}, event.params)
  end

  def output(state) do
    state = finalize_kyoku(state)
    out = %{
      ver: "v1",
      players: Enum.map(state.players, fn {seat, player} -> %{
        name: if player.nickname == nil do Atom.to_string(seat) else player.nickname end,
        score: player.score,
        payout: player.score # TODO no uma?
      } end),
      rules: %{
        mods: state.mods
      },
      kyokus: Enum.reverse(state.log_state.kyokus)
    }
    Jason.encode!(out)
  end

end
