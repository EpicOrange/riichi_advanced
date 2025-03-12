defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Parser
  alias RiichiAdvanced.Utils
  alias RiichiAdvanced.Validator

  defp compile_condition(condition, line, column) do
    condition = case condition do
      condition when is_binary(condition) -> {:ok, {condition, []}}
      {condition, _pos, nil} when is_binary(condition) -> {:ok, {condition, []}}
      {condition, _pos, opts} when is_binary(condition) -> {:ok, {condition, opts}}
      _ -> {:error, "Compiler.compile_cnf_condition: at line #{line}:#{column}, `if` expects a condition, got #{inspect(condition)}"}
    end
    with {:ok, {condition, opts}} <- condition,
         {:ok, opts} <- Validator.validate_json(opts) do
      if Validator.validate_condition_name(condition) do
        if Enum.empty?(opts) do
          {:ok, condition}
        else
          {:ok, %{"name" => condition, "opts" => opts}}
        end
      else
        {:error, "Compiler.compile_cnf_condition: at line #{line}:#{column}, #{inspect(condition)} is not a valid condition"}
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
          {:ok, compiled_args |> Enum.map(&List.wrap/1) |> Enum.concat()}
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
            with {:ok, seats_spec} <- IO.inspect(seats_spec),
                 {:ok, actions} <- compile_action_list(Keyword.get(actions, :do), line, column) do
              {:ok, ["as", seats_spec, actions]}
            end
          _ -> {:error, "\"as\" got invalid parameters: #{inspect(opts)}"}
        end
      {name, [line: line, column: column], args} when is_binary(name) ->
        if name in Validator.allowed_actions() do
          case Utils.sequence(Enum.map(args, &Validator.validate_json/1)) do
            {:ok, args}   -> {:ok, [name | args]}
            {:error, msg} -> {:error, msg}
          end
        else
          {:error, "Compiler.compile_action: at line #{line}:#{column}, #{inspect(name)} is not a valid action"}
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
      [set_spec] when is_binary(set_spec) -> Parser.parse_set(set_spec)
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_set` command expects a single string value, got #{inspect(args)}"}
    end

    with {:ok, set_spec} <- set_spec,
         {:ok, set_spec} <- Validator.validate_json(set_spec),
         {:ok, set_spec} <- Jason.encode(set_spec) do
      {:ok, ".set_definitions[#{name}] = #{set_spec}"}
    end
  end

  defp compile_command("define_match", name, args, line, column) do
    match_spec = case args do
      [match_spec] when is_binary(match_spec) -> Parser.parse_match(match_spec)
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_match` command expects a single string value, got #{inspect(args)}"}
    end

    with {:ok, match_spec} <- match_spec,
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
