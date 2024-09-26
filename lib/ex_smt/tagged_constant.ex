defmodule ExSMT.TaggedConstant do
  defstruct [:tag, :value, equiv_expr: nil]

  def new(tag, value) when is_atom(tag), do:
    %__MODULE__{tag: tag, value: value}

  def new(tag, value, equiv_expr) when is_atom(tag) and equiv_expr != nil, do:
    %__MODULE__{tag: tag, value: value, equiv_expr: equiv_expr}
end

defimpl ExSMT.Serializable, for: ExSMT.TaggedConstant do
  def serialize_bool(%ExSMT.TaggedConstant{value: value}), do:
    ExSMT.Serializable.serialize_bool(value)

  def serialize_int(%ExSMT.TaggedConstant{value: value}), do:
    ExSMT.Serializable.serialize_int(value)
end

defimpl Inspect, for: ExSMT.TaggedConstant do
  import Inspect.Algebra

  def inspect(%ExSMT.TaggedConstant{equiv_expr: expr}, opts) when expr != nil, do:
    to_doc(expr, opts)

  def inspect(%ExSMT.TaggedConstant{tag: tag, value: value, equiv_expr: nil}, opts) do
    concat([
      color("(", :operator, opts),
      space(
        to_doc(value, opts),
        concat([
          color("♯#{tag}", :operator, opts),
        ])
      ),
      color(")", :operator, opts)
    ])
  end
end
