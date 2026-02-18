defmodule RiichiAdvancedWeb.MajsTestLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.RoomState, as: RoomState
  use RiichiAdvancedWeb, :live_view
  import RiichiAdvancedWeb.Translations

  def mount(params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:messages, [])
    |> assign(:nickname, Map.get(params, "nickname", ""))
    |> assign(:lang, Map.get(params, "lang", "en"))
    |> assign(:config, ModLoader.default_config())
    |> assign(:result, "")
    |> assign(:loading, false)

    socket = switch_mods_to_ruleset(socket, "riichi")

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
      <div class="majstest-container" phx-submit="convert_majs">
        <div><%= t(@lang, "Base ruleset") %></div>
        <input id="show-mods" type="checkbox" class="show-mods-checkbox" phx-update="ignore">
        <label for="show-mods" class="shuffle-seats"><%= t(@lang, "Mods") %></label>
        <div class="mods-container">
          <.live_component module={RiichiAdvancedWeb.ModSelectionComponent} id="room-mods" lang={@lang} ruleset={@ruleset} mods={@room_state.mods} categories={@room_state.categories} />
        </div>
        <form phx-submit="convert_majs">
          <select name="ruleset" class="ruleset-dropdown" phx-change="switch_ruleset">
            <%= for {ruleset, name, _desc} <- Constants.available_rulesets() do %>
              <option value={ruleset}><%= name %></option>
            <% end %>
          </select>
          <br/>
          .majs:
          <textarea name="config"><%= @config %></textarea>
          <%= if @loading do %>
            <button><%= t(@lang, "Processing...") %></button>
          <% else %>
            <button type="submit"><%= t(@lang, "Apply majs") %></button>
          <% end %>
          .json:
          <textarea><%= @result %></textarea>
        </form>
      </div>
      <div class="top-right-container">
        <.live_component module={RiichiAdvancedWeb.MenuButtonsComponent} id="menu-buttons" lang={@lang} />
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} lang={@lang} />
    </div>
    """
  end

  def get_enabled_mods(socket) do
    socket.assigns.room_state.mods
    |> Enum.filter(fn {_mod, opts} -> opts.enabled end)
    |> Enum.sort_by(fn {_mod, opts} -> {opts.order, opts.index} end)
    |> Enum.map(fn {mod, opts} -> if Enum.empty?(opts.config) do mod else
        %{name: mod, config: Map.new(opts.config, fn {name, config} -> {name, config.value} end)}
      end end)
  end
  
  def switch_mods_to_ruleset(socket, ruleset) do
    socket = assign(socket, :ruleset, ruleset)

    ruleset_json = ModLoader.get_ruleset_json(socket.assigns.ruleset)
    rules_ref = case Rules.load_rules(ruleset_json, socket.assigns.ruleset) do
      {:ok, rules_ref} -> rules_ref
      {:error, _msg}   -> nil
    end

    {mods, categories} = RoomState.parse_available_mods(Rules.get(rules_ref, "available_mods", []), Rules.get(rules_ref, "default_mods", []))
    # mock room state
    socket = assign(socket, :room_state, %{
        mods: mods,
        categories: categories,
        rules_ref: rules_ref,
      })
    socket
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("right_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}
  
  def handle_event("switch_ruleset", assigns, socket) do
    socket = switch_mods_to_ruleset(socket, assigns["ruleset"])
    {:noreply, socket}
  end

  # reuse RoomState's functions for mod selection stuff
  # ideally these functions would be in mod_selection_component.ex,
  # but that would require passing in a lot of callbacks in order to update shared room state
  # not sure if there is a cleaner way

  def handle_event("toggle_mod", %{"mod" => mod, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    socket = assign(socket, :room_state, RoomState.toggle_mod(socket.assigns.room_state, mod, not enabled))
    {:noreply, socket}
  end

  def handle_event("change_mod_config", assigns, socket) do
    %{"mod" => mod, "name" => name} = assigns
    ix = String.to_integer(assigns[name])
    socket = assign(socket, :room_state, RoomState.change_mod_config(socket.assigns.room_state, mod, name, ix))
    {:noreply, socket}
  end

  def handle_event("toggle_category", %{"category" => category}, socket) do
    socket = assign(socket, :room_state, RoomState.toggle_category(socket.assigns.room_state, category))
    {:noreply, socket}
  end

  def handle_event("reset_mods_to_default", _assigns, socket) do
    socket = assign(socket, :room_state, RoomState.reset_mods_to_default(socket.assigns.room_state))
    {:noreply, socket}
  end

  def handle_event("randomize_mods", _assigns, socket) do
    socket = assign(socket, :room_state, RoomState.randomize_mods(socket.assigns.room_state))
    {:noreply, socket}
  end

  def handle_event("convert_majs", %{"ruleset" => ruleset, "config" => config}, socket) do
    # silent 4MB limit
    if byte_size(config) <= 4 * 1024 * 1024 do
      self = self()
      Task.start(fn ->
        ruleset_json = ModLoader.get_ruleset_json(ruleset)
        config_query = ModLoader.convert_to_jq(config)
        mods = get_enabled_mods(socket)
        IO.inspect(mods)
        ruleset_json = ModLoader.apply_multiple_mods(ruleset_json, mods)
        ruleset_json = JQ.query_string_with_string!(ruleset_json, config_query)
        send(self, {:converted_majs, config, ruleset_json})
      end)
      socket = assign(socket, :loading, true)
      socket = assign(socket, :config, config)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_info({:converted_majs, _config, result}, socket) do
    socket = assign(socket, :result, result)
    socket = assign(socket, :loading, false)
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
