defmodule RiichiAdvanced.Parser do
  alias RiichiAdvanced.Utils

  def parse(input) when is_binary(input) do
    case byte_size(input) do
      size when size > 4 * 1024 * 1024 ->
        {:error, "script too large (#{size / 1024 / 1024} MB > 4 MB)"}
      _ ->
        Regex.replace(~r/(\w+)\s*([+\-*\/])=\s*/, input, "\\1 = \\1 \\2 ") # convert x += 2 to x = x + 2
        |> Code.string_to_quoted(columns: true, existing_atoms_only: true, static_atoms_encoder: fn name, _pos -> {:ok, if name == "do" do :do else name end} end)
        |> case do
          {:ok, ast} -> {:ok, ast}
          {:error, err} -> {:error, err}
        end
    end
  end

  def parse_tiles(tiles_spec) when is_binary(tiles_spec) do
    ret = for group <- String.split(tiles_spec, " ", trim: true), [_, num, suit | attrs] <- Regex.scan(~r/(\d+)([a-zA-Z])(@([a-zA-Z0-9_&]+))?/, group) do
      tile = "#{num}#{String.downcase(suit)}"
      attrs = case attrs do
        [_, attrs] -> String.split(attrs, "&", trim: true)
        _ -> []
      end
      attrs = if suit == String.upcase(suit) do ["_sideways" | attrs] else attrs end
      if Enum.empty?(attrs) do tile else {:%{}, [], [{"tile", tile}, {"attrs", attrs}]} end
    end
    {:ok, ret}
  end
  def parse_short_notation(tiles_spec) when is_binary(tiles_spec) do
    ret = for hand <- String.split(tiles_spec, " ", trim: true), reduce: [] do
      tiles ->
        new_tiles = for [_, nums, suit | attrs] <- Regex.scan(~r/(\d+)([a-zA-Z])(@([a-zA-Z0-9_&]+))?/, hand), num <- String.graphemes(nums) do
          tile = "#{num}#{String.downcase(suit)}"
          attrs = case attrs do
            [_, attrs] -> String.split(attrs, "&", trim: true)
            _ -> []
          end
          attrs = if suit == String.upcase(suit) do ["_sideways" | attrs] else attrs end
          if Enum.empty?(attrs) do tile else {:%{}, [], [{"tile", tile}, {"attrs", attrs}]} end
        end
        [new_tiles | tiles]
    end
    |> Enum.reverse()
    |> Enum.intersperse(["3x"])
    |> Enum.concat()
    {:ok, ret}
  end

  def parse_set(set_spec) when is_binary(set_spec) do
    set_spec = for group <- String.split(set_spec, "|") |> Enum.map(&String.trim/1) do
      for subgroup <- String.split(group, ",", trim: true) |> Enum.map(&String.trim/1) do
        for item <- String.split(subgroup, " ", trim: true) |> Enum.map(&String.trim/1) do
          # check for attributes
          item_attrs = case String.split(item, "@") |> Enum.map(&String.trim/1) do
            [item] -> {:ok, {item, []}}
            [item, attrs] -> {:ok, {item, String.split(attrs, "&")}}
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
    end |> Utils.sequence()
    # simplify singleton sets, i.e. [[0,1,2]] -> [0,1,2]
    with {:ok, set_spec} <- set_spec do
      {:ok, for group <- set_spec do
        case group do
          [set] when is_list(set) -> set
          set -> set
        end
      end}
    end
  end

  @match_keywords ["almost", "exhaustive", "ignore_suit", "restart", "dismantle_calls", "unique", "nojoker", "debug"]

  defp parse_group(group_spec) do
    case String.split(group_spec, ":", trim: true) do
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
            [base, attrs] -> {:ok, {base, String.split(attrs, "&", trim: true)}}
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
      _ -> {:error, "expected :count after item #{inspect(group_spec)}"}
    end
  end

  def parse_match(match_spec) when is_binary(match_spec) do
    for match_definition <- String.split(match_spec, "|") |> Enum.map(&String.trim/1) do
      items = String.split(match_definition, ",", trim: true) |> Enum.map(&String.trim/1)
      if "american" in items do
        {:ok, Enum.find(items, & &1 != "american")}
      else
        for item <- items do
          if item not in @match_keywords do parse_group(item) else {:ok, item} end
        end |> Utils.sequence()
      end
    end |> Utils.sequence()
  end

  def parse_sigils({:sigil_t, _, [{:<<>>, _, [tiles_spec]}, _args]}), do: parse_short_notation(tiles_spec)
  def parse_sigils({:sigil_T, _, [{:<<>>, _, [tiles_spec]}, _args]}), do: parse_tiles(tiles_spec)
  def parse_sigils({:sigil_s, _, [{:<<>>, _, [set_spec]}, _args]}), do: parse_set(set_spec)
  def parse_sigils({:sigil_m, _, [{:<<>>, _, [match_spec]}, _args]}), do: parse_match(match_spec)
  def parse_sigils([do: expr]), do: parse_sigils(expr)
  def parse_sigils(ast) when is_list(ast) do
    # check if keyword list (except the keys are binaries, not atoms)
    if Enum.all?(ast, &match?({k, _v} when is_binary(k), &1)) do
      {ks, vs} = Enum.unzip(ast)
      with {:ok, vs} <- vs |> Enum.map(&parse_sigils/1) |> Utils.sequence() do
        # turn it into a map
        {:ok, {:%{}, [], Enum.zip(ks, vs)}}
      end
    else
      # otherwise, it's just a regular list
      ast |> Enum.map(&parse_sigils/1) |> Utils.sequence()
    end
  end
  def parse_sigils({:%{}, pos, contents}) do
    parsed_map = contents
    |> Enum.map(fn {key, val} ->
      if is_binary(key) do
        case parse_sigils(val) do
          {:ok, val}    -> {:ok, {key, val}}
          {:error, msg} -> {:error, "error parsing sigils in map value: " <> msg}
        end
      else {:error, "non-string JSON key: #{inspect(key)}"} end
    end)
    |> Utils.sequence()
    with {:ok, parsed_map} <- parsed_map do
      {:ok, {:%{}, pos, parsed_map}}
    end
  end
  def parse_sigils(ast), do: {:ok, ast}

end
