defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Parser
  alias RiichiAdvanced.Utils
  alias RiichiAdvanced.Validator

  @binops ["atan2", "copysign", "drem", "fdim", "fmax", "fmin", "fmod", "frexp", "hypot", "jn", "ldexp", "modf", "nextafter", "nexttoward", "pow", "remainder", "scalb", "scalbln", "yn"]

  defp compile_condition(condition, line, column) do
    condition = case condition do
      false -> {:ok, {"false", []}}
      true -> {:ok, {"true", []}}
      condition when is_binary(condition) -> {:ok, {condition, []}}
      {condition, _pos, nil} when is_binary(condition) -> {:ok, {condition, []}}
      {condition, _pos, opts} when is_binary(condition) -> {:ok, {condition, opts}}
      %{"name" => condition, "opts" => opts} -> {:ok, {condition, opts}}
      {:%{}, [line: line, column: column], map} -> compile_condition(Map.new(map), line, column)
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

  # defp compile_action!(action, line, column) do
  #   case compile_action(action, line, column) do
  #     {:ok, json} -> json
  #     {:error, error} -> raise error
  #   end
  # end
  defp compile_action(action, line, column) do
    case action do
      {"if", [line: line, column: column], opts} ->
        case opts do
          [condition, actions] ->
            with {:ok, condition} <- compile_cnf_condition(condition, line, column),
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
              {[do: actions], _i} -> compile_action_list(actions, line, column)
              {arg, i} when name == "add" and i == 1 ->
                with {:ok, condition} <- compile_cnf_condition(arg, line, column) do
                  {:ok, [condition]}
                end
              {arg, _i} -> {:ok, [arg]}
            end)
            |> Utils.sequence()
            with {:ok, args} <- args,
                 {:ok, args} <- args |> Enum.concat() |> Enum.map(&Validator.validate_json/1) |> Utils.sequence() do
              {:ok, [name | args]}
            end
          else
            {:ok, [name]}
          end
        else
          # convert into a function call
          with {:ok, name} <- Validator.validate_json(name) do
            {:ok, ["run", name]}
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
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value) do
      path = if String.starts_with?(path, ".") do path else "." <> path end
      if Validator.validate_json_path(path) do
        case Jason.decode!(name) do
          "set"      -> {:ok, "#{path} = #{value}"}
          "add"      -> {:ok, "#{path} += #{value}"}
          "prepend"  -> {:ok, "#{path} |= #{value} + ."}
          "append"   -> {:ok, "#{path} += #{value}"}
          "subtract" -> {:ok, "#{path} -= #{value}"}
          "multiply" -> {:ok, "#{path} *= #{value}"}
          "merge"    -> {:ok, "#{path} *= #{value}"}
          "divide"   -> {:ok, "#{path} /= #{value}"}
          "modulo"   -> {:ok, "#{path} %= #{value}"}
          op when op in @binops -> {:ok, "#{path} = #{op}(#{path};#{value})"}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `apply` got invalid method #{name}"}
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
         {:ok, condition} <- compile_cnf_condition(condition, line, column),
         {:ok, condition} <- Validator.validate_json(List.wrap(condition)),
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
      [args, [do: actions]] -> {:ok, Map.new(args) |> Map.put(:actions, actions)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_button` command expects a keyword list followed by a do block, got #{inspect(args)}"}
    end

    with {:ok, args} <- args,
         {:ok, display_name} <- Validator.validate_json(Map.get(args, "display_name", "Button")),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, show_when} <- compile_cnf_condition(Map.get(args, "show_when", "false"), line, column),
         {:ok, show_when} <- Validator.validate_json(List.wrap(show_when)),
         {:ok, show_when} <- Jason.encode(show_when),
         {:ok, actions} <- compile_action_list(args.actions, line, column),
         {:ok, actions} <- Validator.validate_json(actions),
         {:ok, actions} <- Jason.encode(actions),
         {:ok, precedence_over} <- Validator.validate_json(Map.get(args, "precedence_over", [])),
         {:ok, precedence_over} <- Jason.encode(precedence_over),
         {:ok, unskippable} <- Validator.validate_json(Map.get(args, "unskippable", false)),
         {:ok, unskippable} <- Jason.encode(unskippable),
         {:ok, cancellable} <- Validator.validate_json(Map.get(args, "cancellable", false)),
         {:ok, cancellable} <- Jason.encode(cancellable),
         {:ok, interrupt_level} <- Validator.validate_json(Map.get(args, "interrupt_level", 100)),
         {:ok, interrupt_level} <- Jason.encode(interrupt_level) do
      add_button = ~s"""
      .buttons[#{name}] = {
        "display_name": #{display_name},
        "show_when": #{show_when},
        "actions": #{actions},
        "precedence_over": #{precedence_over},
        "unskippable": #{unskippable},
        "cancellable": #{cancellable},
        "interrupt_level": #{interrupt_level}
      }
      """
      if Enum.empty?(Map.get(args, "call", [])) do
        {:ok, add_button}
      else
        with {:ok, call} <- Validator.validate_json(Map.get(args, "call", [])),
             {:ok, call} <- Jason.encode(call),
             {:ok, call_conditions} <- compile_cnf_condition(Map.get(args, "call_conditions", "true"), line, column),
             {:ok, call_conditions} <- Validator.validate_json(List.wrap(call_conditions)),
             {:ok, call_conditions} <- Jason.encode(call_conditions),
             {:ok, call_style} <- Validator.validate_json(Map.get(args, "call_style", [])),
             {:ok, call_style} <- Jason.encode(call_style) do

          add_call_button = ~s"""
          .buttons[#{name}] += {
            "call": #{call},
            "call_conditions": #{call_conditions},
            "call_style": #{call_style}
          }
          """
          {:ok, add_button <> "\n| " <> add_call_button}
        end
      end
    end
  end

  defp compile_command("define_auto_button", name, args, line, column) do
    args = case args do
      [args, [do: actions]] -> {:ok, Map.new(args) |> Map.put(:actions, actions)}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_auto_button` command expects a keyword list followed by a do block of actions, got #{inspect(args)}"}
    end

    with {:ok, args} <- args,
         {:ok, display_name} <- Validator.validate_json(Map.get(args, "display_name", "A")),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, desc} <- Validator.validate_json(Map.get(args, "desc", "")),
         {:ok, desc} <- Jason.encode(desc),
         {:ok, actions} <- compile_action_list(args.actions, line, column),
         {:ok, actions} <- Validator.validate_json(actions),
         {:ok, actions} <- Jason.encode(actions),
         {:ok, enabled_at_start} <- Validator.validate_json(Map.get(args, "enabled_at_start", false)),
         {:ok, enabled_at_start} <- Jason.encode(enabled_at_start) do
      add_button = ~s"""
      .auto_buttons[#{name}] = {
        "display_name": #{display_name},
        "desc": #{desc},
        "actions": #{actions},
        "enabled_at_start": #{enabled_at_start}
      }
      """
      {:ok, add_button}
    end
  end

  defp compile_command("define_mod_category", name, args, line, column) do
    prepend = case args do
      [] -> {:ok, false}
      [args] ->
        prepend = Map.get(args, "prepend")
        prepend = if is_boolean(prepend) do prepend else false end
        {:ok, prepend}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_mod_category` command expects a keyword list, got #{inspect(args)}"}
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
      {:ok, jq} -> jq |> IO.inspect()
      {:error, error} -> raise error
    end
  end

  def compile_jq(ast) do
    case ast do
      {:__block__, [], nodes} -> 
        # IO.inspect(nodes, label: "AST")
        case Utils.sequence(Enum.map(nodes, &compile_jq_toplevel/1)) do
          {:ok, val}    -> {:ok, Enum.join(val, "\n| ")}
          {:error, msg} -> {:error, msg}
        end
      {_name, _pos, _actions} -> compile_jq({:__block__, [], [ast]})
      _ -> {:error, "Compiler.compile: got invalid root node #{inspect(ast)}"}
    end
  end
end
