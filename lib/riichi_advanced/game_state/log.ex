defmodule GameEvent do
  defstruct [
    seat: nil,
    event_name: nil,
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

  def log(state, seat, event_name, params) do
    update_in(state.log_state.log, &[%GameEvent{ seat: seat, event_name: event_name, params: params } | &1])
  end

  # def adjudicate_calls(state) do

  # end

  # def queue_call(state, seat, call

  # def modify_last_log(state, fun) do
  #   Map.update!(state, :log, &List.update_at(&1, 0, fun))
  # end

end
