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
        <%= Utils.get_wind_name(Riichi.get_round_wind(@kyoku, @num_players)) %>
      </div>
      <%= if @saki != nil && @all_drafted do %>
        <div class="saki-cards">
          <div class={["saki-card", @saki.version, to_card_class(card), Saki.is_disabled_saki_card?(card) && "disabled"]} :for={card <- Saki.filter_cards(@player.status)}></div>
        </div>
      <% end %>
      <div class="dead-hand-button" phx-cancellable-click="declare_dead_hand" phx-value-seat={@seat} :if={@dead_hand_buttons && @seat != @viewer && @viewer != :spectator}>!</div>
    </div>
    """
  end

  def to_card_class(card) do
    if Saki.is_disabled_saki_card?(card) do
      String.slice(card, 0..-10//1)
    else card end
  end

end
