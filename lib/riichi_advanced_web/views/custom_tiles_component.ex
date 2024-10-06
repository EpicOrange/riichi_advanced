defmodule RiichiAdvancedWeb.CustomTilesComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :tiles, %{})
    socket = assign(socket, :css, "")
    {:ok, socket}
  end

  # something like
  # div.tile.\31 m {
  #   background: url('https://previews.123rf.com/images/nissat/nissat2101/nissat210100023/163374771-spring-mahjong-tile-tile-flower-tile-illustration-icon.jpg');
  #   background-size: 100% 100%;
  # }
  def render(assigns) do
    ~H"""
    <style>
     <%= raw @css %>
    </style>
    """
  end

  def to_css(tile_name, url) do
    # sanitize
    tile_name = tile_name |> String.replace("\"", "") |> String.replace("\'", "") |> String.replace("\\", "") |> String.replace("\n", "")
    url = url |> String.replace("\"", "") |> String.replace("\'", "") |> String.replace("\\", "") |> String.replace("\n", "")

    # escape digits in css
    escaped_name = Regex.replace(~r/(\d)/, tile_name, "\\\\3\\1 ")
    """
    div.tile.#{escaped_name} {
      background: url('#{url}');
      background-size: 100% 100%;
    }
    """
  end

  def update(assigns, socket) do

    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :css, Enum.map(socket.assigns.tiles, fn {name, url} -> to_css(name, url) end) |> Enum.join("\n"))

    {:ok, socket}
  end
end
