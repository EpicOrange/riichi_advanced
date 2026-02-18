defmodule RiichiAdvancedWeb.TipsComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  @tips [
    "If the AI is stuck or missing, click the center compass to try to unstuck them.",
    "After someone calls a win, hover over the winning hand to see how it breaks into sets. (On mobile: tap the winning hand.)",
    "Public rooms show up in the lobby. The lobby screen only exists if there is at least one public room, otherwise it just drops you directly in a new room.",
    "To join a private room, select the ruleset you're playing, and then press \"Join private room\" in the main menu and enter the room code of the room you want to join. Then hit Play.",
    "If you scroll down now, or during a game, you can see the JSON representation of the ruleset you're playing. Which you can modify and play in the Custom ruleset.",
    "You can double click or right click to discard your drawn tile. (On mobile: double tap or long tap.)",
    "When you start a game, it will send a message saying \"Log ID:\" followed by a code. You can use this code at (main menu) > Logs to view a replay of this game afterwards.",
    "A game's log ID can also be found via the Copy Log button on the upper right.",
    # can also add tips about specific rulesets
    # e.g. "In Space Mahjong, any three different winds form a sequence."
    # will need a mechanism to only show them in the Space Mahjong lobby though
  ]

  def mount(socket) do
    n = Enum.count(@tips)
    socket = socket
    |> assign(:tips, @tips)
    |> assign(:num_tips, n)
    |> assign(:index, :rand.uniform(n) - 1)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="tips-component" phx-cancellable-click="tips_clicked" phx-target={@myself}>
      <%= if @root_pid != nil do %>
        <%= dt(@lang, "Tip") %> <%= dt(@lang, Integer.to_string(@index + 1)) %>: <%= dt(@lang, Enum.at(@tips, @index)) %>
      <%= end %>
    </div>
    """
  end

  def handle_event("tips_clicked", _assigns, socket) do
    new_index = socket.assigns.index + 1;
    new_index = if new_index >= socket.assigns.num_tips do 0 else new_index end
    socket = assign(socket, :index, new_index)
    {:noreply, socket}
  end
end
