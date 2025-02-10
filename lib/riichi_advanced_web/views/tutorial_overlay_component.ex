defmodule RiichiAdvancedWeb.TutorialOverlayComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:objects, [])
    |> assign(:initialized, false)
    {:ok, socket}
  end

  defp run_actions(socket, []), do: socket
  defp run_actions(socket, [[action | opts] | actions]) do
    case action do
      "add_object" ->
        obj = Enum.at(opts, 0, "text")
        params = Enum.at(opts, 1, %{})
        assign(socket, :objects, socket.assigns.objects ++ [{obj, params}])
      "clear_objects" -> assign(socket, :objects, [])
      "force_event" ->
        scene = Enum.at(opts, 0, "")
        event = Enum.at(opts, 1, %{})
        socket.assigns.force_event.(scene, event)
        socket
        |> assign(:next_scene, scene)
    end
    |> run_actions(actions)
  end

  def render(assigns) do
    ~H"""
    <div class="tutorial-overlay-objects">
      <%= for {obj, params} <- @objects do %>
        <%= case obj do %>
          <% "text" -> %>
            <div class="tutorial-text" style={"--width: #{Map.get(params, "width", 0)}; --size: #{Map.get(params, "size", 0.5)}; --x: #{Map.get(params, "x", 0)}; --y: #{Map.get(params, "y", 0)}"}>
              <p :for={p <- String.split(params["text"], "\n")}><%= p %></p>
            </div>
          <% "focus" -> %>
            <div class="tutorial-focus" style={"--width: #{Map.get(params, "width", 0)}; --x: #{Map.get(params, "x", 0)}; --y: #{Map.get(params, "y", 0)}"}>
            </div>
          <% _ -> %>
            <div>
              <%= inspect({obj, params}) %>
            </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash, :actions])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    actions = Map.get(assigns, :actions, [])
    IO.inspect({:updating, actions})
    socket = run_actions(socket, actions)

    {:ok, socket}
  end

end
