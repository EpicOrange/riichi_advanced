defmodule RiichiAdvanced.Formatter do
  # formats json so that it looks good in the ruleset box

  @spec _format(any(), false | nil | true | atom() | binary() | list() | number() | map()) :: binary()
  def _format(_, true), do: "true"
  def _format(_, false), do: "false"
  def _format(_, nil), do: "null"
  def _format(_, obj) when is_integer(obj), do: Integer.to_string(obj)
  def _format(_, obj) when is_float(obj), do: Float.to_string(obj)
  def _format(_, obj) when is_atom(obj), do: inspect(Atom.to_string(obj))
  def _format(_, obj) when is_binary(obj), do: inspect(obj)
  def _format(%{spaces: spaces, line_width: line_width} = cxt, obj) when is_map(obj) do # object
    indent = String.duplicate(" ", spaces)
    items = Enum.map(obj, fn {k, v} -> "#{_format(cxt, k)}: #{_format(%{cxt | spaces: spaces + 2}, v)}" end)
    length_estimate = Enum.reduce(items, -2, fn item, sum -> 2 + sum + String.length(item) end)
    if spaces + length_estimate + 2 <= line_width do
      "\{#{Enum.join(items, ", ")}\}"
    else
      "\{\n#{Enum.map_join(items, ",\n", &"  #{indent}#{&1}")}\n#{indent}\}"
    end
  end
  def _format(%{spaces: spaces, line_width: line_width} = cxt, obj) when is_list(obj) do # array
    case obj do
      []  -> "[]"
      [x] -> "[#{_format(cxt, x)}]"
      _   ->
        indent = String.duplicate(" ", spaces)
        items = Enum.map(obj, fn v -> _format(%{cxt | spaces: spaces + 2}, v) end)
        length_estimate = Enum.reduce(items, -2, fn item, sum -> 2 + sum + String.length(item) end)
        if spaces + length_estimate + 2 <= line_width do
          "[#{Enum.join(items, ", ")}]"
        else
          # try to combine items until they exceed line length OR we have 8 items in a line
          items = break_list(items, line_width - spaces, 8)
          "[\n#{Enum.map_join(items, ",\n", &"  #{indent}#{&1}")}\n#{indent}]"
        end
    end
  end

  def break_list(items, width, max_count) do
    Enum.reduce(items, [[]], fn next, [line | rest] = acc ->
      length_estimate = Enum.reduce(line, String.length(next), fn i, sum -> 2 + sum + String.length(i) end)
      if line == [] or (length_estimate <= width and length(line) + 1 <= max_count) do
        [[next | line] | rest]
      else
        [[next] | acc]
      end
    end)
    |> Enum.reverse()
    |> Enum.map(&Enum.join(Enum.reverse(&1), ", "))
  end

  @spec format(any()) :: binary()
  def format(str, line_width \\ 10) do
    _format(%{spaces: 0, line_width: line_width}, str)
  end
end
