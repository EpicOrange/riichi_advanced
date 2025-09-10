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
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      # replace tile bindings with divs
      bindings = bindings
      |> Map.new(fn {k, v} ->
        {k, Gettext.gettext(RiichiAdvancedWeb.Gettext, "default",
          if is_list(v) do Enum.map_join(v, "", &tile_to_div/1) else v end)}
      end)
      # translate
      ret = Gettext.gettext(RiichiAdvancedWeb.Gettext, "default", ident)
      # we have to replace bindings manually,
      # since gettext expects atom keys in bindings
      # but keys are user-provided, thus cannot be atoms
      for {from, to} <- bindings, reduce: ret do
        ret -> String.replace(ret, "%{#{from}}", to)
      end
    end)
  end

  # dynamic
  def dt(_lang, nil) do
    # IO.puts("WARNING: tried to translate nil!")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    ""
  end
  def dt(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident)
    end)
  end
  def dt(_lang, nil, _bindings) do
    # IO.puts("WARNING: tried to translate nil!")
    # IO.inspect(Process.info(self(), :current_stacktrace))
    ""
  end
  # use <%= raw dt_tiles() %> if you want to display tiles
  def dt(lang, ident, bindings) when is_map(bindings) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      # replace tile bindings with divs
      bindings = bindings
      |> Map.new(fn {k, v} ->
        {k, Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default",
          if is_list(v) do Enum.map_join(v, "", &tile_to_div/1) else v end)}
      end)
      # translate
      ret = Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident)
      # we have to replace bindings manually,
      # since gettext expects atom keys in bindings
      # but keys are user-provided, thus cannot be atoms
      for {from, to} <- bindings, reduce: ret do
        ret -> String.replace(ret, "%{#{from}}", to)
      end
    end)
  end

  def tile_to_div(tile) do
    "<div class=\"#{tile |> Utils.to_tile() |> Utils.get_tile_class() |> Enum.join(" ")}\"></div>"
  end

  # hints
  def t_noop(_ident), do: :ok
end