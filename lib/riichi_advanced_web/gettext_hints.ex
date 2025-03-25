defmodule RiichiAdvancedWeb.GettextHints do
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def gettext_hints do
    # messages
    t_noop("Welcome to Riichi Advanced!")
  end
end
