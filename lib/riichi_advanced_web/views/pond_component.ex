defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :pond, [])
    socket = assign(socket, :riichi_index, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[@id, @seat == @last_turn && "just-played"]}>
      <div :for={{tile, i} <- Enum.with_index(@pond)} class={["tile", tile, i == @riichi_index && "sideways"]}></div>
    </div>
    """
  end

  def update(assigns, socket) do
    # check if we just declared riichi
    socket = if socket.assigns.riichi_index == nil && Map.has_key?(assigns, :riichi) && assigns.riichi do
      assign(socket, :riichi_index, length(socket.assigns.pond))
    else socket end

    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    {:ok, socket}
  end
end
