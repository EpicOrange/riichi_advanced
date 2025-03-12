defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Validator
  alias RiichiAdvanced.Utils

  def parse(input) do
    case Code.string_to_quoted(input, columns: true, existing_atoms_only: true, static_atoms_encoder: fn name, _pos -> {:ok, name} end) do
      {:ok, ast} -> {:ok, ast}
      {:error, err} -> {:error, err}
    end
  end

  defp compile_condition(condition, line, column) do
    case condition do
      name when is_binary(name) -> {:ok, Validator.validate_condition_name(name)}
      {name, [line: line, column: column], opts} when is_binary(name) ->
        if Validator.validate_condition_name(name) do
          with {:ok, validated_opts} <- Validator.validate_json(opts) do
            {:ok, %{"name" => name, "opts" => validated_opts}}
          end
        else
          {:error, "Compiler.compile_cnf_condition: at line #{line}:#{column}, \"#{name}\" is not a valid condition"}
        end
      _ -> {:error, "Compiler.compile_cnf_condition: at line #{line}:#{column}, expected a condition, got #{inspect(condition)}"}
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
      {name, [line: line, column: column], args} when is_binary(name) ->
        if name in Validator.allowed_actions() do
          case Utils.sequence(Enum.map(args, &Validator.validate_json/1)) do
            {:ok, args}   -> {:ok, [name | args]}
            {:error, msg} -> {:error, msg}
          end
        else
          {:error, "Compiler.compile_action: at line #{line}:#{column}, \"#{name}\" is not a valid action"}
        end
      _ -> {:error, "Compiler.compile_action: at line #{line}:#{column}, expected an action, got #{inspect(action)}"}
    end
  end

  defp compile_action_list!(action, line, column) do
    case compile_action_list(action, line, column) do
      {:ok, json} -> json
      {:error, error} -> raise error
    end
  end
  defp compile_action_list(ast, line, column) do
    case ast do
      {:__block__, _pos, actions} ->
        case Utils.sequence(Enum.map(actions, &compile_action(&1, line, column))) do
          {:ok, exprs} -> {:ok, exprs}
          {:error, message} -> {:error, message}
        end
      {"if", [line: line, column: column], [condition, actions]} ->
        case compile_cnf_condition(condition, line, column) do
          {:ok, condition} ->
            case compile_action_list(Keyword.get(actions, :do), line, column) do
              {:ok, then_branch} ->
                else_branch_ast = Keyword.get(actions, :else)
                if else_branch_ast == nil do
                  {:ok, [["when", condition, then_branch]]}
                else
                  case compile_action_list(else_branch_ast, line, column) do
                    {:ok, else_branch} -> {:ok, [["ite", condition, then_branch, else_branch]]}
                    {:error, message} -> {:error, message}
                  end
                end
              {:error, message} -> {:error, message}
            end
          {:error, message} -> {:error, message}
        end
      {_name, _pos, _actions} -> compile_action_list({:__block__, [], [ast]}, line, column)
      _ -> {:error, "Compiler.compile_action_list: at line #{line}:#{column}, expected an action list, got #{inspect(ast)}"}
    end
  end

  def compile_jq_toplevel!(ast) do
    case compile_jq_toplevel(ast) do
      {:ok, jq} -> jq
      {:error, error} -> raise error
    end
  end
  defp compile_jq_toplevel(ast) do
    case ast do
      {"def", [line: line, column: column], nodes} ->
        case nodes do
          [{name, [line: line, column: column], _params}, body] when is_binary(name) ->
            case body do
              [do: nodes] ->
                case compile_action_list(nodes, line, column) do
                  {:ok, actions} -> {:ok, ".functions[\"#{name}\"] = #{Jason.encode!(actions)}"}
                  {:error, msg}  -> {:error, msg}
                end
              {_name, _pos, _actions} -> {:ok, ".functions[\"#{name}\"] = #{compile_action_list!(body, line, column) |> Jason.encode!()}"}
              _ -> {:error, "Compiler.compile: at line #{line}:#{column}, def expects a \"do\" block after name, got #{inspect(body)}"}
            end
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, def got invalid name #{inspect(nodes && Enum.at(nodes, 0))}"}
        end
      {"set", [line: line, column: column], nodes} ->
        args = case nodes do
          [{key, _pos, nil}, value] when is_binary(key) -> {:ok, [key, value]}
          [key, value] when is_binary(key) -> {:ok, [key, value]}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, set got invalid key #{inspect(nodes && Enum.at(nodes, 0))}"}
        end
        with {:ok, [key, value]} <- args,
             {:ok, key} <- Validator.validate_json(key),
             {:ok, key} <- Jason.encode(key),
             {:ok, value} <- Validator.validate_json(value),
             {:ok, value} <- Jason.encode(value) do
          {:ok, ".[#{key}] = #{value}"}
        end
      {"on", [line: line, column: column], nodes} ->
        args = case nodes do
          [{event, _pos, nil}, body] when is_binary(event) -> {:ok, [event, body]}
          [event, body] when is_binary(event) -> {:ok, [event, body]}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, on got invalid event #{inspect(nodes && Enum.at(nodes, 0))}"}
        end
        with {:ok, [event, body]} <- args,
             {:ok, event} <- Validator.validate_json(event),
             {:ok, event} <- Jason.encode(event) do
          body = case body do
            name when is_binary(name) -> with {:ok, name} <- Validator.validate_json(name), do: {:ok, [["run", name]]}
            {name, _pos, nil} -> with {:ok, name} <- Validator.validate_json(name), do: {:ok, [["run", name]]}
            [do: actions] -> compile_action_list(actions, line, column)
            {_name, _pos, _actions} -> compile_action_list(body, line, column)
            _ -> {:error, "Compiler.compile: at line #{line}:#{column}, on expects a function name or a do block, got #{inspect(body)}"}
          end
          with {:ok, body} <- body,
               {:ok, body} <- Validator.validate_json(body),
               {:ok, body} <- Jason.encode(body) do
            {:ok, ".[#{event}].actions += #{body}"}
          end
        end
      _ -> {:error, "Compiler.compile: got invalid toplevel command #{inspect(ast)}"}
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
          {:ok, val}    -> {:ok, Enum.join(val, "\n|\n")}
          {:error, msg} -> {:error, msg}
        end
      {_name, _pos, _actions} -> compile_jq({:__block__, [], [ast]})
      _ -> {:error, "Compiler.compile: got invalid root node #{inspect(ast)}"}
    end
  end
end
