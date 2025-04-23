defmodule RiichiAdvanced.Compiler.Constant do
  defstruct [
    name: "constant"
  ]
end

defimpl Jason.Encoder, for: RiichiAdvanced.Compiler.Constant do
  def encode(%RiichiAdvanced.Compiler.Constant{name: name}, opts) do
    Jason.Encode.string("@" <> name, opts)
  end
end

defmodule RiichiAdvanced.Compiler.Variable do
  defstruct [
    name: "variable"
  ]
end

defimpl Jason.Encoder, for: RiichiAdvanced.Compiler.Variable do
  def encode(%RiichiAdvanced.Compiler.Variable{name: name}, _opts) do
    "$" <> name
  end
end

defmodule RiichiAdvanced.Compiler.Expression do
  defstruct [
    op: :+,
    l: nil,
    r: nil
  ]
end

defimpl Jason.Encoder, for: RiichiAdvanced.Compiler.Expression do
  # runtime check that variables in expressions are numbers
  def encode_operand(%RiichiAdvanced.Compiler.Variable{} = var, opts) do
    json = Jason.Encode.value(var, opts) |> IO.iodata_to_binary()
    ["(if ", json, " | type == \"number\" then ", json, " else error(\"variable ", json, " in expression is not a number\") end)"]
  end
  def encode_operand(operand, opts), do: Jason.Encode.value(operand, opts)
  def encode(%RiichiAdvanced.Compiler.Expression{op: op, l: l, r: r}, opts) do
    ["("] ++ List.wrap(encode_operand(l, opts)) ++ [Atom.to_string(op)] ++ List.wrap(encode_operand(r, opts)) ++ [")"]
  end
end

defmodule RiichiAdvanced.Compiler do
  alias RiichiAdvanced.Compiler.Constant
  alias RiichiAdvanced.Compiler.Variable
  alias RiichiAdvanced.Parser
  alias RiichiAdvanced.Utils
  alias RiichiAdvanced.Validator

  @binops ["atan2", "copysign", "drem", "fdim", "fmax", "fmin", "fmod", "frexp", "hypot", "jn", "ldexp", "modf", "nextafter", "nexttoward", "pow", "remainder", "scalb", "scalbln", "yn"]

  defp compile_condition(condition, line, column) do
    case condition do
      {:==, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"counter_equals", pos, [l, r]}, line, column)
      {:==, pos, [{l, _, nil}, r]} -> compile_condition({"counter_equals", pos, [l, r]}, line, column)
      {:!=, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"not_counter_equals", pos, [l, r]}, line, column)
      {:!=, pos, [{l, _, nil}, r]} -> compile_condition({"not_counter_equals", pos, [l, r]}, line, column)
      {:<=, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"counter_at_most", pos, [l, r]}, line, column)
      {:<=, pos, [{l, _, nil}, r]} -> compile_condition({"counter_at_most", pos, [l, r]}, line, column)
      {:>=, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"counter_at_least", pos, [l, r]}, line, column)
      {:>=, pos, [{l, _, nil}, r]} -> compile_condition({"counter_at_least", pos, [l, r]}, line, column)
      {:<, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"counter_less_than", pos, [l, r]}, line, column)
      {:<, pos, [{l, _, nil}, r]} -> compile_condition({"counter_less_than", pos, [l, r]}, line, column)
      {:>, pos, [{l, _, nil}, {r, _, nil}]} -> compile_condition({"counter_more_than", pos, [l, r]}, line, column)
      {:>, pos, [{l, _, nil}, r]} -> compile_condition({"counter_more_than", pos, [l, r]}, line, column)
      {:not, _, [condition]} ->
        with {:ok, result} <- compile_cnf_condition(condition, line, column) do
          {:ok, %{"name" => "not", "opts" => [result]}}
        end
      {:+, _, _} -> Validator.validate_json(condition)
      {:@, _, _} -> Validator.validate_json(condition)
      # since conditions are checked first in compile_constant/3, 
      # the below case will catch all variables that aren't in expressions,
      # whose type we don't know at compile time
      # so just return it as is, even though we're supposed to return booleans
      {:!, _, _} -> Validator.validate_json(condition)
      _ ->
        condition = case condition do
          false -> {:ok, {"false", []}}
          true -> {:ok, {"true", []}}
          condition when is_binary(condition) -> {:ok, {condition, []}}
          {condition, _, nil} when is_binary(condition) -> {:ok, {condition, []}}
          {condition, _, opts} when is_binary(condition) -> {:ok, {condition, opts}}
          %{"name" => condition, "opts" => opts} -> {:ok, {condition, opts}}
          condition ->
            case condition do
              {:ok, %Constant{} = condition} -> {:ok, {condition, []}}
              {:ok, %Variable{} = condition} -> {:ok, {condition, []}}
              _ -> {:error, "Compiler.compile_condition: at line #{line}:#{column}, expecting a condition, got #{inspect(condition)}"}
            end
        end
        with {:ok, {condition, opts}} <- condition,
             {:ok, opts} <- Parser.parse_sigils(opts),
             {:ok, opts} <- Validator.validate_json(opts) do
          if Validator.validate_condition_name(condition) do
            if Enum.empty?(opts) do
              {:ok, condition}
            else
              case Enum.at(opts, -1) do
                %{"as" => seats} -> {:ok, %{"name" => condition, "as" => seats, "opts" => Enum.drop(opts, -1)}}
                _                -> {:ok, %{"name" => condition, "opts" => opts}}
              end
            end
          else
            # IO.puts("Tried to compile invalid condition #{inspect(condition)}")
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
      case condition do
        %Constant{} -> {:ok, condition}
        %Variable{} -> {:ok, condition}
        _           -> {:ok, List.wrap(condition)}
      end
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
      {:=, pos, [{l, _, nil}, {:+, _, [{l, _, nil}, {r, _, nil}]}]} -> compile_action({"add_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:-, _, [{l, _, nil}, {r, _, nil}]}]} -> compile_action({"subtract_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:*, _, [{l, _, nil}, {r, _, nil}]}]} -> compile_action({"multiply_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:/, _, [{l, _, nil}, {r, _, nil}]}]} -> compile_action({"divide_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:+, _, [{l, _, nil}, r]}]} -> compile_action({"add_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:-, _, [{l, _, nil}, r]}]} -> compile_action({"subtract_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:*, _, [{l, _, nil}, r]}]} -> compile_action({"multiply_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {:/, _, [{l, _, nil}, r]}]} -> compile_action({"divide_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, {r, _, nil}]} -> compile_action({"set_counter", pos, [l, r]}, line, column)
      {:=, pos, [{l, _, nil}, r]} -> compile_action({"set_counter", pos, [l, r]}, line, column)
      {"if", [line: line, column: column], opts} ->
        case opts do
          [condition, actions] ->
            with {:ok, condition} <- compile_condition_list(condition, line, column),
                 {:ok, then_branch} <- compile_action_list(Keyword.get(actions, :do), line, column) do
              case Keyword.get(actions, :else) do
                nil -> {:ok, ["when", condition, then_branch]}
                else_branch_ast ->
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
            with {:ok, args} <- Enum.map(args, &compile_constant(&1, line, column)) |> Utils.sequence() do
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
              [args] -> {:ok, ["run", name, args]}
              _      -> {:ok, ["run", name]}
            end
          end
        end
      action ->
        case action do
          {:ok, %Constant{} = action} -> {:ok, action}
          {:ok, %Variable{} = action} -> {:ok, action}
          _ -> {:error, "Compiler.compile_action: at line #{line}:#{column}, expected an action or a if block, got #{inspect(action)}"}
        end
    end
  end

  defp compile_action_list(ast, line, column) do
    case ast do
      {:__block__, [], actions} -> compile_action_list(actions, line, column)
      {_name, [line: line, column: column], _actions} -> compile_action_list([ast], line, column)
      actions when is_list(actions) ->
        case Keyword.get(actions, :do) do
          nil -> Utils.sequence(Enum.map(actions, &compile_action(&1, line, column)))
          ast -> compile_action_list(ast, line, column)
        end
      _ -> {:error, "Compiler.compile_action_list: at line #{line}:#{column}, expected an action list, got #{inspect(ast)}"}
    end
  end

  defp compile_constant(true, _line, _column), do: {:ok, true}
  defp compile_constant(false, _line, _column), do: {:ok, false}
  # if it's a do block, use compile_action_list
  defp compile_constant([do: actions], line, column), do: compile_action_list(actions, line, column)
  defp compile_constant(value, line, column) do
    # otherwise, try a bunch of things
    # this order is important: 
    # validate_json will treat actions/conditions as raw JSON
    # compile_cnf_condition defaults to a single condition
    with {:ok, value} <- Parser.parse_sigils(value),
         {:error, _} <- Validator.validate_expression(value),
         {:error, _} <- Validator.validate_json(value),
         {:error, _} <- compile_cnf_condition(value, line, column),
         {:error, _} <- compile_action(value, line, column) do
      {:error, "Compiler.compile_constant: at line #{line}:#{column}, expected JSON, condition, action, or do block, got #{inspect(value)}"}
    end
  end

  # TODO deprecate
  defp compile_command("var", name, args, line, column) do
    value = case args do
      [value] -> {:ok, value}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `var` command expects only one value, got #{inspect(args)}"}
    end
    with {:ok, value} <- value,
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value) do
      {:ok, ".[#{name}] = #{value}"}
    end
  end

  defp compile_command("def", name, args, line, column) do
    with {:ok, actions} <- compile_action_list(args, line, column),
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
         {:ok, value} <- Parser.parse_sigils(value),
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
         {:ok, path} <- Validator.validate_json_path(path),
         {:ok, value_val} <- compile_constant(value, line, column),
         {:ok, value} <- Jason.encode(value_val) do
      op = Jason.decode!(name)
      default_to_set = String.starts_with?(op, "set_")
      op = if default_to_set do String.replace_leading(op, "set_", "") else op end
      operation = case op do
        "set"                                  -> {:ok, "#{path} = #{value}"}
        "initialize"                           -> {:ok, "#{path} = #{value}"}
        "add"                                  -> {:ok, "#{path} += #{value}"}
        "prepend"                              -> {:ok, "#{path} |= _safe_append(#{value}; .)"}
        "append"                               -> {:ok, "#{path} |= _safe_append(.; #{value})"}
        "merge"      when is_map(value_val)    -> {:ok, "#{path} += #{value}"}
        "merge"                                -> {:error, "tried to merge a non-map value #{inspect(value_val)}"}
        "subtract"                             -> {:ok, "#{path} -= #{value}"}
        "delete"     when is_list(value_val)   -> {:ok, "#{path} |= map(select(#{value} | index(.) | not))"}
        "delete"                               -> {:ok, "#{path} |= map(select(. != #{value}))"}
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
        op when op in @binops -> {:ok, "#{path} = #{op}(#{path};#{value})"}
        _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `apply` got invalid method #{name}"}
      end
      with {:ok, operation} <- operation do
        if op == "set" do
          {:ok, operation}
        else
          # only perform operation if the parent path exists
          otherwise = if default_to_set do "#{path} = #{value}" else "." end
          with {:ok, parent_path} <- Validator.get_parent_path(path) do
            ret = "if (#{parent_path}? != null) then (#{operation}) else #{otherwise} end"
            # IO.puts(ret)
            {:ok, ret}
          end
        end
      end
    end
  end

  defp compile_command("replace", name, args, line, column) do
    path_value1_value2 = case args do
      [path, value1, value2] when is_binary(path) -> {:ok, {path, value1, value2}}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `replace` command expects either \"all\" or an integer, followed by a jq path string and two values, `to_replace` and `replacement`, instead got #{inspect(args)}"}
    end
    with {:ok, {path, value1, value2}} <- path_value1_value2,
         {:ok, path} <- Validator.validate_json_path(path),
         {:ok, value1_val} <- compile_constant(value1, line, column),
         {:ok, value1} <- Jason.encode(value1_val),
         {:ok, value2_val} <- compile_constant(value2, line, column),
         {:ok, value2} <- Jason.encode(value2_val) do
      operation = case Jason.decode(name) do
        {:ok, "all"} -> {:ok, "walk(if . == #{value1} then #{value2} else . end)"}
        {:ok, n} when is_integer(n) -> {:ok, "reduce limit(#{n}; paths(. == #{value1})) as $_path (.; setpath($_path; #{value2}))"}
        {:error, _} -> case name do
          <<"$" <> _>> = var -> {:ok, "if (#{var} | type == \"number\") then reduce limit(#{var}; paths(. == #{value1})) as $_path (.; setpath($_path; #{value2})) else . end"}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `replace` got invalid method #{name}"}
        end
      end
      with {:ok, operation} <- operation do
        # only perform operation if the path exists
        {:ok, "#{path} |= if type != \"null\" then #{operation} else . end"}
      end
    end
  end

  defp compile_command("on", name, args, line, column) do
    {prepend, args} = case args do
      [[{"prepend", prepend}], args] -> {prepend, args}
      [[{"prepend", prepend}] | args] -> {prepend, args}
      _ -> {false, args}
    end
    body = case args do
      [fn_name] when is_binary(fn_name) -> {:ok, [["run", Validator.sanitize_string(fn_name)]]}
      [{fn_name, _pos, nil}] when is_binary(fn_name) -> {:ok, [["run", Validator.sanitize_string(fn_name)]]}
      _ -> compile_action_list(args, line, column)
    end
    with {:ok, body} <- body,
         {:ok, body} <- Jason.encode(body) do
      if prepend do
        {:ok, ".[#{name}].actions |= #{body} + ."}
      else
        {:ok, ".[#{name}].actions += #{body}"}
      end
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

  defp compile_command("define_match", name, args, _line, _column) do
    match_specs = case args do
      # single args
      [{prefix, _, _} = arg] when prefix == :+ or prefix == :@ or prefix == :! ->
        # constant or variable
        with {:ok, match_spec} <- Validator.validate_json(arg),
             {:ok, match_spec} <- Jason.encode(match_spec) do
          {:ok, "#{match_spec}"}
        end
      _ ->
        # multiple args
        match_specs = Enum.map(args, fn
          {:sigil_m, _, [{:<<>>, _, [match_spec]}, _args]} ->
            # standard match definition
            with {:ok, match_spec} <- Parser.parse_match(match_spec),
                 {:ok, match_spec} <- Validator.validate_json(match_spec),
                 {:ok, match_spec} <- Jason.encode(match_spec) do
              {:ok, "#{match_spec}"}
            end
          {:sigil_a, _, [{:<<>>, _, [match_spec]}, _args]} ->
            # american match definition
            with {:ok, match_spec} <- Validator.validate_json(match_spec),
                 {:ok, match_spec} <- Jason.encode(match_spec) do
              {:ok, "[#{match_spec}]"}
            end
          match_spec when is_binary(match_spec) ->
            # existing match definition
            with {:ok, match_spec} <- Validator.validate_json(match_spec) do
              {:ok, ".#{match_spec}_definition"}
            end
        end)
        |> Utils.sequence()
        with {:ok, match_specs} <- match_specs do
          {:ok, Enum.join(match_specs, " + ")}
        end
    end
    with {:ok, match_specs} <- match_specs do
      # `name` is already escaped, so we just insert _definition right before the last quote
      name = Utils.insert_at(name, "_definition", -2)
      # IO.puts(".[#{name}] = #{match_specs}")
      {:ok, ".[#{name}] = #{match_specs}"}
    end
  end

  defp compile_command("extend_match", name, args, line, column) do
    match_spec = case args do
      [{:sigil_m, _, [{:<<>>, _, [match_spec]}, _args]}] when is_binary(match_spec) -> {:ok, match_spec}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `extend_match` command expects a single string value, got #{inspect(args)}"}
    end

    with {:ok, match_spec} <- match_spec,
         {:ok, match_spec} <- Parser.parse_match(match_spec),
         {:ok, match_spec} <- Validator.validate_json(match_spec),
         {:ok, match_spec} <- Jason.encode(match_spec) do
      # `name` is already escaped, so we just insert _definition right before the last quote
      name = Utils.insert_at(name, "_definition", -2)
      {:ok, ".[#{name}] += #{match_spec}"}
    end
  end

  defp compile_command("define_const", name, args, line, column) do
    value = case args do
      [value] -> {:ok, value}
      {_, _, _} -> {:ok, args}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_const` command expects a single JSON, condition, action, or do block, got #{inspect(args)}"}
    end
    with {:ok, value} <- value do
      case value do
        {:@, _, _} -> 
          # copy an existing constant
          with {:ok, %Constant{name: const_name}} <- Validator.validate_json(value),
               {:ok, const_name} <- Jason.encode(const_name) do
            {:ok, ".constants[#{name}] = .constants[#{const_name}]"}
          end
        _ ->
          # set a constant
          with {:ok, value} <- compile_constant(value, line, column),
               {:ok, value} <- Jason.encode(value) do
            {:ok, ".constants[#{name}] = #{value}"}
          end
      end
    end
  end

  defp compile_command("define_yaku", name, args, line, column) do
    yaku_spec = case args do
      [display_name, value, condition] -> {:ok, {display_name, value, condition, []}}
      [display_name, value, condition, supercedes] when is_list(supercedes) -> {:ok, {display_name, value, condition, supercedes}}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define_yaku` command expects a yaku list name, a display name, a value, and a condition, got #{inspect(args)}"}
    end

    with {:ok, {display_name, value, condition, supercedes}} <- yaku_spec,
         {:ok, display_name} <- Validator.validate_json(display_name),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value),
         {:ok, condition} <- compile_condition_list(condition, line, column),
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

  defp compile_command("replace_yaku", name, args, line, column) do
    yaku_spec = case args do
      [display_name, value, condition] when is_binary(display_name) and (is_number(value) or is_binary(value)) -> {:ok, {display_name, value, condition, []}}
      [display_name, value, condition, supercedes] when is_binary(display_name) and (is_number(value) or is_binary(value)) and is_list(supercedes) -> {:ok, {display_name, value, condition, supercedes}}
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `replace_yaku` command expects a yaku list name, a display name, a value, and a condition, got #{inspect(args)}"}
    end

    with {:ok, {display_name, value, condition, supercedes}} <- yaku_spec,
         {:ok, display_name} <- Validator.validate_json(display_name),
         {:ok, display_name} <- Jason.encode(display_name),
         {:ok, value} <- Validator.validate_json(value),
         {:ok, value} <- Jason.encode(value),
         {:ok, condition} <- compile_condition_list(condition, line, column),
         {:ok, condition} <- Jason.encode(condition) do
      add_yaku = """
        if .[#{name}] | any(.display_name == #{display_name}) then
          .[#{name}] |= map(select(.display_name != #{display_name})) + [{\"display_name\": #{display_name}, \"value\": #{value}, \"when\": #{condition}}]
        else . end
      """
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
      "call", "call_conditions", "call_style",
      "call_name", "msg_name"
    ]
    with {:ok, args} <- args,
         {:ok, fields} <- Utils.sequence(for field_name <- field_names do
           case Map.get(args, field_name, nil) do
             nil -> {:ok, nil}
             field_json ->
               with {:ok, field_val} <- (cond do
                      field_name == "actions" -> compile_action_list(field_json, line, column)
                      field_name in ["show_when", "call_conditions"] -> compile_condition_list(field_json, line, column)
                      true -> Validator.validate_json(field_json)
                    end),
                    {:ok, field} <- (if field_val != nil do Jason.encode(field_val) else {:ok, nil} end) do
                 {:ok, if field != nil do "\"#{field_name}\": #{field}" else nil end}
               end |> add_error_cxt("while at line #{line}:#{column} compiling field #{to_string(field_name)} for button #{to_string(name)}")
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
           with {:ok, field_val} <- (cond do
                  field_json == nil -> {:ok, nil}
                  field_name == "actions" -> compile_action_list(field_json, line, column)
                  true -> Validator.validate_json(field_json)
                end),
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
        {:ok, "if ((.available_mods // []) | index(#{name}) | not) then .available_mods |= [#{name}] + . else . end"}
      else
        {:ok, "if ((.available_mods // []) | index(#{name}) | not) then .available_mods += [#{name}] else . end"}
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

  defp compile_command("remove_mod", name, args, line, column) do
    names = if is_list(args) and Enum.all?(args, &is_binary/1) do
      {:ok, [Jason.decode!(name) | List.wrap(args)]}
    else
      {:error, "Compiler.compile: at line #{line}:#{column}, `remove_mod` command expects a mod id or a list of mod ids, got #{inspect(args)}"}
    end
    with {:ok, names} <- names,
         {:ok, names} <- Validator.validate_json(names),
         {:ok, names} <- Enum.map(names, &Jason.encode/1) |> Utils.sequence() do
      {:ok, ~s"""
      .available_mods |= map(select(type != "object" or .id | IN(#{Enum.join(names, ",")}) | not))
      """}
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

  # TODO deprecate
  defp compile_command("define", name, args, line, column) do
    case Jason.decode!(name) do
      "play_restriction" -> 
        args = case args do
          [targets, condition] -> {:ok, {List.wrap(targets), condition}}
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define play_restriction` command expects a target (or list of targets) and a condition, got #{inspect(args)}"}
        end

        with {:ok, {targets, condition}} <- args,
             {:ok, targets} <- Validator.validate_json(targets),
             {:ok, targets} <- Jason.encode(targets),
             {:ok, condition} <- compile_condition_list(condition, line, column),
             {:ok, condition} <- Jason.encode(condition) do
          {:ok, ".play_restrictions += [[#{targets}, #{condition}]]"}
        end
      _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `define` got invalid type #{name}"}
    end
  end

  defp compile_command(cmd, _name, _args, line, column) do
    {:error, "Compiler.compile: at line #{line}:#{column}, #{inspect(cmd)} is not a valid toplevel command}"}
  end

  def compile_toplevel_constant(constant, line, column) do
    # basically compile_constant but disallowing actual constants
    case constant do
      {:+, _, _} -> {:error, "cannot use constants in toplevel conditions"}
      {:@, _, _} -> {:error, "cannot use constants in toplevel conditions"}
      _          -> compile_constant(constant, line, column)
    end
  end

  defp compile_toplevel_condition(condition, line, column) do
    case condition do
      {"true", _, _} -> {:ok, "true"}
      {"false", _, _} -> {:ok, "false"}
      {"equals", [line: line, column: column], [l, r]} ->
        with {:ok, l} <- compile_toplevel_constant(l, line, column),
             {:ok, r} <- compile_toplevel_constant(r, line, column),
             {:ok, l} <- Jason.encode(l),
             {:ok, r} <- Jason.encode(r) do
          {:ok, "(#{l} == #{r})"}
        end
      {:==, [line: line, column: column], [l, r]} ->
        with {:ok, l} <- compile_toplevel_constant(l, line, column),
             {:ok, r} <- compile_toplevel_constant(r, line, column),
             {:ok, l} <- Jason.encode(l),
             {:ok, r} <- Jason.encode(r) do
          {:ok, "(#{l} == #{r})"}
        end
      {:in, [line: line, column: column], [l, r]} ->
        with {:ok, r} <- Validator.validate_json_path(r),
             {:ok, l} <- compile_toplevel_constant(l, line, column),
             {:ok, l} <- Jason.encode(l) do
          {:ok, "(#{r} | any(. == #{l}))"}
        end
      {:not, [line: line, column: column], [arg]} ->
        with {:ok, compiled_arg} <- compile_toplevel_condition(arg, line, column) do
          {:ok, "(#{compiled_arg} | not)"}
        end
      {:or, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_toplevel_condition(&1, line, column))) do
          {:ok, "(#{Enum.join(compiled_args, " or ")})"}
        end
      {:and, [line: line, column: column], args} ->
        with {:ok, compiled_args} <- Utils.sequence(Enum.map(args, &compile_toplevel_condition(&1, line, column))) do
          {:ok, "(#{Enum.join(compiled_args, " and ")})"}
        end
      _ ->
        with {:ok, json} <- compile_toplevel_constant(condition, line, column),
             {:ok, value} <- Jason.encode(json) do
          {:ok, "#{value}"}
        end
    end
  end
  # def compile_jq_toplevel!(ast) do
  #   case compile_jq_toplevel(ast) do
  #     {:ok, jq} -> jq
  #     {:error, error} -> raise error
  #   end
  # end
  defp compile_jq_toplevel(ast, line, column) do
    case ast do
      {"if", [line: line, column: column], [condition, [do: then_cmds, else: else_cmds]]} ->
        with {:ok, condition} <- compile_toplevel_condition(condition, line, column),
             {:ok, then_cmds} <- compile_jq_toplevel(then_cmds, line, column),
             {:ok, else_cmds} <- compile_jq_toplevel(else_cmds, line, column) do
          {:ok, "if #{condition} then\n#{then_cmds}\nelse\n#{else_cmds}\nend"}
        end
      {"if", [line: line, column: column], [condition, [do: then_cmds]]} ->
        with {:ok, condition} <- compile_toplevel_condition(condition, line, column),
             {:ok, then_cmds} <- compile_jq_toplevel(then_cmds, line, column) do
          {:ok, "if #{condition} then\n#{then_cmds}\nelse . end"}
        end
      {"unless", [line: line, column: column], [condition, [do: else_cmds]]} ->
        with {:ok, condition} <- compile_toplevel_condition(condition, line, column),
             {:ok, else_cmds} <- compile_jq_toplevel(else_cmds, line, column) do
          {:ok, "if #{condition} then . else\n#{else_cmds}\nend"}
        end
      {cmd, [line: line, column: column], [name | args]} when is_binary(cmd) ->
        name = case name do
          name when is_binary(name) or is_integer(name) -> Validator.validate_json(name)
          {name, _pos, _params} when is_binary(name) or is_integer(name) -> Validator.validate_json(name)
          {:+, _pos, _params} -> Validator.validate_json(name)
          {:@, _pos, _params} -> Validator.validate_json(name)
          {:!, _pos, _params} -> Validator.validate_json(name)
          _ -> {:error, "Compiler.compile: at line #{line}:#{column}, `#{cmd}` command got invalid name #{inspect(name)}"}
        end
        with {:ok, name} <- name,
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
      {:__block__, _pos, []} -> {:ok, "."}
      {:__block__, pos, nodes} ->
        {line, column} = case pos do
          [line: line, column: column] -> {line, column}
          _ -> {0, 0}
        end
        compile_jq_toplevel(nodes, line, column)
      _ when is_list(ast) ->
        ast
        |> Enum.map(&compile_jq_toplevel(&1, line, column))
        |> Utils.sequence()
        |> case do
          {:ok, val}    ->
            ret = Enum.map_join(val, "\n|", &"(" <> &1 <> ")")
            {:ok, ret}
          {:error, msg} -> {:error, msg}
        end
      _ -> {:error, "Compiler.compile: expected toplevel command, got #{inspect(ast)}"}
    end |> add_error_cxt("while compiling toplevel command at line #{line}:#{column}")
  end

  def compile_jq!(ast) do
    case compile_jq(ast) do
      {:ok, jq} -> jq
      {:error, error} -> raise error
    end
  end

  @header """
  def _ensure_list:
    if type == "array" then
      .
    elif type == "null" then
      []
    else [.] end;
  def _safe_append(l; r):
    (l | _ensure_list) + (r | _ensure_list);
  """
  def header(), do: @header

  def compile_jq(ast) do
    case ast do
      {:__block__, _pos, []} -> {:ok, "."}
      {:__block__, pos, nodes} ->
        # IO.inspect(nodes, label: "AST", limit: :infinity)
        {line, column} = case pos do
          [line: line, column: column] -> {line, column}
          _ -> {0, 0}
        end
        case compile_jq_toplevel(nodes, line, column) do
          {:ok, val}    -> {:ok, @header <> val}
          {:error, msg} -> {:error, msg}
        end
      {_name, _pos, _actions} -> compile_jq({:__block__, [], [ast]})
      _ -> {:error, "Compiler.compile: got invalid root node #{inspect(ast)}"}
    end
  end

  def add_error_cxt({:ok, data}, _msg), do: {:ok, data}
  def add_error_cxt({:error, data}, msg), do: {:error, data <> "\n" <> msg}

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
