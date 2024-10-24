defmodule RiichiAdvancedWeb.DisplayWallWallComponent do
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
              <%= if length(tiles) == 1 do %>
                <div class={["tile", Enum.at(tiles, 0), "bottom"]}></div>
              <% else %>
                <div class={["tile", Enum.at(tiles, 0), "top"]}></div>
                <div class={["tile", Enum.at(tiles, 1), "bottom"]}></div>
              <% end %>
            </div>
          <% end %>
      <% end %>
    </div>
    """
  end

end
