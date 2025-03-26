defmodule RiichiAdvancedWeb.BigTextComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :length, 2)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["big-text", @relative_seat]} style={"--big-text-length: #{@length}"}><%= dt(@lang, @big_text) %></div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
             |> Map.drop([:flash])
             |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    socket = assign(socket, :length, String.length(socket.assigns.big_text))

    {:ok, socket}
  end
end
