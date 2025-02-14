defmodule RiichiAdvancedWeb.LogMenuLive do
  alias RiichiAdvanced.Constants, as: Constants
  use RiichiAdvancedWeb, :live_view

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:messages, [])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:log_id, "")
    |> assign(:error_message, nil)
    |> assign(:version, Constants.version())
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
    <div id="container">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <form phx-submit="redirect">
        Log ID:
        <input type="text" name="log_id" placeholder="Log ID" value={@log_id}/>
        <br/>
        <%= if @error_message != nil do %>
          <div class="form-error"><%= @error_message %></div>
        <% end %>
        <button type="submit" class="enter-button">View log</button>
      </form>
      <div class="index-version"><%= @version %></div>
      <div class="index-bottom-buttons">
        <button phx-click="goto_about">About</button>
        <button><a href="https://github.com/EpicOrange/riichi_advanced">Source</a></button>
        <button><a href="https://discord.gg/5QQHmZQavP">Discord</a></button>
        <button phx-click="goto_index">Back</button>
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("redirect", %{"log_id" => log_id}, socket) do
    # check if this log exists
    if File.exists?(Application.app_dir(:riichi_advanced, "/priv/static/logs/#{log_id <> ".json"}")) do
      socket = push_navigate(socket, to: ~p"/log/#{log_id}?nickname=#{socket.assigns.nickname}")
      {:noreply, socket}
    else
      socket = assign(socket, :error_message, "Log #{log_id} does not exist!")
      socket = assign(socket, :log_id, log_id)
      {:noreply, socket}
    end
  end
  
  def handle_event("goto_about", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/about?nickname=#{socket.assigns.nickname}")
    {:noreply, socket}
  end

  def handle_event("goto_index", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}")
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
