defmodule ExSMT.Expression do
  require Bitwise

  defstruct [op: nil, args: [], var_decls: MapSet.new()]

  def new(op, args, opts \\ []) do
    case Keyword.get(opts, :simplify, true) do
      true ->
        case simplify_trivial(op, args) do
          {:ok, concrete_t} -> concrete_t
          :error -> %__MODULE__{op: op, args: args, var_decls: var_decls(args)}
        end
      false ->
        %__MODULE__{op: op, args: args, var_decls: var_decls(args)}
    end
  end

  def append(%__MODULE__{args: args, var_decls: vd} = f, new_arg), do:
    %__MODULE__{f | args: args ++ [new_arg], var_decls: var_decls_add(vd, new_arg)}

  defp var_decls(%__MODULE__{var_decls: vd}), do: Enum.to_list(vd)
  defp var_decls(%ExSMT.Variable{} = var), do: [var]
  defp var_decls(l) when is_list(l) do
    Enum.flat_map(l, &var_decls/1)
    |> Enum.into(MapSet.new())
  end
  defp var_decls(_), do: MapSet.new()

  defp var_decls_add(vd1, %__MODULE__{var_decls: vd2}), do:
    MapSet.union(vd1, vd2)
  defp var_decls_add(vd, %ExSMT.Variable{} = var), do:
    MapSet.put(vd, var)
  defp var_decls_add(%MapSet{} = vd, _), do:
    vd
  defp var_decls_add(vd, _), do:
    Enum.into(vd, MapSet.new())

  defp simplify_trivial(op, l) do
    case simplify_by_identity(op, l) do
      {:ok, simplified} ->
        {:ok, simplified}
      :error ->
        case concretize_args(l, []) do
          {:ok, concrete_args} ->
            simplify_trivial_op(op, concrete_args)
          :error ->
            :error
        end
    end
  end

  defp concretize_args([], acc), do: {:ok, Enum.reverse(acc)}
  defp concretize_args([t | rest], acc) do
    case concretize(t) do
      {:ok, concrete_t} -> concretize_args(rest, [concrete_t | acc])
      :error -> :error
    end
  end

  def simplify_trivial_op(:+, els), do:
    {:ok, Enum.reduce(els, 0, &(&1 + &2))}
  def simplify_trivial_op(:-, [a, b]), do:
    {:ok, a - b}
  def simplify_trivial_op(:mask, [a, b]), do:
    {:ok, Bitwise.band(a, b)}
  def simplify_trivial_op(:*, els), do:
    {:ok, Enum.reduce(els, 1, &(&1 * &2))}
  def simplify_trivial_op(:div, [a, b]) when b != 0, do:
    {:ok, div(a, b)}
  def simplify_trivial_op(:mod, [a, b]) when b != 0, do:
    {:ok, rem(a, b)}
  def simplify_trivial_op(_, _), do:
    :error

  def simplify_by_identity(:=, [a, a]), do: {:ok, true}
  def simplify_by_identity(:+, [0, a]), do: {:ok, a}
  def simplify_by_identity(:+, [a, 0]), do: {:ok, a}
  def simplify_by_identity(:*, [1, a]), do: {:ok, a}
  def simplify_by_identity(:*, [a, 1]), do: {:ok, a}
  def simplify_by_identity(:*, [0, _]), do: {:ok, 0}
  def simplify_by_identity(:*, [_, 0]), do: {:ok, 0}
  def simplify_by_identity(:"<<", [a, 0]), do: {:ok, a}
  def simplify_by_identity(:">>", [a, 0]), do: {:ok, a}
  def simplify_by_identity(:div, [0, _]), do: {:ok, 0}
  def simplify_by_identity(:div, [a, 1]), do: {:ok, a}
  def simplify_by_identity(:mod, [0, _]), do: {:ok, 0}
  def simplify_by_identity(:mod, [_, 1]), do: {:ok, 0}
  def simplify_by_identity(_op, _args), do: :error

  def concretize(true), do: {:ok, true}
  def concretize(false), do: {:ok, false}
  def concretize(n) when is_integer(n), do: {:ok, n}
  def concretize(str) when is_binary(str), do: {:ok, str}
  def concretize(_), do: :error

  def serialize(%__MODULE__{op: :toplevel, args: [arg], var_decls: var_decls}) do
    var_decls = Enum.map(var_decls, fn var ->
      ["(declare-const ", ExSMT.Serializable.serialize_int(var), " Int)\n"]
    end)
    assertion = ["(assert ", ExSMT.Serializable.serialize_bool(arg), ")\n"]
    [var_decls, assertion]
  end
end

defimpl ExSMT.Serializable, for: ExSMT.Expression do
  require Bitwise

  @bool_to_bool [:and, :or, :not]
  @int_to_bool [:=, :<, :>, :<=, :>=]

  def serialize_bool(%ExSMT.Expression{op: :and, args: []}), do: ["true"]
  def serialize_bool(%ExSMT.Expression{op: :or, args: []}), do: ["false"]
  def serialize_bool(%ExSMT.Expression{op: :not, args: []}), do: ["false"]
  def serialize_bool(%ExSMT.Expression{op: :not, args: [%ExSMT.Expression{op: :not, args: [expr]}]}), do:
    ExSMT.Serializable.serialize_bool(expr)
  def serialize_bool(%ExSMT.Expression{op: op, args: args}) when op in @bool_to_bool do
    ser_args =
      Enum.map(args, &ExSMT.Serializable.serialize_bool/1)
      |> Enum.intersperse(" ")

    ["(", to_string(op), " ", ser_args, ")"]
  end
  def serialize_bool(%ExSMT.Expression{op: op, args: args}) when op in @int_to_bool do
    ser_args =
      Enum.map(args, &ExSMT.Serializable.serialize_int/1)
      |> Enum.intersperse(" ")
    ["(", to_string(op), " ", ser_args, ")"]
  end
  def serialize_bool(%ExSMT.Expression{op: op, args: args}) do
    ser_args =
      Enum.map(args, &ExSMT.Serializable.serialize_int/1)
      |> Enum.intersperse(" ")
    ["(not (= (", to_string(op), " ", ser_args, ") 0))"]
  end

  def serialize_int(%ExSMT.Expression{op: :and, args: []}), do: ["1"]
  def serialize_int(%ExSMT.Expression{op: :or, args: []}), do: ["0"]
  def serialize_int(%ExSMT.Expression{op: :not, args: []}), do: ["0"]
  def serialize_int(%ExSMT.Expression{op: :exp, args: [2, power]}) when is_integer(power), do:
    ExSMT.Serializable.serialize_int(Bitwise.bsl(1, power))
  def serialize_int(%ExSMT.Expression{op: :">>", args: [expr, width]}) when is_integer(width), do:
    ExSMT.Serializable.serialize_int(ExSMT.Expression.new(:div, expr, Bitwise.bsl(1, width)))
  def serialize_int(%ExSMT.Expression{op: :"<<", args: [expr, width]}) when is_integer(width), do:
    ExSMT.Serializable.serialize_int(ExSMT.Expression.new(:*, expr, Bitwise.bsl(1, width)))
  def serialize_int(%ExSMT.Expression{op: :mask, args: [expr, _mask]}), do:
    ExSMT.Serializable.serialize_int(expr)
  def serialize_int(%ExSMT.Expression{op: :not, args: [%ExSMT.Expression{op: :not, args: [expr]}]}), do:
    ExSMT.Serializable.serialize_int(expr)
  def serialize_int(%ExSMT.Expression{op: op} = expr) when op in @bool_to_bool, do:
    ["(ite ", serialize_bool(expr), " 1 0)"]
  def serialize_int(%ExSMT.Expression{op: op, args: args}) when op in @int_to_bool do
    ser_args =
      Enum.map(args, &ExSMT.Serializable.serialize_int/1)
      |> Enum.intersperse(" ")
    ["(ite (", to_string(op), " ", ser_args, ") 1 0)"]
  end
  def serialize_int(%ExSMT.Expression{op: op, args: args}) do
    ser_args =
      Enum.map(args, &ExSMT.Serializable.serialize_int/1)
      |> Enum.intersperse(" ")
    ["(", to_string(op), " ", ser_args, ")"]
  end
end

defimpl Inspect, for: ExSMT.Expression do
  import Inspect.Algebra

  def inspect(%ExSMT.Expression{op: true}, opts), do:
    color("⊤", :nil, opts)
  def inspect(%ExSMT.Expression{op: false}, opts), do:
    color("⊥", :nil, opts)

  def inspect(%ExSMT.Expression{op: :and, args: []}, opts), do:
    color("⊤", :nil, opts)
  def inspect(%ExSMT.Expression{op: :and, args: args}, opts) do
    pre = color("(", :tuple, opts)
    post = color(")", :tuple, opts)
    sep = color(" ∧", :operator, opts)
    nest(container_doc(pre, args, post, opts, &to_doc/2, separator: sep, break: :flex), 2)
  end

  def inspect(%ExSMT.Expression{op: :or, args: []}, opts), do:
    color("⊥", :nil, opts)
  def inspect(%ExSMT.Expression{op: :or, args: args}, opts) do
    pre = color("(", :tuple, opts)
    post = color(")", :tuple, opts)
    sep = color(" ∨", :operator, opts)
    nest(container_doc(pre, args, post, opts, &to_doc/2, separator: sep, break: :flex), 2)
  end

  def inspect(%ExSMT.Expression{op: :not, args: [arg]}, opts) do
    concat([
      color("!", :operator, opts),
      to_doc(arg, opts)
    ])
  end

  def inspect(%ExSMT.Expression{op: op, args: args}, opts) do
    pre = color("(", :hidden, opts)
    post = color(")", :hidden, opts)
    sep = color("", :tuple, opts)
    args = [op | args]
    nest(container_doc(pre, args, post, opts, &to_doc_or_operator/2, separator: sep, break: :flex), 2)
  end

  defp to_doc_or_operator(op_name, opts) when is_atom(op_name), do:
    color(to_string(op_name), :operator, opts)
  defp to_doc_or_operator(t, opts), do:
    to_doc(t, opts)
end
