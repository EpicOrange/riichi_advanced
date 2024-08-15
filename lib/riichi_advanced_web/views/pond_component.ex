defmodule RiichiAdvancedWeb.PondComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :last_tile, nil)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={@id}>
      <div :for={tile <- @pond} class={["tile", tile, tile == @last_tile && "just-played"]}></div>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)
    if Map.has_key?(assigns, :played_tile) do
      socket = assign(socket, :last_tile, assigns.played_tile)
      {:ok, socket}
    else
      socket = assign(socket, :last_tile, nil)
      {:ok, socket}
    end
  end
end
