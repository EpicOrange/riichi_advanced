defmodule RiichiAdvancedWeb.ScoringTestLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState, as: GameState
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.ModLoader, as: ModLoader
  alias RiichiAdvanced.RoomState, as: RoomState
  alias RiichiAdvanced.Utils, as: Utils
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
    |> assign(:seat, :east)
    |> assign(:state, %{
      winners: %{east: %{}},
      winner_seats: [:east],
      winner_index: 0,
      timer: 0,
      visible_screen: nil,
      players: Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{
        score: 25000,
        nickname: Atom.to_string(seat) |> String.capitalize()
      }} end),
      delta_scores: %{},
      delta_scores_reason: nil,
      available_seats: [:east, :south, :west, :north],
      txns: [],
    })
    |> assign(:ruleset, nil)
    |> assign(:ruleset_json, nil)
    |> assign(:yaku, [])
    |> assign(:yaku_list_names, [])
    |> assign(:yaku_lists, [])
    |> assign(:yaku2_lists, [])
    |> assign(:extra_yaku_lists, [])
    |> assign(:minipoint_name, "Fu")
    |> assign(:minipoints, 30)

    socket = switch_to_ruleset(socket, "riichi")
    |> reload_ruleset()

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
      <div class="scoringtest-container">
        <input id="show-mods" name="scoringtest-header" type="radio" phx-update="ignore">
        <input id="show-config" name="scoringtest-header" type="radio" phx-update="ignore">
        <input id="show-none" name="scoringtest-header" type="radio" phx-update="ignore" phx-click="save_mods">
        <header>
          <div><%= t(@lang, "Ruleset") %></div>
          <form>
            <select name="ruleset" class="ruleset-dropdown" phx-change="switch_ruleset">
              <%= for {ruleset, name, _desc} <- Constants.available_rulesets() do %>
                <%= if ruleset == @ruleset do %>
                  <option value={ruleset} selected><%= name %></option>
                <% else %>
                  <option value={ruleset}><%= name %></option>
                <% end %>
              <% end %>
            </select>
          </form>
          <label for="show-mods" class="shuffle-seats"><%= t(@lang, "Mods") %></label>
          <label for="show-config" class="shuffle-seats"><%= t(@lang, "Config") %></label>
          <label for="show-none" class="shuffle-seats"><%= t(@lang, "None") %></label>
        </header> 
        <div class="mods-container">
          <.live_component module={RiichiAdvancedWeb.ModSelectionComponent} id="scoringtest-mods" lang={@lang} ruleset={@ruleset} mods={@room_state.mods} categories={@room_state.categories} />
        </div>
        <div class="yaku-outer-container">
          <.live_component module={RiichiAdvancedWeb.YakuSelectionComponent} id="scoringtest-yaku" lang={@lang} ruleset={@ruleset} yaku={@yaku} yaku_list_names={@yaku_list_names} />
        </div>
        <div class="config-container">
          <textarea name="config" phx-blur="save_config"><%= @config %></textarea>
        </div>
        <form phx-submit="score_yaku">
          <div class="yaku-bottom-buttons">
            <%= if @minipoint_name != nil do %>
              <span class="yaku-bottom-minipoint-name"><%= dt(@lang, @minipoint_name) %></span>
              <input phx-blur="change_minipoints_value" name="minipoints-value" type="number" value={@minipoints} onclick="this.select();">
            <% else %>
              <input name="minipoints-value" type="hidden" value={@minipoints}>
            <% end %>
            <button phx-cancellable-click="clear_yaku"><%= t(@lang, "Unselect all") %></button>
            <%= if @loading do %>
              <button><%= t(@lang, "Scoring...") %></button>
            <% else %>
              <button type="submit"><%= t(@lang, "Score") %></button>
            <% end %>
          </div>
        </form>
        <.live_component module={RiichiAdvancedWeb.ScoreWindowComponent}
          id="score-window"
          seat={@seat}
          lang={@lang}
          players={@state.players}
          winners={@state.winners}
          delta_scores={@state.delta_scores}
          delta_scores_reason={@state.delta_scores_reason}
          timer={@state.timer}
          visible_screen={@state.visible_screen}
          available_seats={@state.available_seats}
          txns={@state.txns}/>
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
  def get_selected_yaku(yaku_assign) do
    yaku_assign
    |> Enum.filter(& &1.selected)
    |> Enum.group_by(& &1.list_name)
    |> Map.new(fn {list_name, yaku} -> {list_name, Enum.map(yaku, &{&1.name, &1.value})} end)
  end
  
  def switch_to_ruleset(socket, ruleset) when ruleset != socket.assigns.ruleset do
    socket = assign(socket, :ruleset, ruleset)
    ruleset_json = ModLoader.get_ruleset_json(socket.assigns.ruleset)

    # from the base ruleset, get its mod list
    rules_ref = case Rules.load_rules(ruleset_json, socket.assigns.ruleset) do
      {:ok, rules_ref} -> rules_ref
      {:error, _msg}   -> nil
    end
    socket = assign(socket, :rules_ref, rules_ref)

    default_mods = Rules.get(rules_ref, "default_mods", [])
    {mods, categories} = RoomState.parse_available_mods(Rules.get(rules_ref, "available_mods", []), default_mods)
    # mock room state
    socket = assign(socket, :room_state, %{
      mods: mods,
      categories: categories,
      rules_ref: rules_ref,
    })
    socket
  end
  def switch_to_ruleset(socket, _ruleset), do: socket

  def reload_ruleset(socket) do
    ruleset = socket.assigns.ruleset
    mods = get_enabled_mods(socket)
    config = socket.assigns.config
    start_async(socket, :reload_ruleset, fn ->
      # apply all default mods + config to base ruleset
      ModLoader.get_ruleset_json(ruleset)
      |> ModLoader.apply_multiple_mods(mods)
      |> JQ.query_string_with_string!(ModLoader.convert_to_jq(config))
    end)
  end

  def retrieve_yaku_lists(socket) do
    rules_ref = socket.assigns.rules_ref
    score_rules = Rules.get(rules_ref, "score_calculation", %{})
    point_names = %{
      "yaku_lists" => Map.get(score_rules, "point_name", ""),
      "yaku2_lists" => Map.get(score_rules, "point2_name", ""),
      "extra_yaku_lists" => Map.get(score_rules, "point_name", ""),
    }
    prev_selections = socket.assigns.yaku
    |> Enum.filter(& &1.selected == true)
    |> MapSet.new(& &1.name)
    parse_yaku = fn list_name ->
      Rules.get(rules_ref, list_name, [])
      |> Enum.map(fn yaku = %{"display_name" => name, "value" => value} -> %{
        name: name,
        desc: Map.get(yaku, "desc", ""),
        value: value,
        list_name: list_name,
        value_name: Map.get(point_names, list_name, ""),
        selected: MapSet.member?(prev_selections, name),
        index: 0,
      } end)
    end
    yaku_lists = Map.get(score_rules, "yaku_lists", [])
    yaku2_lists = Map.get(score_rules, "yaku2_lists", [])
    extra_yaku_lists = Map.get(score_rules, "extra_yaku_lists", [])
    yaku_list_names = yaku_lists ++ yaku2_lists ++ extra_yaku_lists

    socket = socket
    |> assign(:yaku_lists, yaku_lists)
    |> assign(:yaku2_lists, yaku2_lists)
    |> assign(:extra_yaku_lists, extra_yaku_lists)
    |> assign(:yaku_list_names, yaku_list_names)
    |> assign(:yaku, 
      Enum.flat_map(yaku_list_names, parse_yaku)
      |> Enum.uniq()
      |> Enum.with_index()
      |> Enum.map(fn {yaku, i} -> %{yaku | index: i} end)
    ) 
    |> assign(:minipoint_name, Map.get(score_rules, "minipoint_name", "Fu"))
    socket
  end

  def score_yaku(state, selected_yaku, minipoints) do
    if not Enum.empty?(selected_yaku) do
      score_rules = Rules.get(state.rules_ref, "score_calculation", %{})
      points = Enum.flat_map(Map.values(selected_yaku), &Enum.map(&1, fn {_name, value} -> value end)) |> Enum.reduce([], &Scoring.add_yaku_values/2)
      mock_gamestate = %GameState.Game{
        log_loading_mode: true,
        rules_ref: state.rules_ref,
        players: state.players,
        log_state: %{log: []},
      }
      mock_gamestate = put_in(mock_gamestate.players.south.responsibilities, %{east: ["all"]})
      cxt = %{
        seat: :east,
        win_source: :discard,
        smt_hand: [],
        smt_calls: [],
        winning_tile: :"3s",
        winning_hand: [:"3s"],
        is_dealer: true,
        scoring_key: "ron",
        rules_ref: state.rules_ref,
        yaku: selected_yaku,
        minipoints: minipoints,
        points: Utils.get_from_points_list(points, score_rules["point_name"]),
        points2: Utils.get_from_points_list(points, score_rules["point2_name"]),
      }
      mock_gamestate = mock_gamestate
      |> Actions.register_discard(:south, :"3s", true, true)
      |> Actions.trigger_event("before_win", cxt)
      |> Actions.trigger_event("before_scoring", cxt)
      |> Payment.run_scoring_logic(cxt)
      mock_gamestate.txns
      |> IO.inspect(label: "txns")
      value = mock_gamestate.txns |> Enum.filter(& &1.to == :east) |> Payment.consolidate_txns() |> Map.get(:east) |> Payment.get_txn_result()
      |> IO.inspect(label: "value")

      state
      |> Map.put(:winners, %{east: %{}})
      |> Map.put(:winner_seats, [:east])
      |> Map.put(:winner_index, 0)
      |> Map.put(:visible_screen, :scores)
      |> Map.put(:delta_scores, %{east: value, south: -value, west: 0, north: 0})
      |> Map.put(:txns, mock_gamestate.txns)
    end
  end

  def handle_event("back", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/?nickname=#{socket.assigns.nickname}&lang=#{socket.assigns.lang}")
    {:noreply, socket}
  end

  def handle_event("double_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("right_clicked", _assigns, socket), do: {:noreply, socket}
  def handle_event("change_language", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :lang, lang)}
  def handle_event("switch_ruleset", %{"ruleset" => ruleset}, socket), do: {:noreply, socket |> switch_to_ruleset(ruleset) |> reload_ruleset()}
  def handle_event("save_mods", _assigns, socket), do: {:noreply, socket |> reload_ruleset()}
  def handle_event("save_config", %{"value" => value}, socket), do: {:noreply, socket |> assign(:config, value) |> reload_ruleset()}

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

  # for yaku_selection_component
  def handle_event("toggle_yaku", %{"index" => index, "selected" => selected}, socket) do
    selected = selected == "true"
    ix = String.to_integer(index)
    socket = assign(socket, :yaku, List.update_at(socket.assigns.yaku, ix, &Map.put(&1, :selected, not selected)))
    {:noreply, socket}
  end
  def handle_event("change_yaku_value", %{"index" => index, "yaku-value" => value}, socket) do
    ix = String.to_integer(index)
    value = String.to_integer(value)
    yaku = socket.assigns.yaku
    socket = assign(socket, :yaku, List.update_at(yaku, ix, &Map.put(&1, :value, value)))
    {:noreply, socket}
  end
  def handle_event("clear_yaku", _assigns, socket) do
    yaku = socket.assigns.yaku
    socket = assign(socket, :yaku, Enum.map(yaku, &Map.put(&1, :selected, false)))
    {:noreply, socket}
  end
  def handle_event("change_minipoints_value", %{"value" => minipoints}, socket) do
    {minipoints, _rest} = Integer.parse(minipoints)
    socket = assign(socket, :minipoints, minipoints)
    {:noreply, socket}
  end
  def handle_event("ready_for_next_round", _assigns, socket) do
    socket = assign(socket, :state, %{socket.assigns.state | visible_screen: nil})
    {:noreply, socket}
  end

  def handle_event("score_yaku", _assigns, socket) do
    # silent 4MB limit
    if byte_size(socket.assigns.config) <= 4 * 1024 * 1024 do
      # yaku_lists = socket.assigns.yaku_lists ++ socket.assigns.extra_yaku_lists
      # yaku2_lists = socket.assigns.yaku2_lists
      minipoints = socket.assigns.minipoints
      # score_rules = Rules.get(socket.assigns.rules_ref, "score_calculation", %{})
      state = socket.assigns.state
      |> Map.put(:ruleset, socket.assigns.ruleset)
      |> Map.put(:config, socket.assigns.config)
      |> Map.put(:room_code, "scoringtest_" <> String.slice(socket.assigns.session_id, 0..7))
      |> Map.put(:rules_ref, socket.assigns.rules_ref)
      selected_yaku = get_selected_yaku(socket.assigns.yaku)
      socket = socket
      |> start_async(:put_state, fn -> score_yaku(state, selected_yaku, minipoints) end)
      |> assign(:loading, true)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event(_event, _assigns, socket) do
    {:noreply, socket}
  end

  def handle_async(:reload_ruleset, {:ok, ruleset_json}, socket) do
    if ruleset_json != socket.assigns.ruleset_json do
      socket = assign(socket, :ruleset_json, ruleset_json)

      rules_ref = case Rules.load_rules(ruleset_json, socket.assigns.ruleset) do
        {:ok, rules_ref} -> rules_ref
        {:error, _msg}   -> nil
      end
      socket = assign(socket, :rules_ref, rules_ref)
      {:noreply, retrieve_yaku_lists(socket)}
    else {:noreply, socket} end
  end
  def handle_async(:put_state, {:ok, state}, socket) do
    socket = socket
    |> assign(:state, state)
    |> assign(:loading, false)
    {:noreply, socket}
  end
  def handle_async(id, result, socket) do
    IO.inspect({id, result})
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

  def handle_info(_info, socket), do: {:noreply, socket}

end
