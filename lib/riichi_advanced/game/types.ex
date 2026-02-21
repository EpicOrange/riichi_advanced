defmodule RiichiAdvanced.Types do
  @type seat() :: :east | :south | :west | :north
  @type win_source() :: :discard | :draw | :call
  @type modifier_op() :: :+ | :- | :* | :/ | :round_up | :round_down
  @type modifier() :: {modifier_op(), number() | nil, binary()}
  @type line_item() :: %{
    op: binary() | nil,
    amount: number(),
    result: number(),
    reason: binary(),
  }

  defmodule Transaction do
    @type seat() :: RiichiAdvanced.Types.seat()
    @type line_item() :: RiichiAdvanced.Types.line_item()
    @type t :: %__MODULE__{
      name: binary(),
      from: seat() | nil,
      to: seat() | nil,
      line_items: list(line_item()), # reverse order
    }
    defstruct [
      name: "",
      from: nil,
      to: nil,
      line_items: [],
    ]
  end
end
