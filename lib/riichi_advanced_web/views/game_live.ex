defmodule RiichiAdvancedWeb.GameLive do
  use RiichiAdvancedWeb, :live_view

  defp to_revealed_tiles(state) do
    revealed_tiles = Enum.map(state.revealed_tiles, fn tile_spec ->
      if Map.has_key?(state.reserved_tiles, tile_spec) do state.reserved_tiles[tile_spec] else Riichi.to_tile(tile_spec) end
    end)
    revealed_tiles = revealed_tiles ++ Enum.map(length(revealed_tiles)+1..state.max_revealed_tiles//1, fn _ -> :"1x" end)
    revealed_tiles
  end

  def mount(params, _session, socket) do
    socket = assign(socket, :session_id, params["id"])
    socket = assign(socket, :ruleset_json, File.read!(Application.app_dir(:riichi_advanced, "/priv/static/rulesets/#{params["ruleset"] <> ".json"}")))

    # start a new game process, if it doesn't exist already
    game_spec = {RiichiAdvanced.GameSupervisor, session_id: socket.assigns.session_id, ruleset_json: socket.assigns.ruleset_json, name: {:via, Registry, {:game_registry, "game-" <> socket.assigns.session_id}}}
    case DynamicSupervisor.start_child(RiichiAdvanced.GameSessionSupervisor, game_spec) do
      {:ok, _pid} -> IO.puts("Starting game session #{socket.assigns.session_id}")
      {:error, {:shutdown, error}} ->
        IO.puts("Error when starting game session #{socket.assigns.session_id}")
        IO.inspect(error)
      {:error, {:already_started, _pid}} -> nil
    end

    [{game_state, _}] = Registry.lookup(:game_registry, "game_state-" <> socket.assigns.session_id)
    socket = assign(socket, :game_state, game_state)
    socket = assign(socket, :winner, nil)
    socket = assign(socket, :draw, nil)
    socket = assign(socket, :timer, 0)
    # liveviews mount twice
    if socket.root_pid != nil do
      # TODO use id in pubsub
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "game:" <> socket.assigns.session_id)
      [state, seat, shimocha, toimen, kamicha, spectator] = GenServer.call(socket.assigns.game_state, {:new_player, socket})
      socket = assign(socket, :loading, false)
      socket = assign(socket, :players, state.players)
      socket = assign(socket, :player_id, socket.id)
      socket = assign(socket, :turn, state.turn)
      socket = assign(socket, :seat, seat)
      socket = assign(socket, :shimocha, shimocha)
      socket = assign(socket, :toimen, toimen)
      socket = assign(socket, :kamicha, kamicha)
      socket = assign(socket, :spectator, spectator)
      socket = assign(socket, :revealed_tiles, to_revealed_tiles(state))
      socket = assign(socket, :tiles_left, length(state.wall) - state.wall_index - length(state.drawn_reserved_tiles))
      socket = assign(socket, :kyoku, state.kyoku)
      socket = assign(socket, :honba, state.honba)
      socket = assign(socket, :riichi_sticks, state.riichi_sticks)
      {:ok, socket}
    else
      socket = assign(socket, :loading, true)
      socket = assign(socket, :players, %{:east => %Player{}, :south => %Player{}, :west => %Player{}, :north => %Player{}})
      socket = assign(socket, :seat, :east)
      socket = assign(socket, :turn, :east)
      socket = assign(socket, :shimocha, nil)
      socket = assign(socket, :toimen, nil)
      socket = assign(socket, :kamicha, nil)
      socket = assign(socket, :spectator, false)
      socket = assign(socket, :revealed_tiles, [])
      socket = assign(socket, :tiles_left, 0)
      socket = assign(socket, :kyoku, 0)
      socket = assign(socket, :honba, 0)
      socket = assign(socket, :riichi_sticks, 0)
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <%= if not @spectator do %>
      <.live_component module={RiichiAdvancedWeb.HandComponent}
        id="hand self"
        game_state={@game_state}
        your_hand?={true}
        your_turn?={@seat == @turn}
        seat={@seat}
        hand={@players[@seat].hand}
        draw={@players[@seat].draw}
        calls={@players[@seat].calls}
        play_tile={&send(self(), {:play_tile, &1, &2})}
        reindex_hand={&send(self(), {:reindex_hand, &1, &2})}
        />
    <% else %>
      <.live_component module={RiichiAdvancedWeb.HandComponent}
        id="hand self"
        game_state={@game_state}
        your_hand?={false}
        seat={@seat}
        hand={@players[@seat].hand}
        draw={@players[@seat].draw}
        calls={@players[@seat].calls}
        :if={@seat != nil}
        />
    <% end %>
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond self" game_state={@game_state} pond={@players[@seat].pond} riichi={"riichi" in @players[@seat].status} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand shimocha"
      game_state={@game_state}
      your_hand?={false}
      seat={@shimocha}
      hand={@players[@shimocha].hand}
      draw={@players[@shimocha].draw}
      calls={@players[@shimocha].calls}
      :if={@shimocha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond shimocha" game_state={@game_state} pond={@players[@shimocha].pond} riichi={"riichi" in @players[@shimocha].status} :if={@shimocha != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand toimen"
      game_state={@game_state}
      your_hand?={false}
      seat={@toimen}
      hand={@players[@toimen].hand}
      draw={@players[@toimen].draw}
      calls={@players[@toimen].calls}
      :if={@toimen != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond toimen" game_state={@game_state} pond={@players[@toimen].pond} riichi={"riichi" in @players[@toimen].status} :if={@toimen != nil} />
    <.live_component module={RiichiAdvancedWeb.HandComponent}
      id="hand kamicha"
      game_state={@game_state}
      your_hand?={false}
      seat={@kamicha}
      hand={@players[@kamicha].hand}
      draw={@players[@kamicha].draw}
      calls={@players[@kamicha].calls}
      :if={@kamicha != nil}
      />
    <.live_component module={RiichiAdvancedWeb.PondComponent} id="pond kamicha" game_state={@game_state} pond={@players[@kamicha].pond} riichi={"riichi" in @players[@kamicha].status} :if={@kamicha != nil} />
    <.live_component module={RiichiAdvancedWeb.CompassComponent}
      id="compass"
      game_state={@game_state}
      seat={@seat}
      turn={@turn}
      tiles_left={@tiles_left}
      kyoku={@kyoku}
      honba={@honba}
      riichi_sticks={@riichi_sticks}
      riichi={Map.new(@players, fn {seat, player} -> {seat, "riichi" in player.status} end)}
      score={Map.new(@players, fn {seat, player} -> {seat, player.score} end)}
      />
    <.live_component module={RiichiAdvancedWeb.WinWindowComponent} id="win-window" game_state={@game_state} seat={@seat} winner={@winner} timer={@timer}/>
    <.live_component module={RiichiAdvancedWeb.DrawWindowComponent} id="draw-window" game_state={@game_state} seat={@seat} draw={@draw} timer={@timer}/>
    <%= if not @spectator do %>
      <div class="buttons">
        <button class="button" phx-click="button_clicked" phx-value-name={name} :for={name <- @players[@seat].buttons}><%= GenServer.call(@game_state, {:get_button_display_name, name}) %></button>
      </div>
      <div class="auto-buttons">
        <%= for {name, checked} <- @players[@seat].auto_buttons do %>
          <input id={"auto-button-" <> name} type="checkbox" class="auto-button" phx-click="auto_button_toggled" phx-value-name={name} phx-value-enabled={if checked do "true" else "false" end} checked={checked}>
          <label for={"auto-button-" <> name}><%= GenServer.call(@game_state, {:get_auto_button_display_name, name}) %></label>
        <% end %>
      </div>
      <div class="call-buttons-container">
        <%= for {called_tile, choices} <- @players[@seat].call_buttons do %>
          <%= if not Enum.empty?(choices) do %>
            <div class="call-buttons">
              <div class={["tile", called_tile]}></div>
              <div class="call-button-separator"></div>
              <%= for choice <- choices do %>
                <button class="call-button" phx-click="call_button_clicked" phx-value-name={@players[@seat].call_name} phx-value-tile={called_tile} phx-value-choice={Enum.join(choice, ",")}>
                <%= for tile <- choice do %>
                  <div class={["tile", tile]}></div>
                <% end %>
                </button>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
    <% end %>
    <div class="revealed-tiles">
      <div class={["tile", tile]} :for={tile <- @revealed_tiles}></div>
    </div>
    <div class={["big-text", Utils.get_relative_seat(@seat, seat)]} :for={{seat, player} <- @players} :if={player.big_text != ""}><%= player.big_text %></div>
    <div class={["big-text"]} :if={@loading}>Loading...</div>
    <div class="ruleset">
      <textarea><%= @ruleset_json %></textarea>
    </div>
    """
  end

  def handle_event("button_clicked", %{"name" => name}, socket) do
    GenServer.cast(socket.assigns.game_state, {:press_button, socket.assigns.seat, name})
    {:noreply, socket}
  end

  def handle_event("auto_button_toggled", %{"name" => name, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    GenServer.cast(socket.assigns.game_state, {:toggle_auto_button, socket.assigns.seat, name, not enabled})
    {:noreply, socket}
  end

  def handle_event("call_button_clicked", %{"tile" => called_tile, "name" => call_name, "choice" => choice}, socket) do
    call_choice = Enum.map(String.split(choice, ","), &Riichi.to_tile/1)
    GenServer.cast(socket.assigns.game_state, {:run_deferred_actions, %{seat: socket.assigns.seat, call_name: call_name, call_choice: call_choice, called_tile: Riichi.to_tile(called_tile)}})
    {:noreply, socket}
  end

  def handle_info({:play_tile, _tile, index}, socket) do
    if socket.assigns.seat == socket.assigns.turn do
      GenServer.cast(socket.assigns.game_state, {:play_tile, socket.assigns.seat, index})
    end
    {:noreply, socket}
  end
  def handle_info({:reindex_hand, from, to}, socket) do
    GenServer.cast(socket.assigns.game_state, {:reindex_hand, socket.assigns.seat, from, to})
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "state_updated", payload: %{"state" => state}}, socket) do
    if topic == ("game:" <> socket.assigns.session_id) do
      # animate new calls
      num_calls_before = Map.new(socket.assigns.players, fn {seat, player} -> {seat, length(player.calls)} end)
      num_calls_after = Map.new(state.players, fn {seat, player} -> {seat, length(player.calls)} end)
      Enum.each(Map.keys(num_calls_before), fn seat ->
        if num_calls_after[seat] > num_calls_before[seat] do
          relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
          send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", num_new_calls: num_calls_after[seat] - num_calls_before[seat])
        end
      end)

      # animate played tiles
      Enum.each(state.players, fn {seat, player} ->
        if player.last_discard != nil do
          {tile, index} = player.last_discard
          relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
          send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", hand: player.hand ++ player.draw, played_tile: tile, played_tile_index: index)
          send_update(RiichiAdvancedWeb.PondComponent, id: "pond #{relative_seat}", played_tile: tile)
        end
      end)

      socket = assign(socket, :players, state.players)
      socket = assign(socket, :turn, state.turn)
      socket = assign(socket, :winner, state.winner)
      socket = assign(socket, :draw, state.draw)
      socket = assign(socket, :kyoku, state.kyoku)
      socket = assign(socket, :honba, state.honba)
      socket = assign(socket, :riichi_sticks, state.riichi_sticks)
      socket = assign(socket, :timer, state.timer)
      socket = assign(socket, :revealed_tiles, to_revealed_tiles(state))
      socket = assign(socket, :tiles_left, length(state.wall) - state.wall_index - length(state.drawn_reserved_tiles))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:reset_anim, seat}, socket) do
    relative_seat = Utils.get_relative_seat(socket.assigns.seat, seat)
    send_update(RiichiAdvancedWeb.HandComponent, id: "hand #{relative_seat}", hand: socket.assigns.players[seat].hand, played_tile: nil, played_tile_index: nil)
    {:noreply, socket}
  end

  def handle_info(data, socket) do
    IO.puts("unhandled handle_info data:")
    IO.inspect(data)
    {:noreply, socket}
  end

end
