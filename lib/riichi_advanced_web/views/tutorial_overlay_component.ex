defmodule RiichiAdvancedWeb.TutorialOverlayComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:objects, [])
    |> assign(:focuses, [])
    |> assign(:waiting_for_click, false)
    |> assign(:initialized, false)
    {:ok, socket}
  end

  defp run_actions(socket, []), do: socket
  defp run_actions(socket, [[action | opts] | actions]) do
    socket = case action do
      "add_object" ->
        obj = Enum.at(opts, 0, "text")
        params = Enum.at(opts, 1, %{})
        if obj == "focus" do
          assign(socket, :focuses, socket.assigns.focuses ++ [params])
        else
          assign(socket, :objects, socket.assigns.objects ++ [{obj, params}])
        end
      "clear_objects" ->
        socket
        |> assign(:objects, [])
        |> assign(:focuses, [])
      "force_event" ->
        next_scene = Enum.at(opts, 0, "")
        event = Enum.at(opts, 1, %{})
        socket.assigns.force_event.(next_scene, event)
        socket
      "await_click" ->
        next_scene = Enum.at(opts, 0, "")
        socket.assigns.await_click.(next_scene)
        socket
      "pause" ->
        GenServer.cast(socket.assigns.game_state, :pause)
        socket
      "unpause" ->
        GenServer.cast(socket.assigns.game_state, :unpause)
        socket
      "sleep" ->
        duration = Enum.at(opts, 0, 0)
        send_update_after(self(), __MODULE__, [id: "tutorial-overlay", actions: actions], duration)
        socket
      "exit" ->
        send(self(), :back)
        socket
    end
    if action == "sleep" do
      socket
    else 
      run_actions(socket, actions)
    end
  end

  def render(assigns) do
    ~H"""
    <div class={["tutorial-overlay-objects", @waiting_for_click && "awaiting-click"]} phx-click="tutorial_overlay_clicked">
      <%= for {obj, params} <- @objects do %>
        <%= case obj do %>
          <% "text" -> %>
            <div class="tutorial-text" style={"--width: #{Map.get(params, "width", 0)}; --size: #{Map.get(params, "size", 0.5)}; --x: #{Map.get(params, "x", 0)}; --y: #{Map.get(params, "y", 0)}"}>
              <p :for={p <- String.split(params["text"], "\n")}><%= p %></p>
            </div>
          <% _ -> %>
            <div>
              <%= inspect({obj, params}) %>
            </div>
        <% end %>
      <% end %>
      <div class="tutorial-focus" style={get_focus_mask(@focuses)} :if={not Enum.empty?(@focuses)}></div>
    </div>
    """
  end

  def get_focus_mask(focuses) do
    mask = for %{"width" => width, "x" => x, "y" => y} <- focuses do
      "radial-gradient(circle at calc(#{x} * var(--tile-size)) calc(#{y} * var(--tile-size)), transparent calc(#{width} * var(--tile-size)), black calc(#{width} * var(--tile-size)))"
    end |> Enum.join(",")
    "mask-image: #{mask};"
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash, :actions])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    actions = Map.get(assigns, :actions, [])

    socket = run_actions(socket, actions)

    {:ok, socket}
  end

end
