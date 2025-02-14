
# for encoding tiles with attrs, which are tuples, which Jason doesn't handle unless we do this
defimpl Jason.Encoder, for: Tuple do
  alias RiichiAdvanced.Utils, as: Utils
  
  def encode(data, opts) when is_tuple(data) do
    # turn {:"3p", ["hand"]} into its json version, "3p"
    case Utils.to_tile(data) do
      # {tile_id, attrs} -> Jason.Encode.map(%{"tile" => Atom.to_string(tile_id), "attrs" => attrs}, opts)
      # _                -> Jason.Encode.atom(data, opts)
      {tile_id, _attrs} -> Jason.Encode.atom(tile_id, opts)
      _                 -> Jason.Encode.atom(data, opts)
    end
  end
end

defmodule RiichiAdvanced.GameState.Log do
  alias RiichiAdvanced.GameState.Marking, as: Marking
  alias RiichiAdvanced.Utils, as: Utils

  defmodule GameEvent do
    defstruct [
      seat: nil,
      event_type: nil,
      params: %{}
    ]
  end

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

  def from_seat(seat) do
    case seat do
      0 -> :east
      1 -> :south
      2 -> :west
      3 -> :north
      _ -> nil
    end
  end

  def log(state, seat, event_type, params) do
    if seat != nil do
      update_in(state.log_state.log, &[%GameEvent{ seat: to_seat(seat), event_type: event_type, params: params } | &1])
    else
      update_in(state.log_state.log, &[%GameEvent{ event_type: event_type, params: params } | &1])
    end
  end

  defp modify_last_draw_discard(state, fun) do
    ix = Enum.find_index(state.log_state.log, fn event -> event.event_type == :draw or event.event_type == :discard end)
    if ix != nil do
      update_in(state.log_state.log, &List.update_at(&1, ix, fun))
    else
      IO.puts("Tried to update last draw/discard of log, but there is none")
      state
    end
  end

  defp modify_last_button_press(state, fun, create_at_seat) do
    state = case Enum.at(state.log_state.log, 0) do
      event when (event != nil and event.event_type == :buttons_pressed) ->
        if create_at_seat != nil and Enum.at(event.params.buttons, to_seat(create_at_seat)) != nil do
          log(state, nil, :buttons_pressed, %{buttons: [nil, nil, nil, nil]})
        else state end
      _ -> log(state, nil, :buttons_pressed, %{buttons: [nil, nil, nil, nil]})
    end
    update_in(state.log_state.log, &List.update_at(&1, 0, fun))
  end

  def add_call_choices(state, seat, call_name, call_choices) do
    possible_calls = for {called_tile, choices} <- call_choices do
      for choice <- choices do
        if state.turn == seat do
          # self call
          %{player: to_seat(seat), type: call_name, tiles: choice ++ [called_tile]}
        else
          %{player: to_seat(seat), type: call_name, tiles: choice}
        end
      end
    end |> Enum.concat() |> Enum.uniq()
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.update(event.params, :possible_calls, possible_calls, &Enum.uniq(&1 ++ possible_calls)) } end)
  end

  # def add_possible_calls(state) do
  #   possible_calls = for {seat, player} <- state.players do
  #     for {name, {:call, choices}} <- player.button_choices do
  #       for choice <- Map.values(choices) |> Enum.concat() do
  #         %{player: to_seat(seat), type: name, tiles: choice}
  #       end
  #     end |> Enum.concat()
  #   end |> Enum.concat()
  #   modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.put(event.params, :possible_calls, possible_calls) } end)
  # end

  def add_call(state, seat, call_name, call_choice, called_tile) do
    tiles = call_choice ++ if called_tile != nil do [called_tile] else [] end
    call = %{player: to_seat(seat), type: call_name, tiles: tiles}
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.put(event.params, :call, call) } end)
  end

  def add_button_press(state, seat, button_name, data \\ %{}) do
    modify_last_button_press(state, fn event -> %GameEvent{ event | params: Map.update!(event.params, :buttons, &List.replace_at(&1, to_seat(seat), Map.merge(%{button: button_name}, data))) } end, seat)
  end

  # def add_button_data(state, seat, data) do
  #   modify_last_button_press(state, fn event -> %GameEvent{ event | params: Map.update!(event.params, :buttons, &List.update_at(&1, to_seat(seat), fn m -> Map.merge(m, data) end)) } end, nil)
  # end

  # def remove_button_press(state, seat) do
  #   modify_last_button_press(state, fn event -> %GameEvent{ event | params: Map.update!(event.params, :buttons, &List.replace_at(&1, to_seat(seat), nil)) } end, nil)
  # end

  def encode_marking(marking) do
    # [
    #   done: true,
    #   hand: %{
    #     needed: 3,
    #     restrictions: ["self"],
    #     marked: [{:"9s", :east, 12}, {:"7s", :east, 11}, {:"2s", :east, 10}]
    #   }
    # ]
    for {kw, val} <- marking do
      if kw in Marking.special_keys() do
        [Atom.to_string(kw), val]
      else
        val = Map.update!(val, :marked, &Enum.map(&1, fn {t, s, i} -> [t, Atom.to_string(s), i] end))
        |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
        [Atom.to_string(kw), val]
      end
    end
  end

  def decode_marking(marking) do
    # [
    #   ["done", true],
    #   ["hand", %{
    #     "marked" => [["9s", "east", 12], ["7s", "east", 11], ["5s", "east", 10]],
    #     "needed" => 3,
    #     "restrictions" => ["self"]
    #   }]
    # ]
    for [kw, val] <- marking do
      if kw in Enum.map(Marking.special_keys(), &Atom.to_string/1) do
        {String.to_existing_atom(kw), val}
      else
        val = Map.new(val, fn {k, v} -> {String.to_existing_atom(k), v} end)
        val = Map.update!(val, :marked, &Enum.map(&1, fn [t, s, i] -> {Utils.to_tile(t), String.to_existing_atom(s), i} end))
        {String.to_existing_atom(kw), val}
      end
    end
  end

  def finalize_kyoku(state) do
    state = update_in(state.log_state.kyokus, fn kyokus -> [%{
      index: length(state.log_state.kyokus),
      players: Enum.map(state.available_seats, fn dir -> %{
        points: state.players[dir].start_score,
        haipai: state.haipai[dir]
      } end),
      kyoku: state.kyoku,
      honba: if Map.get(state.rules, "display_riichi_sticks", false) do state.honba else 0 end,
      riichi_sticks: if Map.get(state.rules, "display_riichi_sticks", false) do Integer.floor_div(state.pot, state.rules["score_calculation"]["riichi_value"]) else 0 end,
      doras: for i <- -6..-14//-2 do Enum.at(state.dead_wall, i) end |> Enum.filter(& &1 != nil),
      uras: for i <- -5..-14//-2 do Enum.at(state.dead_wall, i) end |> Enum.filter(& &1 != nil),
      kan_tiles: Enum.take(state.dead_wall, -4),
      wall: state.wall |> Enum.drop(52) |> Enum.take(70),
      die1: state.die1,
      die2: state.die2,
      events: state.log_state.log
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(&format_event/1),
      result: for {seat, winner} <- state.winners do
        %{
          seat: to_seat(seat),
          pao: to_seat(Map.get(winner, :pao_seat, nil)),
          won_from: to_seat(winner.payer),
          hand: winner.winning_hand,
          tile: winner.winning_tile,
          yaku: Enum.map(winner.yaku, fn {name, value} -> [name, value] end),
          yakuman: Enum.map(Map.get(winner, :yakuman, []), fn {name, value} -> [name, value] end),
          han: winner.points,
          fu: Map.get(winner, :minipoints, 0),
          yakuman_mult: Map.get(winner, :yakuman_mult, 0),
          points: winner.score,
          delta_points: Enum.map(state.available_seats, fn dir -> state.delta_scores[dir] end),
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
      ref: state.ref,
      players: Enum.map(state.players, fn {seat, player} -> %{
        name: if player.nickname == nil do Atom.to_string(seat) else player.nickname end,
        score: player.score,
        payout: player.score # TODO no uma?
      } end),
      rules: %{
        ruleset: state.ruleset,
        ruleset_json: "",
        mods: state.mods
      },
      kyokus: Enum.reverse(state.log_state.kyokus)
    }
    out = if state.ruleset == "custom" do
      put_in(out.rules.ruleset_json, state.ruleset_json)
    else out end
    Jason.encode!(out)
  end

  def output_to_file(state) do
    output_json = output(state)
    File.write!(Application.app_dir(:riichi_advanced, "/priv/static/logs/#{state.ref <> ".json"}"), output_json)
  end

end
