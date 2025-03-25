defmodule RiichiAdvancedWeb.MenuButtonsComponent do
  alias RiichiAdvanced.Constants
  use RiichiAdvancedWeb, :live_component
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :back_button, true)
    socket = assign(socket, :log_button, false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id]}>
      <button class="language-dropdown-container">
        <form class="language-dropdown" phx-change="change_language">
          <select id="language-dropdown" name="lang">
            <%= for {name, code} <- Constants.langs() do %>
              <%= if code == @lang do %>
                <option value={code} selected><%= name %></option>
              <% else %>
                <option value={code}><%= name %></option>
              <% end %>
            <% end %>
          </select>
        </form>
        <div>
          <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" stroke="#000000" fill="#f4f0eb" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m13 19 3.5-9 3.5 9m-6.125-2h5.25M3 7h7m0 0h2m-2 0c0 1.63-.793 3.926-2.239 5.655M7.5 6.818V5m.261 7.655C6.79 13.82 5.521 14.725 4 15m3.761-2.345L5 10m2.761 2.655L10.2 15"/>
          </svg>
        </div>
      </button>
      <%= if @back_button do %>
        <button class="back" phx-cancellable-click="back"><%= t(@lang, "Back") %></button>
      <% end %>
      <%= if @log_button do %>
        <button class="log" phx-cancellable-click="log"><%= t(@lang, "Copy log") %></button>
      <% end %>
    </div>
    """
  end

end
