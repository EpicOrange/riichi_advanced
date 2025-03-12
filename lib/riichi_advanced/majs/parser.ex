defmodule RiichiAdvanced.Parser do
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

  def parse_set(set_spec) do
    set_spec = for subgroup <- String.split(set_spec, "|", trim: true) |> Enum.map(&String.trim/1) do
      for item <- String.split(subgroup, " ", trim: true) |> Enum.map(&String.trim/1) do
        # check for attributes
        item_attrs = case String.split(item, "@") |> Enum.map(&String.trim/1) do
          [item] -> {:ok, {item, []}}
          [item, attrs] -> {:ok, {item, String.split(attrs, ",")}}
          _ -> {:error, "expected no more than one @ in set item"}
        end
        with {:ok, {item, attrs}} <- item_attrs do
          offset = case Integer.parse(item) do
            {offset, ""} -> offset
            _ -> item
          end
          if Enum.empty?(attrs) do
            {:ok, offset}
          else
            {:ok, {:%{}, [], [{"offset", offset}, {"attrs", attrs}]}}
          end
        end
      end |> Utils.sequence()
    end |> Utils.sequence()
    # simplify singleton sets, i.e. [[0,1,2]] -> [0,1,2]
    with {:ok, set_spec} <- set_spec do
      case set_spec do
        [set] when is_list(set) -> {:ok, set}
        set -> {:ok, set}
      end
    end
  end

  @match_keywords ["exhaustive", "unique"]

  def parse_match(match_spec) do
    for match_definition <- String.split(match_spec, "|", trim: true) |> Enum.map(&String.trim/1) do
      for item <- String.split(match_definition, ",", trim: true) |> Enum.map(&String.trim/1) do
        if item not in @match_keywords do
          case String.split(item, ":", trim: true) do
            [groups_str, count_str] ->
              # parse count
              count = case Integer.parse(count_str) do
                {count, ""} -> {:ok, count}
                _ -> {:error, "could not parse count: #{inspect(count_str)}"}
              end
              # parse groups
              groups = groups_str
              |> String.replace_leading("(", "")
              |> String.replace_trailing(")", "")
              |> String.split(" ", trim: true)
              |> Enum.map(fn group ->
                # check for attributes
                base_attrs = case String.split(group, "@", trim: true) |> Enum.map(&String.trim/1) do
                  [base] -> {:ok, {base, []}}
                  [base, attrs] -> {:ok, {base, String.split(attrs, ",", trim: true)}}
                  _ -> {:error, "invalid attribute syntax: #{group}"}
                end
                with {:ok, {base, attrs}} <- base_attrs do
                  groups = case attrs do
                    [] -> base
                    attrs -> {:%{}, [], [{"tile", base}, {"attrs", attrs}]}
                  end
                  {:ok, groups}
                end
              end)
              |> Utils.sequence()
              with {:ok, groups} <- groups,
                   {:ok, count} <- count do
                {:ok, [groups, count]}
              end
            _ -> {:error, "expected :count after item #{inspect(item)}"}
          end
        else {:ok, item} end
      end |> Utils.sequence()
    end |> Utils.sequence()
  end

end
