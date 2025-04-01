defmodule RiichiAdvancedWeb.Translations do
  alias RiichiAdvanced.Utils, as: Utils
  use Gettext, backend: RiichiAdvancedWeb.Gettext

  # static
  def t(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.gettext(RiichiAdvancedWeb.Gettext, ident)
    end)
  end
  def t(lang, ident, bindings) when is_map(bindings) do
    bindings = Map.new(bindings, fn {k, v} -> {k, Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", v)} end)
    ret = Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.gettext(RiichiAdvancedWeb.Gettext, ident, bindings)
    end)
    if ident == ret do
      # no entry found, so gettext doesn't do substitution, so substitute variables manually
      for {from, to} <- bindings, reduce: ident do
        ident -> String.replace(ident, "%{#{from}}", to)
      end
    else ret end
  end

  # dynamic
  def dt(_lang, nil) do
    IO.puts("WARNING: tried to translate nil!")
    IO.inspect(Process.info(self(), :current_stacktrace))
    ""
  end
  def dt(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident)
    end)
  end
  def dt(_lang, nil, _bindings) do
    IO.puts("WARNING: tried to translate nil!")
    IO.inspect(Process.info(self(), :current_stacktrace))
    ""
  end
  # use <%= raw dt_tiles() %> if you want to display tiles
  def dt(lang, ident, bindings) when is_map(bindings) do
    # remove tile bindings
    {tile_bindings, bindings} = Enum.split_with(bindings, fn {_k, v} -> is_list(v) end)
    bindings = bindings
    |> Map.new()
    |> Map.merge(Map.new(tile_bindings, fn {k, v} -> {k, Enum.map_join(v, "", &tile_to_div/1)} end))
    # translate
    |> Map.new(fn {k, v} -> {k, Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", v)} end)
    ret = Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident, bindings)
    end)
    if ident == ret do
      # no entry found, so gettext doesn't do substitution, so substitute variables manually
      for {from, to} <- bindings, reduce: ident do
        ident -> String.replace(ident, "%{#{from}}", to)
      end
    else ret end
  end

  def tile_to_div(tile) do
    "<div class=\"#{tile |> Utils.to_tile() |> Utils.get_tile_class() |> Enum.join(" ")}\"></div>"
  end

  # hints
  def t_noop(_ident), do: :ok
end