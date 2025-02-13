defmodule RiichiAdvancedWeb.TutorialCreatorLive do
  alias RiichiAdvanced.Constants, as: Constants
  use RiichiAdvancedWeb, :live_view

  @initial_sequence_json """
  {
    "mods": [],
    "config": {
      "starting_hand": {
        "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "7s", "8s", "8s", "1z"],
        "south": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
        "west": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
        "north": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"]
      },
      "starting_draws": ["6s", "1z", "2z", "3z", "5s"],
      "tsumogiri_bots": true
    },
    "scenes": {
      "start": [
        ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
          "text": "Hello, world!"
        }]
      ]
    }
  }
  """

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:messages, [])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:ruleset, Map.get(params, "ruleset", "riichi"))
    |> assign(:seat, Map.get(params, "seat", "east"))
    |> assign(:tutorial_id, Map.get(params, "tutorial_id", nil))
    |> assign(:from, Map.get(params, "from", nil))
    |> assign(:loading, false)

    sequence_json = if socket.assigns.tutorial_id != nil do
      case RiichiAdvanced.ETSCache.get({socket.assigns.ruleset, socket.assigns.tutorial_id}, [], :cache_sequences) do
        [sequence_json] -> sequence_json
        _ -> @initial_sequence_json
      end
    else @initial_sequence_json end
    socket = assign(socket, :sequence_json, sequence_json)

    messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
      GenServer.cast(messages_init.messages_state, :poll_messages)
      socket
    else socket end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container" phx-hook="ClickListener">
      <form class="tutorial-menu-container" phx-submit="submit_tutorial">
        <header>
          <select name="ruleset" class="ruleset-dropdown">
            <%= for {ruleset, name, _desc} <- Constants.available_rulesets() do %>
              <%= if ruleset == @ruleset do %>
                <option value={ruleset} selected><%= name %></option>
              <% else %>
                <option value={ruleset}><%= name %></option>
              <% end %>
            <% end %>
          </select>
          <%= for {name, short_name} <- [{"east", "東"}, {"south", "南"}, {"west", "西"}, {"north", "北"}] do %>
            <input type="radio" id={name} name="seat" value={name} checked={name==@seat} phx-update="ignore">
            <label for={name}><%= short_name %></label>
          <% end %>
        </header>
        <textarea name="sequence_json"><%= @sequence_json %></textarea>
        <button type="submit">
          <%= if @loading do %>Loading...<% else %>Play<% end %>
        </button>
      </form>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = case socket.assigns.from do
      nil     -> push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}")
      ruleset -> push_navigate(socket, to: ~p"/tutorial/#{ruleset}?nickname=#{socket.assigns.nickname}")
    end
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end
  
  def handle_event("submit_tutorial", %{"ruleset" => ruleset, "sequence_json" => sequence_json, "seat" => seat}, socket) do
    socket = assign(socket, :loading, true)
    socket = assign(socket, :sequence_json, sequence_json)
    socket = assign(socket, :ruleset, ruleset)
    socket = assign(socket, :seat, seat)
    send(self(), {:goto_tutorial, ruleset, sequence_json, seat})
    {:noreply, socket}
  end

  def handle_event(_, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info({:goto_tutorial, ruleset, sequence_json, seat}, socket) do
    # 2MB char limit on sequence_json
    if sequence_json != nil and byte_size(sequence_json) <= 2 * 1024 * 1024 do
      uuid = Ecto.UUID.generate()
      RiichiAdvanced.ETSCache.put({ruleset, uuid}, sequence_json, :cache_sequences)
      socket = push_navigate(socket, to: ~p"/tutorial/#{ruleset}/#{uuid}?seat=#{seat}&nickname=#{socket.assigns.nickname}")
      {:noreply, socket}
    else {:noreply, socket} end
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

end
