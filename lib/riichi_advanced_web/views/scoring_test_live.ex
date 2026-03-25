defmodule RiichiAdvancedWeb.ScoringTestLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.GameState, as: GameState
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Kyoku, as: Kyoku
  alias RiichiAdvanced.GameState.Payment, as: Payment
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.Rules, as: Rules
  alias RiichiAdvanced.GameState.Scoring, as: Scoring
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
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
      timer: -1,
      visible_screen: nil,
      players: Map.new([:east, :south, :west, :north], fn seat -> {seat, %Player{}} end),
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
    |> assign(:minipoints, 0)
    |> assign(:tiles, [])
    |> assign(:hand, [])
    # |> assign(:hand, [:"4m", :"2m", :"3m", :"4p", :"4p", :"4p", :"5p", :"6p", :"7p", :"3s", :"4s", :"2s", :"2s", :"2s"])

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
        <input id="show-yaku" name="scoringtest-header" type="radio" phx-update="ignore">
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
          <label for="show-yaku" class="shuffle-seats"><%= t(@lang, "Yaku") %></label>
          <label for="show-mods" class="shuffle-seats"><%= t(@lang, "Mods") %></label>
          <label for="show-config" class="shuffle-seats"><%= t(@lang, "Config") %></label>
          <label for="show-none" class="shuffle-seats"><%= t(@lang, "None") %></label>
        </header>
        <div class="hand-outer-container">
          <.live_component module={RiichiAdvancedWeb.HandSelectionComponent} id="scoringtest-hand" lang={@lang} ruleset={@ruleset} hand={@hand} tiles={@tiles}/>
        </div>
        <div class="yaku-outer-container">
          <.live_component module={RiichiAdvancedWeb.YakuSelectionComponent} id="scoringtest-yaku" lang={@lang} ruleset={@ruleset} yaku={@yaku} yaku_list_names={@yaku_list_names} minipoints={@minipoints} minipoint_name={@minipoint_name} />
        </div>
        <div class="mods-container">
          <.live_component module={RiichiAdvancedWeb.ModSelectionComponent} id="scoringtest-mods" lang={@lang} ruleset={@ruleset} mods={@room_state.mods} categories={@room_state.categories} />
        </div>
        <div class="config-container">
          <textarea name="config" phx-blur="save_config"><%= @config %></textarea>
        </div>
        <div class="scoring-test-bottom-buttons">
          <button phx-cancellable-click="clear_hand" class="clear">Clear</button>
          <form phx-submit="score_hand">
            <%= if @loading do %>
              <button><%= t(@lang, "Scoring...") %></button>
            <% else %>
              <button name="ron" type="submit"><%= t(@lang, "Ron") %></button>
              <button name="tsumo" type="submit"><%= t(@lang, "Tsumo") %></button>
            <% end %>
          </form>
        </div>
        <.live_component module={RiichiAdvancedWeb.WinWindowComponent}
          id="win-window"
          game_state={@state}
          seat={@seat}
          lang={@lang}
          winner={Map.get(@state.winners, Enum.at(@state.winner_seats, @state.winner_index), nil)}
          timer={@state.timer}
          visible_screen={@state.visible_screen}
          />
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
          txns={@state.txns}
          round_result={:win}
          />
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
    |> Enum.flat_map(fn {_list_name, yaku} -> Enum.map(yaku, &{&1.name, &1.value}) end)
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
    {mods, categories} = Rules.parse_available_mods(Rules.get(rules_ref, "available_mods", []), default_mods)
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
      ModLoader.get_ruleset_json(ruleset, nil, true)
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

  def score_hand(state, hand, is_ron?, selected_yaku, minipoints) do
    wall = Enum.map(Rules.get(state.rules_ref, "wall", []), &Utils.to_tile(&1))
    dead_wall_length = Rules.get(state.rules_ref, "initial_dead_wall_length", 0)
    {wall, dead_wall} = if dead_wall_length > 0 do
      Enum.split(wall, -dead_wall_length)
    else {wall, []} end
    state = %GameState.Game{
      wall: wall,
      dead_wall: dead_wall,
      log_loading_mode: true,
      rules_ref: state.rules_ref,
      players: state.players,
      log_state: %{log: []},
      timer: -1,
    }
    initial_score = Rules.get(state.rules_ref, "initial_score", 0)
    tile_freqs = Enum.frequencies(state.wall ++ state.dead_wall)
    state = GameState.update_all_players(state, fn seat, _player -> %Player{
      nickname: Atom.to_string(seat) |> String.capitalize(),
      score: initial_score,
      start_score: initial_score,
      tile_behavior: %TileBehavior{ tile_freqs: tile_freqs }
    } end)
    {winning_tile, hand} = List.pop_at(hand, -1)
    state = if is_ron? do
      payer = :west
      state
      |> GameState.update_player(:east, &%{ &1 | hand: hand })
      |> GameState.update_player(payer, &%{ &1 | discards: [winning_tile] })
      |> Actions.register_discard(payer, winning_tile, true, true)
    else
      state
      |> GameState.update_player(:east, &%{ &1 | hand: hand, draw: [Utils.add_attr(winning_tile, ["_draw"])] })
    end
    win_source = if is_ron? do :discard else :draw end
    scoring_key = case Rules.get(state.rules_ref, "scoring_logic", %{}) do
      %{"ron" => _} -> if is_ron? do "ron" else "tsumo" end
      logic when is_map(logic) -> Enum.at(logic, 0) |> elem(0)
      _ -> if is_ron? do "ron" else "tsumo" end
    end
    state = Kyoku.calculate_winner_details_v2(state, :east, win_source, scoring_key)
    state = update_in(state.winners.east.yaku, & &1 ++ selected_yaku)
    state = if minipoints > 0 do update_in(state.winners.east.minipoints, fn _ -> minipoints end) else state end
    {state, delta_scores, delta_scores_reason, _next_dealer} = Scoring.adjudicate_win_scoring(state)
    state
    |> Map.put(:delta_scores, delta_scores)
    |> Map.put(:delta_scores_reason, delta_scores_reason)
    |> Map.put(:visible_screen, :winner)
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

  # for hand selection component
  def handle_event("add_hand_tile", %{"tile" => tile}, socket) do
    socket = assign(socket, :hand, socket.assigns.hand ++ [tile])
    {:noreply, socket}
  end
  def handle_event("remove_hand_tile", %{"index" => index}, socket) do
    {ix, _} = Integer.parse(index)
    socket = assign(socket, :hand, List.delete_at(socket.assigns.hand, ix))
    {:noreply, socket}
  end
  def handle_event("clear_hand", _assigns, socket) do
    socket = assign(socket, :hand, [])
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
    socket = if socket.assigns.state.visible_screen == :winner do
      assign(socket, :state, %{socket.assigns.state | visible_screen: :scores})
    else
      assign(socket, :state, %{socket.assigns.state | visible_screen: nil})
    end
    {:noreply, socket}
  end

  def handle_event("score_hand", params, socket) do
    # silent 4MB limit
    if byte_size(socket.assigns.config) <= 4 * 1024 * 1024 do
      state = socket.assigns.state
      |> Map.put(:ruleset, socket.assigns.ruleset)
      |> Map.put(:config, socket.assigns.config)
      |> Map.put(:room_code, "scoringtest_" <> String.slice(socket.assigns.session_id, 0..7))
      |> Map.put(:rules_ref, socket.assigns.rules_ref)
      is_ron? = Map.has_key?(params, "ron")    
      hand = Enum.map(socket.assigns.hand, &Utils.to_tile(&1))
      selected_yaku = get_selected_yaku(socket.assigns.yaku)
      minipoints = socket.assigns.minipoints
      socket = socket
      |> start_async(:put_state, fn -> score_hand(state, hand, is_ron?, selected_yaku, minipoints) end)
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

      wall = Rules.get(rules_ref, "wall", [])
      socket = assign(socket, :tiles, Enum.uniq(wall))

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
