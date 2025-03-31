defmodule RiichiAdvancedWeb.Translations do
  use Gettext, backend: RiichiAdvancedWeb.Gettext

  # static
  def t(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.gettext(RiichiAdvancedWeb.Gettext, ident)
    end)
  end
  def t(lang, ident, bindings) do
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
  def dt(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident)
    end)
  end
  def dt(lang, ident, bindings) do
    bindings = Map.new(bindings, fn {k, v} -> {k, Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", v)} end)
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

  # hints
  def t_noop(_ident), do: :ok
end