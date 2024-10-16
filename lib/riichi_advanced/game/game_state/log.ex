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

  def log(state, seat, event_type, params) do
    update_in(state.log_state.log, &[%GameEvent{ seat: seat, event_type: event_type, params: params } | &1])
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
          %{player: seat, type: name, tiles: choice}
        end
      end |> Enum.concat()
    end |> Enum.concat()
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.put(event.params, :possible_calls, possible_calls) } end)
  end

  def add_call(state, seat, call_name, call_choice) do
    call = %{player: seat, type: call_name, tiles: call_choice}
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
      riichi_sticks: state.riichi_sticks,
      doras: ["todo"],
      uras: ["todo"],
      kan_tiles: ["todo"],
      wall: state.wall |> Enum.drop(52) |> Enum.take(70),
      events: state.log_state.log
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(&format_event/1),
      result: "todo"
    } | kyokus] end)
    state = put_in(state.log_state.log, [])
    state
  end

  # output functions

  defp format_event({event, ix}) do
    Map.merge(%{index: ix, player: event.seat, type: event.event_type}, event.params)
  end

  def output(state) do
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
