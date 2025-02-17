defmodule RiichiAdvancedWeb.IndexLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.LobbyState, as: LobbyState
  alias RiichiAdvanced.LobbyState.Lobby, as: Lobby
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:messages, [])
    |> assign(:show_room_code_buttons, false)
    |> assign(:room_code, [])
    |> assign(:version, Constants.version())
    messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
      GenServer.cast(messages_init.messages_state, {:add_message, %{text: "Welcome to Riichi Advanced!"}})
      socket
    else socket end
    socket = assign(socket, :rulesets, Constants.available_rulesets())
    socket = assign(socket, :unimplemented_rulesets, Constants.unimplemented_rulesets())
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container" phx-hook="ClickListener">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <input type="checkbox" id="expand-checkbox" class="expand-checkbox for-rulesets" phx-update="ignore"/>
      <label for="expand-checkbox"/>
      <form phx-submit="redirect">
        <div class="ruleset-selection">
          <%= for {{ruleset, name, desc}, i} <- Enum.with_index(@rulesets) do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} checked={i==0} phx-update="ignore">
            <label for={ruleset} title={desc}><%= name %></label>
          <% end %>
          <br/>
          To be implemented:
          <%= for {ruleset, name, desc, link} <- @unimplemented_rulesets do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} disabled>
            <label for={ruleset} title={desc}><a href={link} target="_blank"><%= name %></a></label>
          <% end %>
        </div>
        <input class="nickname-input" type="text" name="nickname" placeholder="Nickname (optional)" value={@nickname || ""} />
        <div class="enter-buttons">
          <button name="play" type="submit">Play</button>
          <button name="learn" type="submit" :if={not @show_room_code_buttons}>Learn</button>
          <button type="button" phx-cancellable-click="toggle_show_room_code">
            <%= if @show_room_code_buttons do %>
              Close
            <% else %>
              Join private room
            <% end %>
          </button>
        </div>
      </form>
      <%= if @show_room_code_buttons do %>
        <.live_component module={RiichiAdvancedWeb.RoomCodeComponent} id="room-code" set_room_code={&send(self(), {:set_room_code, &1})} />
      <% end %>
      <div class="index-version"><%= @version %></div>
      <div class="index-bottom-buttons">
        <button phx-click="goto_about">About</button>
        <button><a href="https://github.com/EpicOrange/riichi_advanced" target="_blank">Source</a></button>
        <button><a href="https://discord.gg/5QQHmZQavP" target="_blank">Discord</a></button>
        <button phx-click="goto_logs">Logs</button>
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_show_room_code", _assigns, socket) do
    socket = assign(socket, :show_room_code_buttons, not socket.assigns.show_room_code_buttons)
    {:noreply, socket}
  end

  def handle_event("redirect", params, socket) do
    %{"ruleset" => ruleset, "nickname" => nickname} = params
    if Map.has_key?(params, "play") do
      if socket.assigns.show_room_code_buttons do
        socket = if length(socket.assigns.room_code) == 3 do
          # enter private room, or create a new room
          room_code = Enum.join(socket.assigns.room_code, ",")
          push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{nickname}&from=home")
        else socket end
        {:noreply, socket}
      else
        # get all running session ids for this ruleset
        room_codes = DynamicSupervisor.which_children(RiichiAdvanced.RoomSessionSupervisor)
        |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
        |> Enum.filter(fn name -> String.starts_with?(name, "room-#{ruleset}-") end)
        |> Enum.map(fn name -> String.replace_prefix(name, "room-#{ruleset}-", "") end)
        # check if there are any public rooms of this ruleset
        # if not, skip the lobby and go directly to making a new table
        has_public_room = Enum.any?(room_codes, fn room_code -> 
          [{room_state_pid, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room_state", ruleset, room_code))
          room_state = GenServer.call(room_state_pid, :get_state)
          not room_state.private
        end)
        socket = if has_public_room do
          push_navigate(socket, to: ~p"/lobby/#{ruleset}?nickname=#{nickname}")
        else
          {:ok, _, room_code} = LobbyState.create_room(%Lobby{ruleset: ruleset})
          push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{nickname}&from=home")
        end
        {:noreply, socket}
      end
    else
      # tutorial
      socket = if ruleset != "custom" do
        push_navigate(socket, to: ~p"/tutorial/#{ruleset}?nickname=#{nickname}")
      else socket end
      {:noreply, socket}
    end
  end
  
  def handle_event("goto_about", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/about")
    {:noreply, socket}
  end
  
  def handle_event("goto_logs", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/log")
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:set_room_code, room_code}, socket) do
    socket = assign(socket, :room_code, room_code)
    {:noreply, socket}
  end

end
