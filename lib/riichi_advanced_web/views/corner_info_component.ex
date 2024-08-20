defmodule RiichiAdvancedWeb.CornerInfoComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
    <%= @player.nickname %>
      <div class="round-marker" :if={@seat == :east}>
        <%= Utils.get_wind_name(Riichi.get_round_wind(@kyoku)) %>
      </div>
    </div>
    """
  end

end
