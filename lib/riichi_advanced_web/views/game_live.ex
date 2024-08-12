defmodule RiichiAdvancedWeb.GameLive do
  use RiichiAdvancedWeb, :live_view

  # This function initializes the state
  def mount(_params, _session, socket) do
    # liveviews mount twice
    if socket.root_pid != nil do
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "game:main")

      # TODO notify all other players that we have joined the game
      IO.inspect(socket)
      [turn, hands, ponds, draws, seat, shimocha, toimen, kamicha] = RiichiAdvanced.GlobalState.new_player(socket)

      socket = assign(socket, :player_id, socket.id)
      socket = assign(socket, :turn, turn)
      socket = assign(socket, :seat, seat)
      socket = assign(socket, :shimocha, shimocha)
      socket = assign(socket, :toimen, toimen)
      socket = assign(socket, :kamicha, kamicha)
      socket = assign(socket, :hands, hands)
      socket = assign(socket, :ponds, ponds)
      socket = assign(socket, :draws, draws)
      socket = assign(socket, :buttons, Map.keys(RiichiAdvanced.GlobalState.get_buttons(seat)))
      {:ok, socket}
    else
      socket = assign(socket, :seat, :east)
      socket = assign(socket, :turn, :east)
      socket = assign(socket, :shimocha, nil)
      socket = assign(socket, :toimen, nil)
      socket = assign(socket, :kamicha, nil)
      socket = assign(socket, :hands, %{:east => [], :south => [], :west => [], :north => []})
      socket = assign(socket, :ponds, %{:east => [], :south => [], :west => [], :north => []})
      socket = assign(socket, :draws, %{:east => [], :south => [], :west => [], :north => []})
      socket = assign(socket, :buttons, [])
      {:ok, socket}
    end
  end

  # Render the template using the assigned state
  def render(assigns) do
    ~H"""
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand self"
      your_hand?={true}
      your_turn?={@seat == @turn}
      seat={@seat}
      hand={@hands[@seat]}
      draw={@draws[@seat]}
      play_tile={&send(self(), {:play_tile, &1, &2})}
      reindex_hand={&send(self(), {:reindex_hand, &1, &2})}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond self" pond={@ponds[@seat]} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand shimocha"
      your_hand?={false}
      seat={@shimocha}
      hand={@hands[@shimocha]}
      draw={@draws[@shimocha]}
      :if={@shimocha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond shimocha" pond={@ponds[@shimocha]} :if={@shimocha != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand toimen"
      your_hand?={false}
      seat={@toimen}
      hand={@hands[@toimen]}
      draw={@draws[@toimen]}
      :if={@toimen != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond toimen" pond={@ponds[@toimen]} :if={@toimen != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand kamicha"
      your_hand?={false}
      seat={@kamicha}
      hand={@hands[@kamicha]}
      draw={@draws[@kamicha]}
      :if={@kamicha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond kamicha" pond={@ponds[@kamicha]} :if={@kamicha != nil} />
    <div class="seating">You are <%= @seat %><br>It is <%= @turn %>'s turn</div>
    <div class="compass" phx-click="set_turn"></div>
    <div class="buttons">
      <%= for name <- @buttons do %>
        <button class="button" phx-click="button_clicked" phx-value-name={name}><%= name %></button>
      <% end %>
    </div>
    """
  end

  def handle_event("set_turn", _assigns, socket) do
    RiichiAdvanced.GlobalState.change_turn(socket.assigns.seat)
    {:noreply, socket}
  end

  def handle_event("button_clicked", %{"name" => name}, socket) do
    RiichiAdvanced.GlobalState.press_button(socket.assigns.seat, name)
    {:noreply, socket}
  end

  def handle_info({:play_tile, tile, index}, socket) do
    if socket.assigns.seat == socket.assigns.turn do
      RiichiAdvanced.GlobalState.play_tile(socket.assigns.seat, tile, index)
    end
    {:noreply, socket}
  end
  def handle_info({:reindex_hand, from, to}, socket) do
    RiichiAdvanced.GlobalState.reindex_hand(socket.assigns.seat, from, to)
    {:noreply, socket}
  end

  def handle_info(%{topic: "game:main", event: "played_tile", payload: %{"seat" => seat, "tile" => tile, "index" => index}}, socket) do
    relative_seat = RiichiAdvanced.GlobalState.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", played_tile: tile, played_tile_index: index)
    send_update(RiichiAdvancedWeb.PondComponent, id: "pond #{relative_seat}", played_tile: tile)
    {:noreply, socket}
  end

  def handle_info(%{topic: "game:main", event: "state_updated", payload: %{"state" => state}}, socket) do
    # IO.puts("Global state updated event:")
    # IO.inspect(state)
    socket = assign(socket, :turn, state.turn)
    socket = assign(socket, :hands, state.hands)
    socket = assign(socket, :draws, state.draws)
    socket = assign(socket, :buttons, Map.keys(RiichiAdvanced.GlobalState.get_buttons(socket.assigns.seat)))
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

end
