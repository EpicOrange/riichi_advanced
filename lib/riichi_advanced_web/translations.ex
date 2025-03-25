defmodule RiichiAdvancedWeb.Translations do
  use Gettext, backend: RiichiAdvancedWeb.Gettext

  # static
  def t(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.gettext(RiichiAdvancedWeb.Gettext, ident)
    end)
  end
  def t(lang, ident, bindings) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      localized = Map.new(bindings, fn {k, v} -> {k, Gettext.dgettext(Gettext, "default", v)} end)
      Gettext.gettext(RiichiAdvancedWeb.Gettext, ident, localized)
    end)
  end

  # dynamic
  def dt(lang, ident) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident)
    end)
  end
  def dt(lang, ident, bindings) do
    Gettext.with_locale(RiichiAdvancedWeb.Gettext, lang, fn ->
      localized = Map.new(bindings, fn {k, v} -> {k, Gettext.dgettext(Gettext, "default", v)} end)
      Gettext.dgettext(RiichiAdvancedWeb.Gettext, "default", ident, localized)
    end)
  end

  # hints
  def t_noop(ident) do
    Gettext.gettext_noop(RiichiAdvancedWeb.Gettext, ident)
  end
end