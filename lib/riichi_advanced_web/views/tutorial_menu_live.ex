defmodule RiichiAdvancedWeb.TutorialMenuLive do
  alias RiichiAdvanced.ModLoader, as: ModLoader
  use RiichiAdvancedWeb, :live_view

  @tutorials %{
    "riichi" => [
      {"riichi_basics", "Basic flow of the game", :east},
      {"riichi_calls", "Calling tiles", :north}
    ]
  }

  def mount(params, _session, socket) do
    socket = socket
    |> assign(:messages, [])
    |> assign(:ruleset, params["ruleset"])
    |> assign(:nickname, params["nickname"])
    |> assign(:display_name, params["ruleset"])
    |> assign(:available_tutorials, Map.get(@tutorials, params["ruleset"], []))
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
      <header class="tutorial-menu-header">
        <h3>Tutorials for ruleset: <b><%= @display_name %></b></h3>
      </header>
      <div class="tutorial-menu-container">
        <%= if Enum.empty?(@available_tutorials) do %>
          Sorry, there are currently no tutorials for this ruleset!
          <br/>
          Hit the back button to return to the main menu.
        <% else %>
          <div class="tutorial-menu-buttons">
            <button phx-cancellable-click="goto_tutorial" phx-value-index={i} phx-value-sequence={sequence} phx-value-seat={seat} :for={{{sequence, name, seat}, i} <- Enum.with_index(@available_tutorials)}>
              Tutorial <%= i + 1 %>:
              <%= if @clicked_index == Integer.to_string(i) do %> Loading... <% else %> <%= name %> <% end %>
            </button>
          </div>
        <% end %>
      </div>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
      <div class="ruleset">
        <textarea readonly><%= @ruleset_json %></textarea>
      </div>
    </div>
    """
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/")
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

  def handle_event(_, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info({:goto_tutorial, sequence, seat}, socket) do
    socket = push_navigate(socket, to: ~p"/tutorial/#{socket.assigns.ruleset}/#{sequence}?nickname=#{socket.assigns.nickname}&seat=#{seat}")
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

end
