defmodule RiichiAdvancedWeb.WinWindowComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="win-window">
      <div class="hand winning-hand">
        <div class={["tile", tile]} :for={tile <- [:"2m", :"2m", :"2m", :"0m", :"5m", :"5m", :"7m", :"7m", :"8m", :"8m"]}></div>
        <%= for {_name, call} <- [{"pon", [{:"7z", false}, {:"7z", true}, {:"7z", false}]}] do %>
          <div class="call">
            <div class={["tile", tile, sideways && "sideways"]} :for={{tile, sideways} <- call}></div>
          </div>
        <% end %>
        <div class={["tile", "winning-tile", "8m"]}></div>
      </div>
      <div class="yakus">
        <%= for {name, han} <- [{"Riichi", 1}, {"Ippatsu", 1}, {"Tsumo", 1}, {"Chun", 2}, {"Toitoi", 2}, {"Honitsu", 3}, {"Dora", 3}, {"Aka", 1}] do %>
          <div class="yaku">
            <div class="yaku-text"><%= name %></div>
            <div class="han-counter"><%= han %> Han</div>
          </div>
        <% end %>
      </div>
      <div class="score-display">
        <div class="total-han-display">14 Han</div>
        <div class="total-fu-display">50 Fu</div>
        <div class="total-score-display">48000</div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    {:ok, socket}
  end
end
