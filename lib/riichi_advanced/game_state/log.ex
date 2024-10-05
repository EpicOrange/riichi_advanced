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
    params = %{possible_calls: Enum.flat_map(state.players, fn {seat, player} -> Enum.map(player.button_choices, fn {name, choices} -> %{seat: seat, name: name, choices: choices} end) end)}
    modify_last_draw_discard(state, fn event -> %GameEvent{ event | params: Map.merge(event.params, params) } end)
  end

end
