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

  defmodule Responsibility do
    @type seat() :: RiichiAdvanced.Types.seat()
    @type modifier :: RiichiAdvanced.Types.modifier()
    @type t :: %__MODULE__{
      from: seat() | nil,
      to: seat() | nil,
      yaku_spec: list(binary()),
      scoring_key: binary(),

      yaku: list({binary(), number()}),
      yaku2: list({binary(), number()}),
      minipoints: number(),
      modifiers: list(modifier()),
    }
    defstruct [
      from: nil, # who is responsible for paying the yaku+minipoints?
      to: nil,   # who gets this payment?
      yaku_spec: [],
      scoring_key: "", # e.g. "ron", defined by ruleset

      # below is to be removed
      yaku: [],
      yaku2: [],
      minipoints: 0,
      modifiers: [], # ordered list of {op, amount, reason}
    ]
  end
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
  defmodule WinInfo do
    @type seat() :: RiichiAdvanced.Types.seat()
    @type win_source() :: RiichiAdvanced.Types.win_source()
    @type modifier() :: RiichiAdvanced.Types.modifier()
    @type t :: %__MODULE__{
      seat: seat(),
      won_by: {win_source(), seat()},
      yaku: list({binary(), number()}),
      yaku2: list({binary(), number()}),
      minipoints: number(),
      pao_map: %{seat() => list(binary())},
      available_seats: list(seat()),
      modifiers: list(modifier())
    }
    defstruct [
      seat: :east,
      won_by: {:discard, :east},
      yaku: [], # {name, value} pairs
      yaku2: [], # {name, value} pairs
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
end
