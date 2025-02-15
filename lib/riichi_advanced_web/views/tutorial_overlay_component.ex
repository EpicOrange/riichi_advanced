defmodule RiichiAdvancedWeb.TutorialOverlayComponent do
  use RiichiAdvancedWeb, :live_component

  def mount(socket) do
    socket = socket
    |> assign(:objects, [])
    |> assign(:focuses, [])
    |> assign(:deferred_actions, [])
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
        events = Enum.at(opts, 0, %{})
        events = if not is_list(Enum.at(events, 0)) do [events] else events end
        next_scenes = List.wrap(Enum.at(opts, 1, List.duplicate(:resume, length(events))))
        socket.assigns.force_event.(next_scenes, events, true)
        socket
        |> assign(:deferred_actions, actions)
      "await_event" ->
        events = Enum.at(opts, 0, %{})
        events = if not is_list(Enum.at(events, 0)) do [events] else events end
        next_scenes = List.wrap(Enum.at(opts, 1, List.duplicate(:resume, length(events))))
        socket.assigns.force_event.(next_scenes, events, false)
        socket
        |> assign(:deferred_actions, actions)
      "await_click" ->
        next_scene = Enum.at(opts, 0, :resume)
        socket.assigns.await_click.(next_scene)
        socket
        |> assign(:deferred_actions, actions)
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
      "play_scene" ->
        next_scene = Enum.at(opts, 0)
        socket.assigns.play_scene.(next_scene)
        socket
      "exit" ->
        send(self(), :back)
        socket
    end
    if action in ["sleep", "await_click", "await_event", "force_event"] do
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
      <div class="tutorial-focus mobile" style={get_focus_mask(@focuses, true)} :if={not Enum.empty?(@focuses)}></div>
      <div class="tutorial-focus desktop" style={get_focus_mask(@focuses, false)} :if={not Enum.empty?(@focuses)}></div>
    </div>
    """
  end

  def get_focus_mask(focuses, mobile?) do
    mask = for params <- focuses do
      {width, x, y} = case params do
        %{"width" => width, "x" => x, "y" => "buttons"} when mobile? -> {width, x, 14}
        %{"width" => width, "x" => x, "y" => "buttons"}              -> {width, x, 14.5}
        %{"width" => width, "x" => x, "y" => y}                      -> {width, x, y}
        %{"width" => width, "hand_index" => i} when mobile?          -> {1.5 * width, 0.9375 + 1.5 * 0.75 * i, 15.625}
        %{"width" => width, "hand_index" => i}                       -> {width, 2.875 + 0.75 * i, 15.875}
        %{"width" => width, "draw_index" => i} when mobile?          -> {1.5 * width, 1.5 + 1.5 * 0.75 * i, 15.625}
        %{"width" => width, "draw_index" => i}                       -> {width, 3.25 + 0.75 * i, 15.875}
        # %{"width" => width, "winning_hand_index" => i}               -> {width, 3.375 + 0.75 * i, 2.75}
        _                                                            -> {0, 0, 0}
      end
      "radial-gradient(circle at calc(#{x} * var(--tile-size)) calc(#{y} * var(--tile-size)), transparent calc(#{width} * var(--tile-size)), black calc(#{width} * var(--tile-size)))"
    end |> Enum.join(",")
    "mask-image: #{mask};"
  end

  def update(assigns, socket) do
    socket = assigns
    |> Map.drop([:flash, :actions])
    |> Enum.reduce(socket, fn {key, value}, acc_socket -> assign(acc_socket, key, value) end)

    actions = Map.get(assigns, :actions, [])
    actions = if actions == :resume do socket.assigns.deferred_actions else actions end
    socket = run_actions(socket, actions)

    {:ok, socket}
  end

end
