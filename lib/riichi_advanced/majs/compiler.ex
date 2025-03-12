defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Validator
  alias RiichiAdvanced.Utils

  def parse(input) when is_binary(input) do
    case byte_size(input) do
      size when size > 4 * 1024 * 1024 ->
        {:error, "script too large (#{size / 1024 / 1024} MB > 4 MB)"}
      _ ->
        case Code.string_to_quoted(input, columns: true, existing_atoms_only: true, static_atoms_encoder: fn name, _pos -> {:ok, if name == "do" do :do else name end} end) do
          {:ok, ast} -> {:ok, ast}
          {:error, err} -> {:error, err}
        end
    end
  end

  defp compile_condition(condition, line, column) do
    condition = case condition do
      condition when is_binary(condition) -> {:ok, {condition, []}}
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
      {"if", [line: line, column: column], [condition, actions]} ->
        with {:ok, condition} <- compile_cnf_condition(condition, line, column),
             {:ok, then_branch} <- compile_action_list(Keyword.get(actions, :do), line, column) do
          else_branch_ast = Keyword.get(actions, :else)
          if else_branch_ast == nil do
            {:ok, [["when", condition, then_branch]]}
          else
            with {:ok, else_branch} <- compile_action_list(else_branch_ast, line, column) do
              {:ok, [["ite", condition, then_branch, else_branch]]}
            end
          end
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
            [args] -> compile_command(cmd, name, List.wrap(args), line, column)
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
          {:ok, val}    -> {:ok, Enum.join(val, "\n|\n")}
          {:error, msg} -> {:error, msg}
        end
      {_name, _pos, _actions} -> compile_jq({:__block__, [], [ast]})
      _ -> {:error, "Compiler.compile: got invalid root node #{inspect(ast)}"}
    end
  end
end
