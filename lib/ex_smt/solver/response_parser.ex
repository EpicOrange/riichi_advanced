defmodule ExSMT.Solver.ResponseParser do
  import NimbleParsec

  integer =
    optional(ascii_char([?-]))
    |> ascii_string([?0..?9], min: 1)
    |> tag(:integer)

  binary =
    ignore(ascii_char([?#]))
    |> ignore(ascii_char([?b]))
    |> ascii_string([?0, ?1], min: 1)
    |> tag(:binary)

  hex =
    ignore(ascii_char([?#]))
    |> ignore(ascii_char([?x]))
    |> ascii_string([?0..?9, ?a..?f], min: 1)
    |> tag(:hex)

  decimal =
    optional(ascii_char([?-]))
    |> ascii_string([?0..?9], min: 1)
    |> ascii_char([?.])
    |> ascii_string([?0..?9], min: 1)
    |> tag(:decimal)

  mangled_var =
    ignore(ascii_char([?|]))
    |> utf8_string([{:not, ?|}], min: 1)
    |> ignore(ascii_char([?|]))
    |> tag(:var)

  identifier =
    ascii_string([?a..?z, ?A..?Z, ?0..?9, ?-, ?_], min: 1)
    |> tag(:identifier)

  atom =
    ignore(ascii_char([?:]))
    |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?-, ?_], min: 1)
    |> tag(:atom)

  string =
    ignore(ascii_char([?"]))
    |> optional(utf8_string([{:not, ?"}], min: 1))
    |> ignore(ascii_char([?"]))
    |> tag(:string)

  operator =
    empty()
    |> choice([
      string("<="),
      string("<"),
      string("="),
      string(">="),
      string(">"),
      string("!")
    ])
    |> tag(:operator)

  sort =
    ascii_char([?A..?Z])
    |> repeat(ascii_char([?a..?z, ?A..?Z, ?0..?9, ?-, ?_]))
    |> tag(:sort)

  empty_list =
    ignore(ascii_char([?(]))
    |> ignore(ascii_char([?)]))
    |> tag(:empty_list)

  flexible_space =
    ignore(ascii_string([?\s, ?\r, ?\n, ?\t, ?\v], min: 1))

  sexpr =
    ignore(ascii_char([?(]))
    |> optional(flexible_space)
    |> parsec(:sexpr_term)
    |> repeat(flexible_space |> parsec(:sexpr_term))
    |> optional(flexible_space)
    |> ignore(ascii_char([?)]))
    |> tag(:list)

  defparsec :sexpr_term, choice([
    decimal,
    binary,
    hex,
    integer,
    string,
    mangled_var,
    operator,
    identifier,
    atom,
    sort,
    empty_list,
    sexpr,
  ])

  newline = ignore(ascii_char([?\n]))

  defparsec :response, repeat(
    optional(flexible_space)
    |> parsec(:sexpr_term)
    |> tag(:response_term)
    |> concat(newline)
  )

  def parse(lns) when is_list(lns), do:
    parse(IO.iodata_to_binary(lns))
  def parse(lns) when is_binary(lns) do
    {:ok, results, "", %{}, _, _} = response(lns)
    Enum.map(results, &normalize_types/1)
  end

  defp normalize_types({:response_term, [t]}), do:
    normalize_types(t)
  defp normalize_types({:list, l}), do:
    Enum.map(l, &normalize_types/1)
  defp normalize_types({:identifier, [id_str]}), do:
    String.to_atom(id_str)
  defp normalize_types({:operator, [str]}), do:
    String.to_atom(str)
  defp normalize_types({:atom, [str]}), do:
    String.to_atom(str)
  defp normalize_types({:var, [mangled]}), do:
    ExSMT.Variable.from_mangled(mangled)
  defp normalize_types({:empty_list, []}), do:
    []
  defp normalize_types({:integer, [digits_str]}), do:
    String.to_integer(digits_str)
  defp normalize_types({:bin, [digits_str]}), do:
    String.to_integer(digits_str, 2)
  defp normalize_types({:hex, [digits_str]}), do:
    String.to_integer(digits_str, 16)
  defp normalize_types({:decimal, digits_str}) do
    {:ok, dec} =
      IO.iodata_to_binary(digits_str)
      |> Decimal.parse()
    dec
  end
  defp normalize_types({:string, [bin]}), do:
    bin
end
