defmodule RiichiAdvancedWeb.CornerInfoComponent do
  alias RiichiAdvanced.GameState.Saki, as: Saki
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
      <%= if @saki != nil && Map.has_key?(@saki, :all_drafted) && @saki.all_drafted do %>
        <div class="saki-cards">
          <div class={["saki-card", @saki.version, card]} :for={card <- Saki.filter_cards(@player.status)}></div>
        </div>
      <% end %>
    </div>
    """
  end

end
