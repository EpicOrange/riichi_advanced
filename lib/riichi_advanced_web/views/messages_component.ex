defmodule RiichiAdvancedWeb.MessagesComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="messages-container">
      <div class="messages">
        <%= for msg <- @messages do %>
          <%= if is_list(msg) do %>
            <span>
              <%= for m <- msg do %>
                <span style={"color: #{Map.get(m, :color, "white")};"} class={[Map.get(m, :bold, false) && "bold"]}><%= m.text %></span>
              <% end %>
            </span>
          <% else %>
            <span style={"color: #{Map.get(msg, :color, "white")};"} class={[Map.get(msg, :bold, false) && "bold"]}><%= msg.text %></span>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

end
