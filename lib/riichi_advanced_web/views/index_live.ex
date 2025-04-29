defmodule RiichiAdvancedWeb.IndexLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.LobbyState, as: LobbyState
  alias RiichiAdvanced.LobbyState.Lobby, as: Lobby
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view
  import RiichiAdvancedWeb.Translations

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:messages, [])
    |> assign(:show_room_code_buttons, false)
    |> assign(:room_code, [])
    |> assign(:version, Constants.version())
    messages_init = RiichiAdvanced.MessagesState.link_player_socket(socket.root_pid, socket.assigns.session_id)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.assigns.session_id)
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
      <form class="ruleset-selection-form" phx-submit="redirect">
        <div class="ruleset-selection">
          <%= for {{ruleset, name, desc}, i} <- Enum.with_index(@rulesets) do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} checked={i==0} phx-update="ignore">
            <label for={ruleset} title={dt(@lang, desc)} data-name={dt(@lang, name)} tabindex={i}><%= dt(@lang, name) %></label>
          <% end %>
          <br/>
          <%= t(@lang, "To be implemented:") %>
          <%= for {{ruleset, name, desc, link}, i} <- Enum.with_index(@unimplemented_rulesets) do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} disabled>
            <label for={ruleset} title={dt(@lang, desc)} data-name={dt(@lang, name)} tabindex={i}><a href={link} target="_blank"><%= dt(@lang, name) %></a></label>
          <% end %>
        </div>
        <input class="nickname-input" type="text" name="nickname" placeholder={t(@lang, "Nickname (optional)")} value={@nickname || ""} />
        <div class="enter-buttons">
          <button name="play" type="submit"><%= t(@lang, "Play") %></button>
          <button name="learn" type="submit" :if={not @show_room_code_buttons}><%= t(@lang, "Learn") %></button>
          <button type="button" phx-cancellable-click="toggle_show_room_code">
            <%= if @show_room_code_buttons do %>
              <%= t(@lang, "Close") %>
            <% else %>
              <%= t(@lang, "Join private room") %>
            <% end %>
          </button>
        </div>
      </form>
      <%= if @show_room_code_buttons do %>
        <.live_component module={RiichiAdvancedWeb.RoomCodeComponent} id="room-code" lang={@lang} set_room_code={&send(self(), {:set_room_code, &1})} />
      <% end %>
      <div class="index-version"><%= @version %></div>
      <div class="index-bottom-buttons">
        <button phx-click="goto_about"><%= t(@lang, "About") %></button>
        <button><a href="https://github.com/EpicOrange/riichi_advanced" target="_blank"><%= t(@lang, "Source") %></a></button>
        <button><a href="https://discord.gg/5QQHmZQavP" target="_blank"><%= t(@lang, "Discord") %></a></button>
        <button phx-click="goto_logs"><%= t(@lang, "Logs") %></button>
      </div>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" lang={@lang} back_button={false} />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} lang={@lang} />
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("right_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}

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
          [{room_state_pid, _}] = Utils.registry_lookup("room_state", ruleset, room_code)
          room_state = GenServer.call(room_state_pid, :get_state)
          not room_state.private
        end)
        socket = if has_public_room do
          push_navigate(socket, to: ~p"/lobby/#{ruleset}?nickname=#{nickname}&lang=#{socket.assigns.lang}")
        else
          {:ok, _, room_code} = LobbyState.create_room(%Lobby{ruleset: ruleset})
          push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{nickname}&from=home&lang=#{socket.assigns.lang}")
        end
        {:noreply, socket}
      end
    else
      # tutorial
      socket = if ruleset != "custom" do
        push_navigate(socket, to: ~p"/tutorial/#{ruleset}?nickname=#{nickname}&lang=#{socket.assigns.lang}")
      else socket end
      {:noreply, socket}
    end
  end
  
  def handle_event("goto_about", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/about?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end
  
  def handle_event("goto_logs", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/log?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.assigns.session_id do
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
