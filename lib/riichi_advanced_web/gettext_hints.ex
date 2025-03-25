defmodule RiichiAdvancedWeb.GettextHints do
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def gettext_hints do
    # messages
    t_noop("Welcome to Riichi Advanced!")
    t_noop("Player")
    t_noop("Player %{nickname} joined as %{seat}")
    t_noop("east")
    t_noop("south")
    t_noop("west")
    t_noop("north")
    t_noop("exited")
    t_noop("called %{call} on %{tile} with hand %{hand}")
    t_noop("discarded %{tile}")
    t_noop("from hand")

    # rules tabs
    t_noop("Rules")
    t_noop("1 Han")
    t_noop("2 Han")
    t_noop("3 Han")
    t_noop("4 Han")
    t_noop("5 Han")
    t_noop("Yakuman")

  end
end
