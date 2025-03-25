defmodule RiichiAdvancedWeb.GettextHints do
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def gettext_hints do
    # messages
    t_noop("Welcome to Riichi Advanced!")
    t_noop("Player %{nickname} joined as %{seat}")
    t_noop("east")
    t_noop("south")
    t_noop("west")
    t_noop("north")
  end
end
