defmodule RiichiAdvanced.Validator do
  alias RiichiAdvanced.Utils

  @allowed_actions [
    # normal actions
    "noop", "print", "print_status", "print_counters", "print_pao_map", "print_context", "print_hand", "print_discards", "print_tags", "push_message", "push_system_message", "add_rule", "update_rule", "delete_rule", "add_rule_tab", "run", "play_tile", "draw", "draw_aside", "call", "self_call", "upgrade_call", "flower", "trigger_custom_call", "draft_saki_card", "reverse_turn_order", "advance_turn", "change_turn", "win_by_discard", "win_by_call", "win_by_draw", "win_by_second_visible_discard", "ryuukyoku", "abortive_draw", "set_status", "unset_status", "set_status_all", "unset_status_all", "set_counter", "set_counter_all", "add_counter", "subtract_counter", "multiply_counter", "divide_counter", "big_text", "pause", "sort_hand", "reveal_tile", "add_score", "subtract_score", "put_down_riichi_stick", "bet_points", "add_honba", "reveal_hand", "reveal_other_hands", "discard_draw", "press_button", "press_first_call_button", "when", "unless", "ite", "as", "when_anyone", "when_everyone", "when_others", "mark", "move_tiles", "swap_tiles", "copy_tiles", "delete_tiles", "swap_marked_calls", "swap_out_fly_joker", "extend_live_wall_with_marked", "extend_dead_wall_with_marked", "pon_marked_discard", "flip_marked_discard_facedown", "clear_marking", "set_tile_alias", "set_tile_alias_all", "save_tile_behavior", "load_tile_behavior", "clear_tile_aliases", "set_tile_ordering", "set_tile_ordering_all", "add_attr", "add_attr_first_tile", "add_attr_tagged", "remove_attr_hand", "remove_attr_all", "tag_tiles", "tag_drawn_tile", "tag_last_discard", "tag_dora", "untag_tiles", "untag", "convert_last_discard", "flip_all_calls_faceup", "flip_first_visible_discard_facedown", "flip_aside_facedown", "draw_from_aside", "charleston_left", "charleston_across", "charleston_right", "shift_tile_to_dead_wall", "resume_deferred_actions", "cancel_deferred_actions", "recalculate_buttons", "recalculate_playables", "draw_last_discard", "check_discard_passed", "scry", "scry_all", "clear_scry", "choose_yaku", "disable_saki_card", "enable_saki_card", "save_revealed_tiles", "load_revealed_tiles", "merge_draw", "pass_draws", "saki_start", "register_last_discard", "enable_auto_button", "modify_winner", "modify_payout", "set_scoring_header", "make_responsible_for", "pause",
    # minipoints actions
    "put_calls_in_hand", "put_winning_tile_in_hand", "remove_attrs", "add", "prune", "convert_calls", "remove_calls", "remove_winning_groups", "remove_groups", "retain_empty_hands", "round_up", "take_maximum", "add_original_hand", "print", "count"
  ]
  def allowed_actions, do: @allowed_actions

  @allowed_conditions ["not", "true", "false", "equals", "print", "print_status", "print_counters", "print_context", "our_turn", "our_turn_is_next", "our_turn_is_prev", "game_start", "no_discards_yet", "no_calls_yet", "last_call_is", "kamicha_discarded", "toimen_discarded", "shimocha_discarded", "anyone_just_discarded", "someone_else_just_discarded", "just_discarded", "anyone_just_called", "someone_else_just_called", "just_called", "just_self_called", "call_available", "self_call_available", "can_upgrade_call", "has_draw", "has_aside", "has_calls", "has_call_named", "has_no_call_named", "won", "won_by_call", "won_by_draw", "won_by_discard", "ended_by_exhaustive_draw", "ended_by_abortive_draw", "has_yaku", "has_yaku2", "has_yaku_with_hand", "has_yaku_with_discard", "has_yaku_with_call", "has_yaku2_with_hand", "has_yaku2_with_discard", "has_yaku2_with_call", "has_declared_yaku_with_hand", "has_declared_yaku_with_discard", "has_declared_yaku_with_call", "tiles_match", "last_discard_matches", "last_called_tile_matches", "needed_for_hand", "is_drawn_tile", "status", "status_missing", "discarder_status", "callee_status", "caller_status", "shimocha_status", "toimen_status", "kamicha_status", "others_status", "anyone_status", "everyone_status", "buttons_include", "buttons_exclude", "tile_drawn", "tile_not_drawn", "tile_revealed", "tile_not_revealed", "no_tiles_remaining", "tiles_remaining", "next_draw_possible", "has_score", "has_score_below", "round_wind_is", "seat_is", "hand_tile_count", "aside_tile_count", "hand_dora_count", "winning_dora_count", "winning_reverse_dora_count", "match", "winning_hand_consists_of", "winning_hand_not_tile_consists_of", "all_saki_cards_drafted", "has_existing_yaku", "has_no_yaku", "has_points", "placement", "last_discard_matches_existing", "called_tile_matches_any_discard", "last_discard_exists", "visible_discard_exists", "second_last_visible_discard_exists", "call_would_change_waits", "call_changes_waits", "wait_count_at_least", "wait_count_at_most", "call_contains", "called_tile_contains", "call_choice_contains", "tag_exists", "tagged", "has_attr", "has_hell_wait", "all_waits_are_in_hand", "third_row_discard", "tiles_in_hand", "anyone", "dice_equals", "counter_equals", "counter_at_least", "counter_at_most", "counter_more_than", "counter_less_than", "genbutsu_shimocha", "genbutsu_toimen", "genbutsu_kamicha", "dealt_in_last_round", "wall_is_here", "dead_wall_ends_here", "bet_at_least", "is_winner", "shimocha_exists", "toimen_exists", "kamicha_exists", "three_winners", "hand_length_at_least", "current_turn_is", "hand_is_dead", "all_calls_deaden_hand", "is_ai", "num_players", "is_tenpai_american", "can_discard_after_call", "minipoints_equals", "minipoints_at_least", "minipoints_at_most", "rule_exists", "is_responsible_for", "yaku_exists"]
  def allowed_conditions, do: @allowed_conditions

  @allowed_events ["after_bloody_end", "after_call", "after_charleston", "after_discard_passed", "after_draw", "after_initialization", "after_saki_start", "after_scoring", "after_start", "after_turn_change", "after_win", "before_abortive_draw", "before_call", "before_conclusion", "before_continue", "before_exhaustive_draw", "before_scoring", "before_start", "before_turn_change", "before_win", "on_no_valid_tiles"]
  def allowed_events, do: @allowed_events

  def sanitize_string(str) when is_binary(str), do: String.replace(str, "\\(", "\\\\(") # disallow any string interpolation

  # all of json, but don't allow null, true, or false
  def validate_json(nil), do: {:ok, nil}
  def validate_json(true), do: {:ok, true}
  def validate_json(false), do: {:ok, false}
  def validate_json(ast) when is_number(ast), do: {:ok, ast}
  def validate_json({:-, _pos, [value]}) when is_integer(value), do: {:ok, -value} # negative literals
  def validate_json(ast) when is_binary(ast), do: {:ok, sanitize_string(ast)}
  def validate_json(ast) when is_list(ast), do: ast |> Enum.map(&validate_json(&1)) |> Utils.sequence()
  def validate_json({:+, _, [{:@, _, [{name, _, nil}]}]}) when is_binary(name), do: validate_constant(name, true)
  def validate_json({:@, _, [{name, _, nil}]}) when is_binary(name), do: validate_constant(name)
  def validate_json({:!, _, [{name, _, nil}]}) when is_binary(name), do: validate_variable(name)
  def validate_json({:+, _, _} = ast), do: validate_expression(ast)
  def validate_json({:-, _, _} = ast), do: validate_expression(ast)
  def validate_json({:*, _, _} = ast), do: validate_expression(ast)
  # def validate_json(%RiichiAdvanced.Compiler.Constant{name: name}), do: validate_constant(name)
  # def validate_json(%RiichiAdvanced.Compiler.Variable{name: name}), do: validate_variable(name)
  # def validate_json(ast) when is_map(ast), do: validate_map(ast) # this matches structs...
  def validate_json({:%{}, _pos, contents}), do: validate_map(contents)
  def validate_json(not_json) do
    # IO.inspect(Process.info(self(), :current_stacktrace))
    {:error, "invalid JSON: #{inspect(not_json)}"}
  end

  # numeric expressions can only contain numeric expressions, not JSON
  def validate_expression(ast) when is_number(ast), do: {:ok, ast}
  def validate_expression({:!, _, [{name, _, nil}]}), do: validate_variable(name)
  def validate_expression({:+, _, [l, r]}), do: validate_operands(:+, l, r)
  def validate_expression({:-, _, [l, r]}), do: validate_operands(:-, l, r)
  def validate_expression({:*, _, [l, r]}), do: validate_operands(:*, l, r)
  def validate_expression(ast), do: {:error, "non-numeric node in expression: #{inspect(ast)}"}
  def validate_operands(op, l, r) when is_atom(op) do
    with {:ok, l} <- validate_expression(l),
         {:ok, r} <- validate_expression(r) do
      {:ok, %RiichiAdvanced.Compiler.Expression{op: op, l: l, r: r}}
    end
  end

  def validate_map(map) do
    validated_map = map
    |> Enum.map(fn {key, val} ->
      if is_binary(key) do
        case {validate_json(key), validate_json(val)} do
          {{:ok, key}, {:ok, val}} -> {:ok, {key, val}}
          {{:error, msg}, _}       -> {:error, "invalid JSON key: " <> msg}
          {_, {:error, msg}}       -> {:error, "invalid JSON value: " <> msg}
        end
      else {:error, "non-string JSON key: #{inspect(key)}"} end
    end)
    |> Utils.sequence()
    with {:ok, validated_map} <- validated_map do
      {:ok, Map.new(validated_map)}
    end
  end

  def validate_condition_name(name) when is_binary(name) do
    negated = is_binary(name) and String.starts_with?(name, "not_")
    base_name = if negated do String.replace_leading(name, "not_", "") else name end
    base_name in @allowed_conditions
  end
  def validate_condition_name(%RiichiAdvanced.Compiler.Constant{}), do: true
  def validate_condition_name(%RiichiAdvanced.Compiler.Variable{}), do: true
  def validate_condition_name(_name), do: false

  def validate_action_name(name) when is_binary(name) do
    negated = is_binary(name) and String.starts_with?(name, "uninterruptible_")
    base_name = if negated do String.replace_leading(name, "uninterruptible_", "") else name end
    base_name in @allowed_actions or String.starts_with?(name, "@")
  end
  def validate_action_name(_name), do: false

  @valid_path_regex ~r/^(\.[a-zA-Z0-9_]+|\[-?[0-9]+\]|\["[a-zA-Z0-9_ ]+"\])+$/
  def validate_json_path(path) when is_binary(path) do
    path = if String.starts_with?(path, ".") do path else "." <> path end
    if path == "." or Regex.match?(@valid_path_regex, path) do
      {:ok, path}
    else
      {:error, "got invalid path #{inspect(path)}"}
    end
  end
  def validate_json_path(path), do: {:error, "got non-string path #{inspect(path)}"}

  def get_parent_path(path) when is_binary(path) do
    path = Regex.scan(~r/(\.[^.\[\]]+|\[[^\]]+\])/, path)
    |> Enum.map(fn [match | _captures] -> match end)
    |> Enum.drop(-1)
    |> Enum.join("")
    {:ok, if String.starts_with?(path, ".") do path else "." <> path end}
  end
  def get_parent_path(path), do: {:error, "got non-string path #{inspect(path)}"}

  @valid_constant_regex ~r/^[a-z_][a-z0-9_]*$/
  def validate_constant(name, splatted \\ false)
  def validate_constant(name, splatted) when is_binary(name) do
    if Regex.match?(@valid_constant_regex, name) do
      {:ok, %RiichiAdvanced.Compiler.Constant{name: if splatted do "splat$" else "" end <> name}}
    else
      IO.inspect(Process.info(self(), :current_stacktrace))
      {:error, "invalid constant name: #{inspect(name)}"}
    end
  end
  def validate_constant(name, _splatted), do: {:error, "non-string constant name: #{inspect(name)}"}

  @valid_variable_regex ~r/^[a-z_][a-z0-9_]*$/
  def validate_variable(name) when is_binary(name) do
    if Regex.match?(@valid_variable_regex, name) do
      {:ok, %RiichiAdvanced.Compiler.Variable{name: name}}
    else
      {:error, "invalid variable name: #{inspect(name)}"}
    end
  end
  def validate_variable(name), do: {:error, "non-string variable name: #{inspect(name)}"}
end
