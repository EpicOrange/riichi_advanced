defmodule RiichiAdvancedWeb.TutorialMenuLive do
  alias RiichiAdvanced.LobbyState, as: LobbyState
  alias RiichiAdvanced.LobbyState.Lobby, as: Lobby
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:messages, [])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:display_name, params["ruleset"])
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:available_tutorials, Map.get(Constants.tutorials(), params["ruleset"], []))
    |> assign(:clicked_index, nil)

    ruleset_json = ModLoader.get_ruleset_json(socket.assigns.ruleset)
    socket = assign(socket, :ruleset_json, ruleset_json)

    # parse the ruleset to get its display name
    rules = try do
      case Jason.decode(RiichiAdvanced.ModLoader.strip_comments(ruleset_json)) do
        {:ok, rules} -> rules
        {:error, err} ->
          IO.puts("Erroring json:")
          IO.inspect(ruleset_json)
          IO.puts("WARNING: Failed to read ruleset file at character position #{err.position}!\nRemember that trailing commas are invalid!")
          %{}
      end
    rescue
      ArgumentError -> 
        IO.puts("WARNING: Ruleset \"#{socket.assigns.ruleset_json}\" doesn't exist!")
        %{}
    end
    socket = assign(socket, :display_name, Map.get(rules, "display_name", socket.assigns.display_name))

    messages_init = RiichiAdvanced.MessagesState.link_player_socket(socket.root_pid, socket.assigns.session_id)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.assigns.session_id)
      GenServer.cast(messages_init.messages_state, :poll_messages)
      socket
    else socket end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container" phx-hook="ClickListener">
      <header class="tutorial-menu-header">
        <h3><%= t(@lang, "Tutorials for ruleset:") %><b><%= dt(@lang, @display_name) %></b></h3>
      </header>
      <div class="tutorial-menu-container">
        <%= if Enum.empty?(@available_tutorials) do %>
          <%= t(@lang, "Sorry, there are currently no tutorials for this ruleset!") %>
          <br/>
          <%= t(@lang, "Hit the back button to return to the main menu.") %>
          <div class="tutorial-menu-buttons">
            <button phx-cancellable-click="create_tutorial">
              <%= t(@lang, "Create your own tutorial!") %>
            </button>
          </div>
        <% else %>
          <div class="tutorial-menu-buttons">
            <button phx-cancellable-click="goto_tutorial" phx-value-index={i} phx-value-sequence={sequence} phx-value-seat={seat} :for={{{sequence, name, seat}, i} <- Enum.with_index(@available_tutorials)}>
              <%= t(@lang, "Tutorial") %> <%= i + 1 %>:
              <%= if @clicked_index == Integer.to_string(i) do %> <%= t(@lang, "Loading...") %> <% else %> <%= dt(@lang, name) %> <% end %>
            </button>
            <button phx-cancellable-click="create_tutorial">
              <%= t(@lang, "Create your own tutorial!") %>
            </button>
          </div>
        <% end %>
      </div>
      <footer class="tutorial-menu-footer">
        <button phx-cancellable-click="play_game">
          <%= t(@lang, "Play") %> <%= dt(@lang, @display_name) %>!
        </button>
      </footer>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" lang={@lang} />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} lang={@lang} />
      <div class="ruleset">
        <div class="ruleset-text"><%= t(@lang, "Ruleset:") %></div>
        <textarea readonly><%= @ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end
  
  def handle_event("goto_tutorial", %{"sequence" => sequence, "seat" => seat, "index" => i}, socket) do
    socket = assign(socket, :clicked_index, i)
    send(self(), {:goto_tutorial, sequence, seat})
    {:noreply, socket}
  end
  
  def handle_event("play_game", _assigns, socket) do
    ruleset = socket.assigns.ruleset
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
      push_navigate(socket, to: ~p"/lobby/#{ruleset}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    else
      {:ok, _, room_code} = LobbyState.create_room(%Lobby{ruleset: ruleset})
      push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}&from=learn")
    end
    {:noreply, socket}
  end
  
  def handle_event("create_tutorial", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/tutorial_creator?ruleset=#{socket.assigns.ruleset}&from=#{socket.assigns.ruleset}&nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info({:goto_tutorial, sequence, seat}, socket) do
    socket = push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}/#{sequence}?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}&seat=#{seat}")
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

end
