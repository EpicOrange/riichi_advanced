defmodule RiichiAdvancedWeb.CustomStyleComponent do
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = assign(socket, :style, %{})
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
    <style><%= raw @css %></style>
    """
  end

  # can't accept arbitrary urls, since it can be to a SVG that includes JS

  # def tile_to_css(tile_name, url) do
  #   # sanitize
  #   tile_name = String.replace(tile_name, ~r/[^a-zA-Z0-9]/, "")
  #   url = case URI.parse(url) do
  #     %URI{scheme: scheme} when scheme in ["http", "https"] -> url
  #     _ -> nil
  #   end
  #   # escape digits in css
  #   escaped_name = Regex.replace(~r/(\d)/, tile_name, "\\\\3\\1 ")
  #   if tile_name != "" and url != nil do
  #     """
  #     div.tile.#{escaped_name} {
  #       background: url('#{url}');
  #       background-size: 100% 100%;
  #     }
  #     """
  #   else "" end
  # end

  def tile_index_to_css(tile_name, index) do
    # sanitize
    tile_name = String.replace(tile_name, ~r/[^a-zA-Z0-9]/, "")
    # escape digits in css
    escaped_name = Regex.replace(~r/(\d)/, tile_name, "\\\\3\\1 ")
    if tile_name != "" do
      """
      div.tile.#{escaped_name}::after {
        content: "#{index}";
      }
      """
    else "" end
  end

  def sanitize_color(color) do
    if color =~ Utils.css_color_regex() do color else "transparent" end
  end
  def sanitize_index(index) do
    if index =~ ~r/^[a-zA-Z0-9]*$/ do index else "transparent" end
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    tile_index_css = if Map.has_key?(socket.assigns.style, "tile_indices") do
      socket.assigns.style
      |> Map.get("tile_indices", [])
      |> Enum.map_join("\n", fn {tile, index} -> tile_index_to_css(tile, sanitize_index(index)) end)
    else "" end
    
    tile_back_css = if Map.has_key?(socket.assigns.style, "tile_back_color") do
      color = sanitize_color(socket.assigns.style["tile_back_color"])
      """
      main {
        --tile-back: #{color};
        --tile-back-side: #{color};
      }
      div.tile.\\31 x {
        background-image: none;
        background-color: #{color};
      }
      """
    else "" end
    tile_back_side_css = if Map.has_key?(socket.assigns.style, "tile_back_side_color") do
      color = sanitize_color(socket.assigns.style["tile_back_side_color"])
      """
      main {
        --tile-back-side: #{color};
      }
      """
    else "" end
    tablecloth_css = if Map.has_key?(socket.assigns.style, "tablecloth_color") do
      color = sanitize_color(socket.assigns.style["tablecloth_color"])
      """
      main {
        --bg-color: #{color};
      }
      """
    else "" end
    css = Enum.join([tile_index_css, tile_index_css, tile_back_css, tile_back_side_css, tablecloth_css], "\n")
    socket = assign(socket, :css, css)

    {:ok, socket}
  end
end
