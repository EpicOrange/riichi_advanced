defmodule ExSMT.Variable do
  defstruct [:key, :type, :name, :i]

  def new(type, name, i \\ nil) do
    key = mangle(type, name, i)
    %__MODULE__{key: key, type: type, name: name, i: i}
  end

  defp mangle(type, name, i) do
    name_mangled = Macro.underscore(to_string(name))
    i_part = case i do
      nil -> "_"
      n when is_integer(n) -> ["I:", to_string(n)]
      t -> ["E:", Base.encode64(:erlang.term_to_binary(t))]
    end
    "#{type}:#{name_mangled}:#{i_part}"
  end

  def from_mangled(bin) when is_binary(bin) and byte_size(bin) >= 5 do
    [type, name | i_parts] = String.split(bin, ":", trim: true)

    type = String.to_atom(type)
    name = String.to_atom(name)

    i = case i_parts do
      ["_"] -> nil
      ["I", int_str] -> String.to_integer(int_str, 10)
      ["E", etf_b64] -> :erlang.binary_to_term(Base.decode64!(etf_b64))
    end

    %__MODULE__{type: type, name: name, i: i}
  end
end

defimpl ExSMT.Serializable, for: ExSMT.Variable do
  def serialize_int(%ExSMT.Variable{key: key}) do
    ["|", to_string(key), "|"]
  end

  def serialize_bool(%ExSMT.Variable{key: key}) do
    ["(not (= |", to_string(key), "| 0))"]
  end
end

defimpl Inspect, for: ExSMT.Variable do
  import Inspect.Algebra

  def inspect(%ExSMT.Variable{type: :env, name: name, i: nil}, opts) do
    name = String.upcase(to_string(name))
    color("$#{name}", :environment_ref, opts)
  end
  def inspect(%ExSMT.Variable{type: :env, name: name, i: i}, opts) do
    name = String.upcase(to_string(name))
    concat([
      color("$#{name}", :environment_ref, opts),
      color("[", :tuple, opts),
      to_doc(i, opts),
      color("]", :tuple, opts)
    ])
  end

  def inspect(%ExSMT.Variable{type: :ssa, name: pc, i: i}, opts) when is_integer(i) do
    color("%#{pc}:#{i}", :identifier_ref, opts)
  end
  def inspect(%ExSMT.Variable{type: :ssa, name: pc, i: i}, opts) do
    concat([
      color("%#{pc}[", :identifier_ref, opts),
      to_doc(i, opts),
      color("]", :identifier_ref, opts)
    ])
  end
  def inspect(%ExSMT.Variable{name: pc, i: nil}, opts) do
    color("%#{pc}", :identifier_ref, opts)
  end
end
