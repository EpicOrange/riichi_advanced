defmodule RiichiAdvancedWeb.CornerInfoComponent do
  alias RiichiAdvanced.GameState.Saki, as: Saki
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :display_round_marker, false)
    socket = assign(socket, :ai_thinking, false)
    socket = assign(socket, :chips, %{})
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <%= @player.nickname %>
      <div class="round-marker" :if={@display_round_marker and @seat == :east}>
        <%= Utils.get_wind_name(Riichi.get_round_wind(@kyoku, @num_players)) %>
      </div>
      <%= if @saki != nil and @all_drafted do %>
        <div class="saki-cards">
          <div class={["saki-card", @saki.version, to_card_class(card), Saki.is_disabled_saki_card?(card) && "disabled"]} :for={card <- Saki.filter_cards(@player.status)}></div>
        </div>
      <% end %>
      <div class="shuugi-display" :if={@player.counters["shuugi"] > 0}>
        <%= for {name, amt} <- @chips do %>
          <div class={["chips", name]}>
            <div class="chip" :for={_ <- List.duplicate(nil, max(0, amt))}>
            </div>
          </div>
        <% end %>
        <span><%= @player.counters["shuugi"] %></span>
      </div>
      <div class="ai-thinking" :if={@ai_thinking}></div>
    </div>
    """
  end

  def to_card_class(card) do
    if Saki.is_disabled_saki_card?(card) do
      String.slice(card, 0..-10//1)
    else card end
  end

  def calculate_chips(amt) do
    {chip1, amt} = if amt >= 100 do {Integer.floor_div(amt-100, 100), 100+rem(amt, 100)} else {0, amt} end
    {chip2, amt} = if amt >= 25 do {Integer.floor_div(amt-25, 25), 25+rem(amt, 25)} else {0, amt} end
    {chip3, amt} = if amt >= 5 do {Integer.floor_div(amt-5, 5), 5+rem(amt, 5)} else {0, amt} end
    chip4 = amt
    %{
      chip1: chip1,
      chip2: chip2,
      chip3: chip3,
      chip4: chip4,
    }
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    shuugi = socket.assigns.player.counters["shuugi"]
    socket = if is_number(shuugi) do
      assign(socket, :chips, calculate_chips(shuugi))
    else socket end
    {:ok, socket}
  end

end
