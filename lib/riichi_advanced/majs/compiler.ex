defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Parser
  alias RiichiAdvanced.Utils
  alias RiichiAdvanced.Validator

  @binops ["atan2", "copysign", "drem", "fdim", "fmax", "fmin", "fmod", "frexp", "hypot", "jn", "ldexp", "modf", "nextafter", "nexttoward", "pow", "remainder", "scalb", "scalbln", "yn"]

  defp compile_condition(condition, line, column) do
    case condition do
      {:not, _, [condition]} ->
        with {:ok, result} <- compile_cnf_condition(condition, line, column) do
          {:ok, %{"name" => "not", "opts" => [result]}}
        end
      _ ->
        condition = case condition do
          false -> {:ok, {"false", []}}
          true -> {:ok, {"true", []}}
          condition when is_binary(condition) -> {:ok, {condition, []}}
          {:@, _, [{constant, _, nil}]} when is_binary(constant) -> {:ok, {"@" <> constant, []}}
          {condition, _, nil} when is_binary(condition) -> {:ok, {condition, []}}
          {condition, _, opts} when is_binary(condition) -> {:ok, {condition, opts}}
          %{"name" => condition, "opts" => opts} -> {:ok, {condition, opts}}
          _ -> {:error, "Compiler.compile_condition: at line #{line}:#{column}, expecting a condition, got #{inspect(condition)}"}
        end
        with {:ok, {condition, opts}} <- condition,
             {:ok, opts} <- Parser.parse_sigils(opts),
             {:ok, opts} <- Validator.validate_json(opts) do
          if Validator.validate_condition_name(condition) do
            if Enum.empty?(opts) do
              {:ok, condition}
            else
              {:ok, %{"name" => condition, "opts" => opts}}
            end
          else
            {:error, "Compiler.compile_condition: at line #{line}:#{column}, #{inspect(condition)} is not a valid condition"}
          end
        end
    end
  end

  defp compile_cnf_condition(condition, line, column) do
    case condition do
      {:and, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_cnf_condition(&1, line, column))) do
          {:ok, compiled_args |> Enum.map(&List.wrap/1) |> Enum.concat()}
        end
      {:or, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_dnf_condition(&1, line, column))) do
          {:ok, [compiled_args |> Enum.map(&List.wrap/1) |> Enum.concat()]}
        end
      _ -> compile_condition(condition, line, column)
    end
  end

  defp compile_dnf_condition(condition, line, column) do
    case condition do
      {:or, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_dnf_condition(&1, line, column))) do
          {:ok, compiled_args |> Enum.map(&List.wrap/1) |> Enum.concat()}
        end
      {:and, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_cnf_condition(&1, line, column))) do
          {:ok, [compiled_args |> Enum.map(&List.wrap/1) |> Enum.concat()]}
        end
      _ -> compile_condition(condition, line, column)
    end
  end

  defp compile_condition_list(condition, line, column) do
    with {:ok, condition} <- compile_cnf_condition(condition, line, column) do
      {:ok, List.wrap(condition)}
    end
  end

  # defp compile_action!(action, line, column) do
  #   case compile_action(action, line, column) do
  #     {:ok, json} -> json
  #     {:error, error} -> raise error
  #   end
  # end
  defp compile_action(action, line, column) do
    case action do
      {:@, _pos, action} -> {:ok, Validator.validate_json(action)}
      {"if", [line: line, column: column], opts} ->
        case opts do
          [condition, actions] ->
            with {:ok, condition} <- compile_condition_list(condition, line, column),
                 {:ok, then_branch} <- compile_action_list(Keyword.get(actions, :do), line, column) do
              else_branch_ast = Keyword.get(actions, :else)
              if else_branch_ast == nil do
                {:ok, ["when", condition, then_branch]}
              else
                with {:ok, else_branch} <- compile_action_list(else_branch_ast, line, column) do
                  {:ok, ["ite", condition, then_branch, else_branch]}
                end
              end
            end
          _ -> {:error, "\"if\" got invalid parameters: #{inspect(opts)}"}
        end
      {"unless", [line: line, column: column], opts} ->
        case opts do
          [condition, actions] ->
            with {:ok, condition} <- compile_condition_list(condition, line, column),
                 {:ok, then_branch} <- compile_action_list(Keyword.get(actions, :do), line, column) do
              else_branch_ast = Keyword.get(actions, :else)
              if else_branch_ast == nil do
                {:ok, ["unless", condition, then_branch]}
              else
                with {:ok, else_branch} <- compile_action_list(else_branch_ast, line, column) do
                  {:ok, ["ite", condition, else_branch, then_branch]}
                end
              end
            end
          _ -> {:error, "\"unless\" got invalid parameters: #{inspect(opts)}"}
        end
      {"as", [line: line, column: column], opts} ->
        case opts do
          [seats_spec, actions] ->
            seats_spec = case seats_spec do
              seats_spec when is_binary(seats_spec) -> {:ok, seats_spec}
              {seats_spec, _pos, nil} when is_binary(seats_spec) -> {:ok, seats_spec}
              _ -> {:error, "Compiler.compile_action: at line #{line}:#{column}, `as` expects a seat spec, got #{inspect(seats_spec)}"}
            end
            with {:ok, seats_spec} <- seats_spec,
                 {:ok, actions} <- compile_action_list(Keyword.get(actions, :do), line, column) do
              {:ok, ["as", seats_spec, actions]}
            end
          _ -> {:error, "\"as\" got invalid parameters: #{inspect(opts)}"}
        end
      {name, [line: line, column: column], args} when is_binary(name) ->
        if name in Validator.allowed_actions() do
          if args != nil do
            # each action in a do block should be treated as another parameter
            args = Enum.map(Enum.with_index(args), &case &1 do
              {{:@, _, [{constant, _, nil}]}, _i} when is_binary(constant) -> {:ok, ["@" <> constant]}
              {[do: actions], _i} ->
                with {:ok, action_list} <- compile_action_list(actions, line, column) do
                  {:ok, [action_list]}
                end
              {arg, i} when name == "add" and i == 1 ->
                with {:ok, condition} <- compile_condition_list(arg, line, column) do
                  {:ok, [condition]}
                end
              {arg, _i} -> {:ok, [arg]}
            end)
            |> Utils.sequence()
            with {:ok, args} <- args,
                 {:ok, args} <- Parser.parse_sigils(args),
                 {:ok, args} <- args |> Enum.concat() |> Enum.map(&Validator.validate_json/1) |> Utils.sequence() do
              {:ok, [name | args]}
            end
          else
            {:ok, [name]}
          end
        else
          # convert into a function call
          with {:ok, name} <- Validator.validate_json(name),
               {:ok, args} <- Parser.parse_sigils(args),
               {:ok, args} <- Validator.validate_json(args) do
            case args do
              [args] -> {:ok, ["run", name, Map.new(args)]}
              _      -> {:ok, ["run", name]}
            end
          end
        end
      _ -> {:error, "Compiler.compile_action: at line #{line}:#{column}, expected an action or a if block, got #{inspect(action)}"}
    end
  end

  # defp compile_action_list!(action, line, column) do
  #   case compile_action_list(action, line, column) do
  #     {:ok, json} -> json
  #     {:error, error} -> raise error
  #   end
  # end
  defp compile_action_list(ast, line, column) do
    case ast do
      {:__block__, [], actions} -> compile_action_list(actions, line, column)
      {_name, [line: line, column: column], _actions} -> compile_action_list([ast], line, column)
      actions when is_list(actions) -> Utils.sequence(Enum.map(actions, &compile_action(&1, line, column)))
      _ -> {:error, "Compiler.compile_action_list: at line #{line}:#{column}, expected an action list, got #{inspect(ast)}"}
    end
  end

  defp compile_constant(value, line, column) do
    with {:error, _} <- Validator.validate_json(value),
         {:error, _} <- compile_cnf_condition(value, line, column),
         {:error, _} <- compile_action(value, line, column),
         {:error, _} <- compile_action_list(Keyword.get(value, :do), line, column) do
      {:error, "Compiler.compile_constant: at line #{line}:#{column}, expected JSON, condition, action, or do block, got #{inspect(value)}"}
    end
  end

  defp compile_command("var", name, args, line, column) do
    value = case args do
      [value] -> {:ok, value}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `set` command expects only one value, got #{inspect(args)}"}
    end
    with {:ok, value} <- value,
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value) do
      {:ok, ".[#{name}] = #{value}"}
    end
  end

  defp compile_command("def", name, args, line, column) do
    with {:ok, actions} <- compile_action_list(args, line, column),
         {:ok, actions} <- Validator.validate_json(actions),
         {:ok, actions} <- Jason.encode(actions) do
      {:ok, ".functions[#{name}] = #{actions}"}
    end
  end

  defp compile_command("set", name, args, line, column) do
    value = case args do
      [value] -> {:ok, value}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `set` command expects only one value, got #{inspect(args)}"}
    end
    with {:ok, value} <- value,
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value) do
      {:ok, ".[#{name}] = #{value}"}
    end
  end

  defp compile_command("apply", name, args, line, column) do
    path_value = case args do
      [path, value] when is_binary(path) -> {:ok, {path, value}}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `apply` command expects a jq path string and an optional string value, got #{inspect(args)}"}
    end
    with {:ok, {path, value}} <- path_value,
         {:ok, value_val} <- compile_constant(value, line, column),
         {:ok, value} <- Jason.encode(value_val) do
      path = if String.starts_with?(path, ".") do path else "." <> path end
      if Validator.validate_json_path(path) do
        operation = case Jason.decode!(name) do
          "set"                                  -> {:ok, "#{path} = #{value}"}
          "add"                                  -> {:ok, "#{path} += #{value}"}
          "prepend"    when is_list(value_val)   -> {:ok, "#{path} |= #{value} + ."}
          "prepend"                              -> {:ok, "#{path} |= #{Jason.encode!(List.wrap(value_val))} + ."}
          "append"     when is_list(value_val)   -> {:ok, "#{path} += #{value}"}
          "append"                               -> {:ok, "#{path} += #{Jason.encode!(List.wrap(value_val))}"}
          "merge"      when is_map(value_val)    -> {:ok, "#{path} += #{value}"}
          "merge"                                -> {:ok, "#{path} += #{Jason.encode!(Map.new(value_val))}"}
          "subtract"                             -> {:ok, "#{path} -= #{value}"}
          "delete"                               -> {:ok, "#{path} -= #{value}"}
          "multiply"                             -> {:ok, "#{path} *= #{value}"}
          "deep_merge"                           -> {:ok, "#{path} *= #{value}"}
          "divide"     when is_number(value_val) -> {:ok, "#{path} /= #{value}"}
          "modulo"     when is_number(value_val) -> {:ok, "#{path} %= #{value}"}
          "delete_key" when is_binary(value_val) -> {:ok, "#{path} |= del(.[#{value}])"}
          "delete_key" when is_list(value_val)   ->
            if Enum.all?(value_val, &is_binary/1) do
              {:ok, "#{path} |= (reduce #{value}[] as $_k (.; del(.[$_k])))"}
            else
              {:error, "Compiler.compile: at line #{line}:#{column}, `apply delete_key` tried to delete a non-string or non-list-of-strings #{value}"}
            end
          "replace_all" when is_list(value_val)  ->
            case value_val do
              [from, to] -> {:ok, "#{path} |= walk(if . == #{Jason.encode!(from)} then #{Jason.encode!(to)} else . end)"}
              _          -> {:error, "Compiler.compile: at line #{line}:#{column}, `apply replace_all` requires a 2-element list [from, to] as the value"}
            end
          op when op in @binops -> {:ok, "#{path} = #{op}(#{path};#{value})"}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `apply` got invalid method #{name}"}
        end
        with {:ok, operation} <- operation do
          # only perform operation if the path exists
          {:ok, "if (#{path} | type) != \"null\" then #{operation} else . end"}
        end
      else
        {:error, "Compiler.compile: at line #{line}:#{column}, `apply` got invalid path #{path}"}
      end
    end
  end

  defp compile_command("on", name, args, line, column) do
    body = case args do
      [fn_name] when is_binary(fn_name) -> {:ok, [["run", fn_name]]}
      [{fn_name, _pos, nil}] when is_binary(fn_name) -> {:ok, [["run", fn_name]]}
      _ -> compile_action_list(args, line, column)
    end
    with {:ok, body} <- body,
         {:ok, body} <- Validator.validate_json(body),
         {:ok, body} <- Jason.encode(body) do
      {:ok, ".[#{name}].actions += #{body}"}
    end
  end

  defp compile_command("define_set", name, args, line, column) do
    set_spec = case args do
      [{:sigil_s, _, [{:<<>>, _, [set_spec]}, _args]}] when is_binary(set_spec) -> {:ok, set_spec}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_set` command expects a single string value, got #{inspect(args)}"}
    end

    with {:ok, set_spec} <- set_spec,
         {:ok, set_spec} <- Parser.parse_set(set_spec),
         {:ok, set_spec} <- Validator.validate_json(set_spec),
         {:ok, set_spec} <- Jason.encode(set_spec) do
      {:ok, ".set_definitions[#{name}] = #{set_spec}"}
    end
  end

  defp compile_command("define_match", name, args, line, column) do
    match_spec = case args do
      [{:sigil_m, _, [{:<<>>, _, [match_spec]}, _args]}] when is_binary(match_spec) -> {:ok, match_spec}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_match` command expects a single string value, got #{inspect(args)}"}
    end

    with {:ok, match_spec} <- match_spec,
         {:ok, match_spec} <- Parser.parse_match(match_spec),
         {:ok, match_spec} <- Validator.validate_json(match_spec),
         {:ok, match_spec} <- Jason.encode(match_spec) do
      # `name` is already escaped, so we just insert _definition right before the last quote
      name = Utils.insert_at(name, "_definition", -2)
      {:ok, ".[#{name}] = #{match_spec}"}
    end
  end

  defp compile_command("define_const", name, args, line, column) do
    value = case args do
      [value] -> {:ok, value}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_const` command expects a single JSON, condition, action, or do block, got #{inspect(args)}"}
    end

    with {:ok, value} <- value,
         {:ok, value} <- compile_constant(value, line, column),
         {:ok, value} <- Jason.encode(value) do
      {:ok, ".constants[#{name}] = #{value}"}
    end
  end

  defp compile_command("define_yaku", name, args, line, column) do
    yaku_spec = case args do
      [display_name, value, condition] when is_binary(display_name) and (is_number(value) or is_binary(value)) -> {:ok, {display_name, value, condition, []}}
      [display_name, value, condition, supercedes] when is_binary(display_name) and (is_number(value) or is_binary(value)) and is_list(supercedes) -> {:ok, {display_name, value, condition, supercedes}}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_yaku` command expects a yaku list, a display name, a value, and a condition, got #{inspect(args)}"}
    end

    with {:ok, {display_name, value, condition, supercedes}} <- yaku_spec,
         {:ok, display_name} <- Validator.validate_json(display_name),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value),
         {:ok, condition} <- compile_condition_list(condition, line, column),
         {:ok, condition} <- Validator.validate_json(condition),
         {:ok, condition} <- Jason.encode(condition) do
      add_yaku = ".[#{name}] += [{\"display_name\": #{display_name}, \"value\": #{value}, \"when\": #{condition}}]"
      if Enum.empty?(supercedes) do
        {:ok, add_yaku}
      else
        with {:ok, supercedes} <- Validator.validate_json(supercedes),
             {:ok, supercedes} <- Jason.encode(supercedes) do
          {:ok, add_yaku <> "\n| .yaku_precedence[#{display_name}] += #{supercedes}"}
        end
      end
    end
  end

  defp compile_command("define_yaku_precedence", name, args, line, column) do
    yaku = case args do
      [yaku] when is_list(yaku) -> {:ok, yaku}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_yaku_precedence` command expects a list of yaku names or values, got #{inspect(args)}"}
    end

    with {:ok, yaku} <- yaku,
         {:ok, yaku} <- Validator.validate_json(yaku),
         {:ok, yaku} <- Jason.encode(yaku) do
      {:ok, ".yaku_precedence[#{name}] += #{yaku}"}
    end
  end

  defp compile_command("define_button", name, args, line, column) do
    args = case args do
      [args, [do: actions]] -> {:ok, Map.new(args) |> Map.put("actions", actions)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_button` command expects a keyword list followed by a do block, got #{inspect(args)}"}
    end
    field_names = [
      "display_name", "show_when", "actions",
      "precedence_over", "unskippable", "cancellable", "upgrades", "interrupt_level",
      "call", "call_conditions", "call_style"
    ]
    with {:ok, args} <- args,
         {:ok, fields} <- Utils.sequence(for field_name <- field_names do
           field_json = Map.get(args, field_name, nil)
           with {:ok, field_json} <- (cond do
                  field_json == nil -> {:ok, nil}
                  field_name == "actions" -> compile_action_list(field_json, line, column)
                  field_name in ["show_when", "call_conditions"] -> compile_condition_list(field_json, line, column)
                  true -> {:ok, field_json}
                end),
                {:ok, field_val} <- Validator.validate_json(field_json),
                {:ok, field} <- (if field_val != nil do Jason.encode(field_val) else {:ok, nil} end) do
             {:ok, if field != nil do "\"#{field_name}\": #{field}" else nil end}
           end
         end) do
      fields = Enum.reject(fields, &is_nil/1)
      add_button = ~s"""
      .buttons[#{name}] = {
        #{Enum.map_join(fields, ",\n", &"  "<>&1)}
      }
      """
      {:ok, add_button}
    end
  end

  defp compile_command("define_auto_button", name, args, line, column) do
    args = case args do
      [args, [do: actions]] -> {:ok, Map.new(args) |> Map.put("actions", actions)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_auto_button` command expects a keyword list followed by a do block of actions, got #{inspect(args)}"}
    end

    field_names = ["display_name", "desc", "actions", "enabled_at_start"]
    with {:ok, args} <- args,
         {:ok, fields} <- Utils.sequence(for field_name <- field_names do
           field_json = Map.get(args, field_name, nil)
           with {:ok, field_json} <- (cond do
                  field_json == nil -> {:ok, nil}
                  field_name == "actions" -> compile_action_list(field_json, line, column)
                  true -> {:ok, field_json}
                end),
                {:ok, field_val} <- Validator.validate_json(field_json),
                {:ok, field} <- (if field_val != nil do Jason.encode(field_val) else {:ok, nil} end) do
             {:ok, if field != nil do "\"#{field_name}\": #{field}" else nil end}
           end
         end) do
      fields = Enum.reject(fields, &is_nil/1)
      add_button = ~s"""
      .auto_buttons[#{name}] = {
        #{Enum.map_join(fields, ",\n", &"  "<>&1)}
      }
      """
      {:ok, add_button}
    end
  end

  defp compile_command("define_mod_category", name, args, line, column) do
    prepend = case args do
      [] -> {:ok, false}
      [[{"prepend", prepend}]] when is_boolean(prepend) -> {:ok, prepend}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_mod_category` command only takes an optional `prepend: true`, got #{inspect(args)}"}
    end

    with {:ok, prepend} <- prepend do
      if prepend do
        {:ok, ".available_mods |= [#{name}] + ."}
      else
        {:ok, ".available_mods += [#{name}]"}
      end
    end
  end

  defp compile_command("define_mod", name, args, line, column) do
    args = case args do
      [args] -> {:ok, Map.new(args)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_mod` command expects a keyword list, got #{inspect(args)}"}
    end

    with {:ok, args} <- args,
         {:ok, display_name} <- Validator.validate_json(Map.get(args, "name", "Button")),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, desc} <- Validator.validate_json(Map.get(args, "desc", "")),
         {:ok, desc} <- Jason.encode(desc),
         {:ok, order} <- Validator.validate_json(Map.get(args, "order", 0)),
         {:ok, order} <- Jason.encode(order),
         {:ok, category_val} <- Validator.validate_json(Map.get(args, "category", nil)),
         {:ok, category} <- Jason.encode(category_val),
         {:ok, deps} <- Validator.validate_json(Map.get(args, "deps", [])),
         {:ok, deps} <- Jason.encode(deps),
         {:ok, conflicts} <- Validator.validate_json(Map.get(args, "conflicts", [])),
         {:ok, conflicts} <- Jason.encode(conflicts),
         {:ok, default} <- Validator.validate_json(Map.get(args, "default", false)) do
      if category_val != nil do
        {:ok, ~s"""
        (.available_mods | index(#{category})) as $ix1
        |
        (.available_mods[$ix1+1:] | map(type == "string") | index(true)) as $ix2
        |
        ($ix1 + $ix2 + 1) as $ix
        |
        .available_mods |= .[:$ix] + [{
          "id": #{name},
          "name": #{display_name},
          "desc": #{desc},
          "order": #{order},
          "deps": #{deps},
          "conflicts": #{conflicts}
        }] + .[$ix:]
        """}
      else
        {:ok, ~s"""
        .available_mods += [{
          "id": #{name},
          "name": #{display_name},
          "desc": #{desc},
          "default": #{default},
          "order": #{order},
          "deps": #{deps},
          "conflicts": #{conflicts}
        }]
        """}
      end
    end
  end

  defp compile_command("config_mod", name, args, line, column) do
    args = case args do
      [args] -> {:ok, Map.new(args)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `config_mod` command expects a keyword list, got #{inspect(args)}"}
    end

    with {:ok, args} <- args,
         {:ok, type} <- Validator.validate_json(Map.get(args, "type", "dropdown")),
         {:ok, type} <- Jason.encode(type),
         {:ok, display_name} <- Validator.validate_json(Map.get(args, "name", "")),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, values} <- Validator.validate_json(Map.get(args, "values", [])),
         {:ok, values} <- Jason.encode(values),
         {:ok, default_val} <- Validator.validate_json(Map.get(args, "default", nil)),
         {:ok, default} <- Jason.encode(default_val) do
      if default_val != nil do
        {:ok, ~s"""
        .available_mods |= map(if type == "object" and .id == #{name} then
          .config += [{
            "type": #{type},
            "name": #{display_name},
            "values": #{values},
            "default": #{default}
          }]
        else . end)
        """}
      else
        {:ok, ~s"""
        .available_mods |= map(if type == "object" and .id == #{name} then
          .config += [{
            "type": #{type},
            "name": #{display_name},
            "values": #{values}
          }]
        else . end)
        """}
      end
    end
  end

  defp compile_command("define_preset", name, args, line, column) do
    mods = case args do
      [mods] -> {:ok, mods}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_preset` command expects a list of mods, got #{inspect(args)}"}
    end

    with {:ok, mods} <- mods,
         {:ok, mods} <- Validator.validate_json(mods),
         {:ok, mods} <- Jason.encode(mods) do
      {:ok, ~s"""
      .available_presets += [{
        "display_name": #{name},
        "enabled_mods": #{mods}
      }]
      """}
    end
  end

  defp compile_command("remove_yaku", name, args, line, column) do
    names = case args do
      [names] when is_binary(names) -> {:ok, [names]}
      [names] when is_list(names) -> {:ok, names}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `remove_yaku` command expects a name or a list of names, got #{inspect(args)}"}
    end

    with {:ok, names} <- names,
         {:ok, names} <- Validator.validate_json(names),
         {:ok, names} <- Enum.map(names, &Jason.encode/1) |> Utils.sequence() do
      {:ok, ~s"""
      .[#{name}] |= map(select(.display_name | IN(#{Enum.join(names, ",")}) | not))
      """}
    end
  end

  defp compile_command(cmd, _name, _args, line, column) do
    {:error, "Compiler.compile: at line #{line}:#{column}, #{inspect(cmd)} is not a valid toplevel command}"}
  end

  # def compile_jq_toplevel!(ast) do
  #   case compile_jq_toplevel(ast) do
  #     {:ok, jq} -> jq
  #     {:error, error} -> raise error
  #   end
  # end
  defp compile_jq_toplevel(ast) do
    case ast do
      {cmd, [line: line, column: column], [name | args]} when is_binary(cmd) ->
        name = case name do
          name when is_binary(name) -> {:ok, name}
          {name, _pos, _params} -> {:ok, name}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `#{cmd}` command got invalid name #{inspect(name)}"}
        end
        with {:ok, name} <- name,
             {:ok, name} <- Validator.validate_json(name),
             {:ok, name} <- Jason.encode(name) do
          compile_command(cmd, name, args, line, column)
          case args do
            [[do: args]] -> compile_command(cmd, name, args, line, column)
            args when is_list(args) -> compile_command(cmd, name, args, line, column)
            [] -> {:error, "Compiler.compile: at line #{line}:#{column}, `#{cmd}` command expects an argument, got #{inspect(args)}"} 
            _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `#{cmd}` command got invalid arguments #{inspect(args)}"}
          end
        end
      {cmd, [line: line, column: column], args} when is_binary(cmd) ->
        {:error, "Compiler.compile: at line #{line}:#{column}, `#{cmd}` command expects arguments, got #{inspect(args)}"}
      _ -> {:error, "Compiler.compile: expected toplevel command, got #{inspect(ast)}"}
    end
  end

  def compile_jq!(ast) do
    case compile_jq(ast) do
      {:ok, jq} -> jq
      {:error, error} -> raise error
    end
  end

  def compile_jq(ast) do
    case ast do
      {:__block__, _pos, []} -> {:ok, "."}
      {:__block__, _pos, nodes} ->
        # IO.inspect(nodes, label: "AST")
        case Utils.sequence(Enum.map(nodes, &compile_jq_toplevel/1)) do
          {:ok, val}    -> {:ok, Enum.join(val, "\n| ")}
          {:error, msg} -> {:error, msg}
        end
      {_name, _pos, _actions} -> compile_jq({:__block__, [], [ast]})
      _ -> {:error, "Compiler.compile: got invalid root node #{inspect(ast)}"}
    end
  end



  # WIP simple decompiler: json -> majs

  defp decompile_toplevel_key(key, value) do
    with {:ok, key} <- Validator.validate_json(key),
         {:ok, value} <- Jason.encode(value) do
      {:ok, "set #{key}" <> value}
    end
  end

  def decompile_json(json) do
    case Jason.decode(json) do
      {:ok, root} when is_map(root) ->
        for {top_key, value} <- root do
          decompile_toplevel_key(top_key, value)
        end
        |> Utils.sequence()
        |> case do
          {:ok, majs} -> Enum.join(majs, "\n\n")
          {:error, msg} ->
            IO.puts(msg)
            ""
        end
      {:error, msg} ->
        IO.puts(msg)
        ""
    end
  end
end
