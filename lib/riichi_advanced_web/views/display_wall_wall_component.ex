defmodule RiichiAdvancedWeb.DisplayWallWallComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :wall, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= for tiles <- @wall do %>
          <%= if tiles == [:dead, :wall] do %>
            <div class="spacer"></div>
          <% else %>
            <div class="tile-stack">
              <%= for {tile, i} <- Enum.with_index(Enum.reverse(tiles)) do %>
                <div class={Utils.get_tile_class(tile, i, assigns)} style={"--level: #{i}"}></div>
              <% end %>
            </div>
          <% end %>
      <% end %>
    </div>
    """
  end

end
