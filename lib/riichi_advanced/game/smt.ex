defmodule RiichiAdvanced.SMT do
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Match, as: Match
  alias RiichiAdvanced.Riichi, as: Riichi
  alias RiichiAdvanced.Utils, as: Utils
  
  @boilerplate """
               (set-logic QF_FD)
               (define-fun zero () (_ BitVec <len>) (_ bv0 <len>))
               (define-fun one () (_ BitVec <len>) (_ bv1 <len>))
               (define-fun add8_single ((left (_ BitVec 4)) (right (_ BitVec 4))) (_ BitVec 4)
                 (bvor (bvand #x8 left) (bvand #x8 right) (bvadd (bvand #x7 left) (bvand #x7 right))))
               (declare-const octal_mask (_ BitVec <len>))
               (declare-const carry_mask (_ BitVec <len>))
               (define-fun add8 ((left (_ BitVec <len>)) (right (_ BitVec <len>))) (_ BitVec <len>)
                 (bvor (bvand carry_mask left) (bvand carry_mask right) (bvadd (bvand octal_mask left) (bvand octal_mask right))))
               (define-fun fold_digits ((shift (_ BitVec <len>)) (bv (_ BitVec <len>))) (_ BitVec <len>)
                 (bvand (bvsub (bvshl one shift) one) (add8 bv (bvlshr bv shift))))
               (define-fun is_set_num ((num (_ BitVec 8))) Bool
                 (and (bvule (_ bv1 8) num) (bvule num (_ bv3 8))))
               (define-fun make_mask ((size (_ BitVec <len>))) (_ BitVec <len>)
                 (bvsub (bvshl one size) one))
               (define-fun add_overflow ((size (_ BitVec <len>)) (val (_ BitVec <len>))) (_ BitVec <len>)
                 (bvor (bvand val (make_mask size)) (bvlshr val size)))
               (define-fun apply_set ((set (_ BitVec <len>)) (ixs (_ BitVec <len>)) (suit_size (_ BitVec <len>))) (_ BitVec <len>)
                 (bvmul set (bvand ixs (make_mask suit_size))))
               (define-fun apply_set_cycle ((set (_ BitVec <len>)) (ixs (_ BitVec <len>)) (pos (_ BitVec <len>)) (suit_size (_ BitVec <len>))) (_ BitVec <len>)
                 (bvshl (add_overflow suit_size (apply_set set (bvlshr ixs pos) suit_size)) pos))
               (define-fun apply_set_chain ((set (_ BitVec <len>)) (ixs (_ BitVec <len>)) (pos (_ BitVec <len>)) (suit_size (_ BitVec <len>))) (_ BitVec <len>)
                 (bvshl (bvand (apply_set set (bvlshr ixs pos) suit_size) (make_mask suit_size)) pos))
               """

  def to_smt_tile(tile, encoding, ix \\ -1, joker_ixs \\ %{}) do
    if is_list(tile) do
      smt_tile_list = for t <- tile, do: to_smt_tile(t, encoding, ix, joker_ixs)
      "(bvadd #{Enum.join(smt_tile_list, " ")})"
    else
      if ix in joker_ixs do "joker#{ix}" else
        case encoding[Utils.strip_attrs(tile)] do
          nil ->
            # IO.puts("Unhandled smt tile #{inspect(tile)}")
            # IO.inspect(Process.info(self(), :current_stacktrace))
            IO.puts("Unhandled smt tile #{inspect(tile)}\nEncoding:")
            IO.inspect(encoding)
            "zero"
          encoded -> encoded
        end
      end
    end
  end

  def make_chainable(args, fun) do
    Enum.reduce(args, fn arg, acc -> "(#{fun} #{arg} #{acc})" end)
  end

  def obtain_all_solutions(solver_pid, encoding, encoding_r, joker_ixs, last_assignment \\ nil, result \\ []) do
    cond do
      length(joker_ixs) == 0 -> [%{}]
      length(result) >= Integer.floor_div(100, length(joker_ixs)) -> result
      true ->
        contra = if last_assignment == nil do "" else Enum.map(joker_ixs, fn i -> "(equal_digits joker#{i} #{to_smt_tile(last_assignment[i], encoding)})" end) end
        contra = if last_assignment == nil do "" else "(assert (not (and #{Enum.join(contra, " ")})))\n" end
        query = "(get-value (#{Enum.join(Enum.map(joker_ixs, fn i -> "joker#{i}" end), " ")}))\n"
        smt = Enum.join([contra, "(check-sat)\n", query])
        if Debug.print_smt() do
          IO.puts(smt)
        end
        {:ok, response} = GenServer.call(solver_pid, {:query, smt, false}, 60000)
        case ExSMT.Solver.ResponseParser.parse(response) do
          [:sat | assigns] ->
            new_assignment = Map.new(Enum.zip(joker_ixs, Enum.flat_map(assigns, &Enum.map(&1, fn [_, val] -> encoding_r[val] end))))
            obtain_all_solutions(solver_pid, encoding, encoding_r, joker_ixs, new_assignment, [new_assignment | result])
          [:unsat | _] -> result
        end
    end
  end

  def get_chain(ordering, x, depth \\ 0)
  def get_chain(_, nil, _), do: []
  def get_chain(ordering, x, depth) do
    if depth >= 100 do [] else [x | get_chain(ordering, ordering[x], depth + 1)] end
  end

  def find_chains_cycles(ordering, other_tiles \\ []) do
    if not Enum.empty?(ordering) do
      # starting from non-destination points, find all chains
      chains = (other_tiles ++ Map.keys(ordering))
      |> MapSet.new()
      |> MapSet.difference(ordering |> Map.values() |> MapSet.new())
      |> Enum.map(&get_chain(ordering, &1))
      used_tiles = Enum.concat(chains)
      # remove used tiles, plus an arbitrary link, and repeat
      ordering = ordering
      |> Enum.reject(fn {t1, _t2} -> t1 in used_tiles end)
      |> Enum.drop(1)
      |> Map.new()
      {cycles1, cycles2} = find_chains_cycles(ordering)
      {chains, cycles1 ++ cycles2}
    else {[], []} end
  end
  # RiichiAdvanced.SMT.find_chains_cycles(%{"2m": :"3m", "6m": :"7m", "7m": :"8m", "1m": :"2m", "3m": :"4m", "8m": :"9m", "4m": :"5m"})
  # RiichiAdvanced.SMT.find_chains_cycles(%{"2m": :"3m", "6m": :"7m", "7m": :"8m", "5m": :"6m", "1m": :"2m", "3m": :"4m", "8m": :"9m", "4m": :"5m"})
  # RiichiAdvanced.SMT.find_chains_cycles(%{"2m": :"3m", "6m": :"7m", "7m": :"8m", "5m": :"6m", "1m": :"2m", "3m": :"4m", "8m": :"9m", "4m": :"5m", "9m": :"1m"})
  # RiichiAdvanced.SMT.find_chains_cycles(%{"1z": :"2z", "2z": :"3z", "3z": :"4z", "4z": :"1z", "5z": :"6z", "6z": :"7z", "7z": :"5z"})

  # return encoding length, a map from tiles to smt tile values, and a smt function that shifts sets accordingly

  def sum_digits_ix_generator(ix, acc \\ [])
  def sum_digits_ix_generator(ix, acc) when ix <= 4 do
    Enum.reverse(acc)
  end
  def sum_digits_ix_generator(ix, acc) do
    next_ix = trunc(Float.ceil(ix / 8) * 4)
    sum_digits_ix_generator(next_ix, [next_ix | acc])
  end

  def determine_encoding(ordering, other_tiles \\ []) do
    {chains, cycles} = find_chains_cycles(ordering, other_tiles)
    num_tiles = length(Enum.concat(chains ++ cycles))
    len = 4 * num_tiles
    # (define-fun shift_set ((indices (_ BitVec 136)) (set (_ BitVec 136))) (_ BitVec 136)
    #   (bvor
    #     (apply_set_cycle set indices (_ bv0 136) (_ bv36 136))
    #     (apply_set_cycle set indices (_ bv36 136) (_ bv36 136))
    #     (apply_set_cycle set indices (_ bv72 136) (_ bv36 136))
    #     (apply_set_chain set indices (_ bv108 136) (_ bv16 136))
    #     (apply_set_chain set indices (_ bv124 136) (_ bv12 136))))
    {acc, encoding, encoding_r, suits} = for chain <- chains, reduce: {0, %{}, %{}, []} do
      {acc, encoding, encoding_r, suits} ->
        suit_len = 4 * length(chain)
        new_suit = "(apply_set_chain set indices (_ bv#{acc} #{len}) (_ bv#{suit_len} #{len}))"
        new_encoding = chain
        |> Enum.with_index()
        |> Map.new(fn {tile, i} -> {tile, "(bvshl one (_ bv#{acc+i*4} #{len}))"} end)
        new_encoding_r = chain
        |> Enum.with_index()
        |> Map.new(fn {tile, i} -> {Bitwise.<<<(1, acc+i*4), tile} end)
        {acc + suit_len, Map.merge(encoding, new_encoding), Map.merge(encoding_r, new_encoding_r), [new_suit | suits]}
    end

    # preprocess cycles so they start with 1m,1p,1s if possible
    # so cosmic mahjong can shift suits
    # (our encoding of 10, 20 offsets assumes 8 digit gap between tiles)
    # (which requires aligning the three suits)
    cycles = for cycle <- cycles do
      one_ix = Enum.find_index(cycle, & &1 in [:"1m", :"1p", :"1s"])
      if one_ix != nil do
        {head, tail} = Enum.split(cycle, one_ix)
        tail ++ head
      else cycle end
    end

    {_, encoding, encoding_r, suits} = for cycle <- cycles, reduce: {acc, encoding, encoding_r, suits} do
      {acc, encoding, encoding_r, suits} ->
        suit_len = 4 * length(cycle)
        new_suit = "(apply_set_cycle set indices (_ bv#{acc} #{len}) (_ bv#{suit_len} #{len}))"
        new_encoding = cycle
        |> Enum.with_index()
        |> Map.new(fn {tile, i} -> {tile, "(bvshl one (_ bv#{acc+i*4} #{len}))"} end)
        new_encoding_r = cycle
        |> Enum.with_index()
        |> Map.new(fn {tile, i} -> {Bitwise.<<<(1, acc+i*4), tile} end)
        {acc + suit_len, Map.merge(encoding, new_encoding), Map.merge(encoding_r, new_encoding_r), [new_suit | suits]}
    end
    shift_set = "(define-fun shift_set ((indices (_ BitVec #{len})) (set (_ BitVec #{len}))) (_ BitVec #{len})\n  (bvor " <> Enum.join(suits, "\n        ") <> "))"

    # (assert (= octal_mask #x7777777777777777777777777777777777))
    # (assert (= carry_mask #x8888888888888888888888888888888888))
    octal_mask = "(assert (= octal_mask #x#{String.duplicate("7", num_tiles)}))"
    carry_mask = "(assert (= carry_mask #x#{String.duplicate("8", num_tiles)}))"

    # (define-fun sum_digits ((bv (_ BitVec 136))) (_ BitVec 4)
    #   ((_ extract 3 0)
    #     (fold_digits (_ bv4 136)
    #     (fold_digits (_ bv8 136)
    #     (fold_digits (_ bv12 136)
    #     (fold_digits (_ bv20 136)
    #     (fold_digits (_ bv36 136)
    #     (fold_digits (_ bv68 136) bv))))))))
    fold_digits_calls = Enum.reduce(RiichiAdvanced.SMT.sum_digits_ix_generator(len), "bv", fn ix, exp -> "(fold_digits (_ bv#{ix} #{len})\n    #{exp})" end)
    sum_digits = """
    (define-fun sum_digits ((bv (_ BitVec #{len}))) (_ BitVec 4)
      ((_ extract 3 0)
        #{fold_digits_calls}))
    """

    # (define-fun equal_digits ((left (_ BitVec 136)) (right (_ BitVec 136))) Bool
    #   (and
    #     (= ((_ extract 135 132) left) ((_ extract 135 132) right))
    #     (= ((_ extract 131 128) left) ((_ extract 131 128) right))
    #     (= ((_ extract 127 124) left) ((_ extract 127 124) right))
    #     ...
    #     (= ((_ extract 11 8) left) ((_ extract 11 8) right))
    #     (= ((_ extract 7 4) left) ((_ extract 7 4) right))
    #     (= ((_ extract 3 0) left) ((_ extract 3 0) right))))
    equal_calls = Enum.map(0..len-1//4, fn ix -> "(= ((_ extract #{ix+3} #{ix}) left) ((_ extract #{ix+3} #{ix}) right))" end)
    at_least_calls = Enum.map(0..len-1//4, fn ix -> "(bvuge ((_ extract #{ix+3} #{ix}) left) ((_ extract #{ix+3} #{ix}) right))" end)
    equal_digits = """
    (define-fun equal_digits ((left (_ BitVec #{len})) (right (_ BitVec #{len}))) Bool
      (and
        #{Enum.join(equal_calls, "\n    ")}))
    (define-fun at_least_digits ((left (_ BitVec #{len})) (right (_ BitVec #{len}))) Bool
      (and
        #{Enum.join(at_least_calls, "\n    ")}))
    (define-fun nonzero ((val (_ BitVec #{len}))) Bool
      (not (equal_digits zero val)))
    """

    tile_from_index = """
    (define-fun tile_from_index ((ix (_ BitVec 8))) (_ BitVec #{len})
      (bvshl one (concat (_ bv0 #{len-8}) (bvshl ix (_ bv2 8)))))
    """

    smt = Enum.join([octal_mask, carry_mask, sum_digits, equal_digits, tile_from_index, shift_set, ""], "\n")

    {len, encoding, encoding_r, smt}
  end
  # RiichiAdvanced.SMT.determine_encoding(%{"1z": :"2z", "2z": :"3z", "3z": :"4z", "4z": :"1z", "5z": :"6z", "6z": :"7z"})

  def set_suit_to_bitvector(set) do
    # input: [0, 0, 3, 6]
    # output: "001001002"
    set
    |> Enum.frequencies()
    |> Enum.reduce([0, 0, 0, 0, 0, 0, 0, 0, 0], fn {ix, freq}, acc -> List.replace_at(acc, ix, freq) end)
    |> Enum.reverse()
    |> Enum.map_join(&Integer.to_string/1)
  end

  def add_missing_suit(sets) do
    # basically if sets has keys 0 and 2 but not 1, add 1
    if Map.has_key?(sets, 0) and not Map.has_key?(sets, 1) and Map.has_key?(sets, 2) do
      Map.put(sets, 1, [])
    else sets end
  end

  def set_to_bitvector(set, len) do
    # input: [0, 0, 3, 6, 11, 11, 14, 17, 22, 22, 25, 28]
    # output: "#x100100200010010020001001002"
    # 100, 101, 102 correspond to dragons, we ignore them
    {tiles, _dragons} = Enum.split_with(set, fn i -> i < 30 end)
    tiles
    |> Enum.group_by(fn i -> trunc(i / 10) end)
    |> add_missing_suit()
    |> Enum.sort_by(fn {k, _v} -> -k end)
    |> Enum.map_join(fn {_k, v} -> set_suit_to_bitvector(Enum.map(v, &rem(&1, 10))) end)
    |> String.pad_leading(Integer.floor_div(len, 4), "0")
    |> then(&"#x" <> &1)
  end

  def remove_group_keywords(group) do
    if is_list(group) do Enum.reject(group, & &1 in Match.group_keywords()) |> Enum.sort() else group end
  end

  def strip_restart(match_definition) do
    if "restart" in match_definition do
      # remove "restart" and everything to the left of it
      match_definition
      |> Enum.reverse()
      |> Enum.take_while(& &1 != "restart")
      |> Enum.reverse()
    else match_definition end
  end

  def tile_group_assertion(i, encoding, len, group, num, unique) do
    if unique do
      # "(assert ((_ at-least #{num})\n#{Enum.map(group, fn tile -> "    (nonzero (bvand h (bvmul (_ bv7 #{len}) #{to_smt_tile(Utils.to_tile(tile), encoding)})))" end) |> Enum.join("\n")}))"
      tiles = Enum.map(group, &to_smt_tile(Utils.to_tile(&1), encoding))
      tile_ixs = 1..length(tiles)
      declare_tile_flags = Enum.map(tile_ixs, fn ix -> "(declare-const tiles#{i}_#{ix} Bool)" end)
      all_tiles = Enum.map(tile_ixs, fn ix -> "tiles#{i}_#{ix}" end) |> Enum.join(" ")
      equals_tiles = "(equal_digits tiles#{i} (bvadd\n      #{Enum.map(Enum.zip(tiles, tile_ixs), fn {tile, ix} -> "(ite tiles#{i}_#{ix} #{tile} zero)" end) |> Enum.join("\n      ")}))"
      assert_tile = "(assert (=> tiles#{i}_used\n  (and\n    #{equals_tiles}\n    (at_least_digits hand tiles#{i})\n    ((_ at-least #{num}) #{all_tiles})\n    ((_ at-most #{num}) #{all_tiles}))))"
      Enum.join(declare_tile_flags ++ [assert_tile], "\n")
    else
      "(assert (equal_digits tiles#{i} (bvmul (_ bv#{num} #{len}) (bvadd\n    #{Enum.map(group, &to_smt_tile(Utils.to_tile(&1), encoding)) |> Enum.join("\n    ")}))))"
    end
  end

  def _match_hand_smt_v2(solver_pid, hand, calls, all_tiles, match_definitions, tile_behavior) do
    ordering = tile_behavior.ordering
    tile_mappings = TileBehavior.tile_mappings(tile_behavior)

    calls = calls
    |> Enum.reject(fn {call_name, _call} -> call_name in Riichi.flower_names() end)
    |> Enum.map(&Utils.call_to_tiles/1)
    |> Enum.map(&Enum.take(&1, 3)) # ignore kans
    |> Enum.with_index()

    jokers = Map.keys(tile_mappings)
    if Debug.print_smt() do
      IO.puts("Hand to be encoded into SMT is #{inspect(hand)}")
      IO.puts("Calls to be encoded into SMT is #{inspect(calls)}")
      IO.puts("Jokers are #{inspect(jokers)}")
    end
    all_tiles = tile_mappings
    |> Map.values()
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(all_tiles, &MapSet.union/2)
    |> MapSet.new(&Utils.strip_attrs/1)
    |> Enum.reject(& &1 in jokers) # we're solving for jokers, so don't include them as assignables
    # IO.puts("Non-joker tiles are #{inspect(all_tiles)}")
    {len, encoding, encoding_r, encoding_boilerplate} = determine_encoding(ordering, all_tiles)
    # encoding = %{
    #   :"1m" => "#x0000000000000000000000000000000001",
    #   :"2m" => "#x0000000000000000000000000000000010",
    #   :"3m" => "#x0000000000000000000000000000000100",
    #   :"4m" => "#x0000000000000000000000000000001000",
    #   :"5m" => "#x0000000000000000000000000000010000",
    #   :"6m" => "#x0000000000000000000000000000100000",
    #   :"7m" => "#x0000000000000000000000000001000000",
    #   :"8m" => "#x0000000000000000000000000010000000",
    #   :"9m" => "#x0000000000000000000000000100000000",
    #   :"1p" => "#x0000000000000000000000001000000000",
    #   :"2p" => "#x0000000000000000000000010000000000",
    #   :"3p" => "#x0000000000000000000000100000000000",
    #   :"4p" => "#x0000000000000000000001000000000000",
    #   :"5p" => "#x0000000000000000000010000000000000",
    #   :"6p" => "#x0000000000000000000100000000000000",
    #   :"7p" => "#x0000000000000000001000000000000000",
    #   :"8p" => "#x0000000000000000010000000000000000",
    #   :"9p" => "#x0000000000000000100000000000000000",
    #   :"1s" => "#x0000000000000001000000000000000000",
    #   :"2s" => "#x0000000000000010000000000000000000",
    #   :"3s" => "#x0000000000000100000000000000000000",
    #   :"4s" => "#x0000000000001000000000000000000000",
    #   :"5s" => "#x0000000000010000000000000000000000",
    #   :"6s" => "#x0000000000100000000000000000000000",
    #   :"7s" => "#x0000000001000000000000000000000000",
    #   :"8s" => "#x0000000010000000000000000000000000",
    #   :"9s" => "#x0000000100000000000000000000000000",
    #   :"1z" => "#x0000001000000000000000000000000000",
    #   :"2z" => "#x0000010000000000000000000000000000",
    #   :"3z" => "#x0000100000000000000000000000000000",
    #   :"4z" => "#x0001000000000000000000000000000000",
    #   :"5z" => "#x0010000000000000000000000000000000",
    #   :"0z" => "#x0010000000000000000000000000000000",
    #   :"6z" => "#x0100000000000000000000000000000000",
    #   :"7z" => "#x1000000000000000000000000000000000"
    # }

    # first figure out what the sets are
    # generates this:
    # (define-fun set1 () (_ BitVec 136) #x0000000000000000000000000000000111)
    # (define-fun set2 () (_ BitVec 136) #x0000000000000000000000000000000003)
    # (define-fun set3 () (_ BitVec 136) #x0000000000000000000000000000000002)
    # (define-fun to_set ((num (_ BitVec 8))) (_ BitVec 136)
    #   (ite (= num (_ bv1 8)) set1
    #   (ite (= num (_ bv2 8)) set2
    #   (ite (= num (_ bv3 8)) set3 zero))))
    # IO.inspect(match_definitions, charlists: :as_lists, label: "match_definitions")
    all_sets = match_definitions
    |> Enum.concat()
    |> Enum.reject(&Kernel.is_binary/1)
    |> Enum.filter(fn [_groups, num] -> num > 0 end)
    |> Enum.flat_map(fn [groups, _num] -> groups end)
    |> Enum.reject(fn group -> is_binary(group) end)
    |> Enum.reject(fn group -> is_list(group) and Utils.is_tile(Enum.at(group, 0)) end)
    |> Enum.map(&remove_group_keywords/1)
    |> Enum.uniq() # [[0, 0], [0, 1, 2], [0, 0, 0]]
    # IO.inspect(all_sets, charlists: :as_lists, label: "all_sets")
    set_definitions = all_sets
    |> Enum.map(fn group -> Enum.flat_map(group, fn elem -> if is_list(elem) do elem else [elem] end end) end)
    |> Enum.with_index()
    |> Enum.map(fn {set, i} ->
      if Enum.any?(set, & &1 >= 10) do
        # multi-suit set; must be equal to one of three possible suit rotations
        str1 = set_to_bitvector(set, len)
        str2 = set_to_bitvector(Enum.map(set, &Integer.mod(&1 + 10, 30)), len)
        str3 = set_to_bitvector(Enum.map(set, &Integer.mod(&1 + 20, 30)), len)
        """
        (declare-const set#{i+1}_sel (_ BitVec 2))
        (define-fun set#{i+1} () (_ BitVec #{len})
          (ite (= (_ bv1 2) set#{i+1}_sel) #{str1}
          (ite (= (_ bv2 2) set#{i+1}_sel) #{str2}
          (ite (= (_ bv3 2) set#{i+1}_sel) #{str3} zero))))
        """
      else
        str = set_to_bitvector(set, len)
        "(define-fun set#{i+1} () (_ BitVec #{len}) #{str})\n"
      end
    end)
    set_indices = if Enum.empty?(all_sets) do [] else 1..length(all_sets) end
    to_set_fun = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "\n  (ite (= num (_ bv#{i} 8)) set#{i}" end) end
    to_set_fun = if Enum.empty?(all_sets) do "" else "(define-fun to_set ((num (_ BitVec 8))) (_ BitVec #{len})" <> Enum.join(to_set_fun) <> " zero)" <> String.duplicate(")", length(all_sets)) <> "\n" end

    # first figure out which tiles are jokers based on tile_mappings
    call_tiles = Enum.flat_map(calls, fn {call, _i} -> call end)
    {joker_ixs, joker_constraints} = hand ++ call_tiles
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _ix} -> Utils.has_matching_tile?([tile], jokers) end)
    |> Enum.map(fn {tile, ix} ->
      {_joker, joker_choices} = Enum.find(tile_mappings, fn {joker, _choices} -> Utils.same_tile(tile, joker) end)
      joker_choices = joker_choices
      |> Enum.map(&Utils.strip_attrs/1)
      |> Enum.flat_map(fn tile2 -> if tile2 == :any do all_tiles else [tile2] end end)
      |> Enum.map(fn tile2 -> "(= joker#{ix} #{to_smt_tile(tile2, encoding)})" end)
      |> Enum.join("\n            ")
      {ix, "(declare-const joker#{ix} (_ BitVec #{len}))\n(assert (or #{joker_choices}))\n"}
    end)
    |> Enum.unzip()

    # collect all non-set tile groups used (sets of exact tiles rather than shiftable sets)
    all_tile_groups = for match_definition <- match_definitions, {[groups, num], group_ix} <- Enum.with_index(match_definition), num > 0, reduce: [] do
      all_tile_groups ->
        unique_ix = Enum.find_index(match_definition, & &1 == "unique")
        tile_groups = groups
        |> Enum.map(&remove_group_keywords/1)
        # reject groups that are already sets
        |> Enum.reject(& &1 in all_sets)
        # reject groups that contain tiles that don't exist in our encoding
        |> Enum.reject(&cond do
          Utils.is_tile(&1) -> not Map.has_key?(encoding, &1 |> Utils.to_tile() |> Utils.strip_attrs())
          is_list(&1) -> Enum.any?(&1, fn tile -> not Map.has_key?(encoding, tile |> Utils.to_tile() |> Utils.strip_attrs()) end)
          true -> IO.puts("Unrecognized group #{inspect(&1)}\nGroups are: #{inspect(groups)}")
        end)
        if Enum.empty?(tile_groups) do
          all_tile_groups
        else
          unique = unique_ix != nil and group_ix > unique_ix
          new_groups = if unique do
            [{tile_groups, num, true}]
          else
            Enum.flat_map(tile_groups, fn group -> cond do
              is_binary(group) -> [{[group], num, false}]
              is_list(group) and Utils.is_tile(Enum.at(group, 0)) -> [{group, num, false}]
              true ->
                IO.puts("Unhandled SMT tile group #{inspect(group, charlists: :as_lists)}. Maybe it's an unrecognized set type not in all_sets?")
                []
            end end)
          end
          all_tile_groups ++ new_groups
        end
    end |> Enum.uniq()

    # hand part 2: declare hand
    # (declare-const hand (_ BitVec 136))
    # (assert (= hand (bvadd #x0001100001110000000200000000000000 joker1)))
    hand_smt = hand
    |> Enum.with_index()
    |> Enum.map(fn {tile, ix} -> "#{to_smt_tile(tile, encoding, ix, joker_ixs)}\n                       " end)
    hand_smt = ["(declare-const hand (_ BitVec #{len}))\n(assert (= hand (bvadd #{Enum.join(hand_smt)})))\n"]
    
    # hand part 2: declare variables for hand indices
    # (declare-const hand_indices1 (_ BitVec 136))
    # (declare-const hand_indices2 (_ BitVec 136))
    # (declare-const hand_indices3 (_ BitVec 136))
    # (assert
    #   (equal_digits hand (bvadd
    #     (bvmul hand_indices1 set1)
    #     (bvmul hand_indices2 set2)
    #     (bvmul hand_indices3 set3)
    #     (ite tiles1_used tiles1 zero))))
    set_indices = if Enum.empty?(all_sets) do [] else 1..length(all_sets) end
    declare_hand_indices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "(declare-const hand_indices#{i} (_ BitVec #{len}))\n" end) end
    # we use bvmul for sets that use different suits
    # otherwise, use shift_set, which handles wrapping
    add_hand_indices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "\n    (#{if Enum.all?(Enum.at(all_sets, i-1), & &1 < 10) do "shift_set" else "bvmul" end} hand_indices#{i} set#{i})" end) |> Enum.join() end
    # add tile groups to the hand if they are used
    tile_group_indices = if Enum.empty?(all_tile_groups) do [] else 1..length(all_tile_groups) end
    add_used_tiles = if Enum.empty?(all_tile_groups) do [] else Enum.map(tile_group_indices, fn i -> "\n    (ite tiles#{i}_used tiles#{i} zero)" end) end
    assert_hand_indices = if Enum.empty?(all_sets) do [] else ["(assert\n  (equal_digits hand (bvadd#{add_hand_indices}#{add_used_tiles})))\n"] end

    has_calls = length(calls) > 0
    calls_smt = if has_calls do
      # calls part 1: declare each non-flower call
      # (declare-const call1 (_ BitVec 136))
      # (assert (= call1 (bvadd joker3 #x0000000011000000000000000000000000)))
      # (declare-const call2 (_ BitVec 136))
      # (assert (= call2 (bvadd #x0000000000111000000000000000000000)))
      calls_decls = for {call, i} <- calls, reduce: [] do
        calls_decls ->
          call_smt = call
          |> Enum.with_index()
          |> Enum.map(fn {tile, ix} -> "#{to_smt_tile(tile, encoding, length(hand)+i*3+ix, joker_ixs)}" end)
          calls_decls ++ ["(declare-const call#{i+1} (_ BitVec #{len}))\n(assert (= call#{i+1} (bvadd #{Enum.join(call_smt, "\n                        ")})))\n"]
      end

      # calls part 2: declare variables for call indices and set identities
      # (declare-const call1_index (_ BitVec 8))
      # (declare-const call1_set (_ BitVec 8))
      # (assert (is_set_num call1_set))
      # (assert (equal_digits call1 (bvmul (tile_from_index call1_index) (to_set call1_set))))
      # (declare-const call2_index (_ BitVec 8))
      # (declare-const call2_set (_ BitVec 8))
      # (assert (is_set_num call2_set))
      # (assert (equal_digits call2 (bvmul (tile_from_index call2_index) (to_set call2_set))))
      call_identities = Enum.map(1..length(calls), fn i ->
        """
        (declare-const call#{i}_index (_ BitVec 8))
        (declare-const call#{i}_set (_ BitVec 8))
        (assert (is_set_num call#{i}_set))
        (assert (equal_digits call#{i} (shift_set (tile_from_index call#{i}_index) (to_set call#{i}_set))))
        """
      end)

      # calls part 3: assertions for call indices 
      # (define-fun call_indices1 () (_ BitVec 136)
      #   (bvadd (ite (= call1_set (_ bv1 8)) (tile_from_index call1_index) zero)
      #          (ite (= call2_set (_ bv1 8)) (tile_from_index call2_index) zero)))
      # (define-fun call_indices2 () (_ BitVec 136)
      #   (bvadd (ite (= call1_set (_ bv2 8)) (tile_from_index call1_index) zero)
      #          (ite (= call2_set (_ bv2 8)) (tile_from_index call2_index) zero)))
      # (define-fun call_indices3 () (_ BitVec 136)
      #   (bvadd (ite (= call1_set (_ bv3 8)) (tile_from_index call1_index) zero)
      #          (ite (= call2_set (_ bv3 8)) (tile_from_index call2_index) zero)))
      call_indices = Enum.map(set_indices, fn i ->
        call_sets = Enum.map(1..length(calls), fn j -> "(ite (= call#{j}_set (_ bv#{i} 8)) (tile_from_index call#{j}_index) zero)" end)
        "(define-fun call_indices#{i} () (_ BitVec #{len})\n  (bvadd #{Enum.join(call_sets, "\n         ")}))\n"
      end)

      calls_decls ++ call_identities ++ call_indices
    else [] end
    # (declare-const indices1 (_ BitVec 136))
    # (declare-const indices2 (_ BitVec 136))
    # (declare-const indices3 (_ BitVec 136))
    # (assert (= indices1 (bvadd hand_indices1 call_indices1)))
    # (assert (= indices2 (bvadd hand_indices2 call_indices2)))
    # (assert (= indices3 (bvadd hand_indices3 call_indices3)))
    # (declare-const sumindices1 (_ BitVec 4))
    # (declare-const sumindices2 (_ BitVec 4))
    # (declare-const sumindices3 (_ BitVec 4))
    # (assert (= sumindices1 (sum_digits indices1)))
    # (assert (= sumindices2 (sum_digits indices2)))
    # (assert (= sumindices3 (sum_digits indices3)))
    # (assert (= #x0 (bvand #x8 (add8_single sumindices1 (add8_single sumindices2 sumindices3)))))
    declare_indices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "(declare-const indices#{i} (_ BitVec #{len}))\n" end) end
    assert_indices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "(assert (= indices#{i} (bvadd hand_indices#{i}#{if has_calls do " call_indices#{i}" else "" end})))\n" end) end
    declare_sumindices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "(declare-const sumindices#{i} (_ BitVec 4))\n" end) end
    assert_sumindices = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "(assert (= sumindices#{i} (sum_digits indices#{i})))\n" end) end
    assert_indices_total = if Enum.empty?(all_sets) do [] else Enum.map(set_indices, fn i -> "sumindices#{i}" end) |> make_chainable("add8_single") end
    assert_indices_total = if Enum.empty?(all_sets) do "" else "(assert (= #x0 (bvand #x8 #{assert_indices_total})))\n" end

    # assert_indices = Enum.map(set_indices, fn i -> "(assert (= indices#{i} (bvadd hand_indices#{i} call_indices#{i})))\n" end)

    index_smt = declare_hand_indices ++ assert_hand_indices
             ++ declare_indices ++ assert_indices
             ++ declare_sumindices ++ assert_sumindices
             ++ [assert_indices_total]

    # assert match definitions match
    # ; example tiles for kokushi check
    # (define-fun tiles1 ((h (_ BitVec 136))) Bool
    #   ((_ at-least 13)
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000000000000000000000000000001)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000000000000000000000100000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000000000000000000001000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000000000000100000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000000000001000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000000100000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000001000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000010000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0000100000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0001000000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0010000000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x0100000000000000000000000000000000)))
    #     (nonzero (bvand h (bvmul (_ bv7 136) #x1000000000000000000000000000000000)))))
    # ; e.g. 4 sets and a pair OR 7 pairs OR kokushi
    # (assert (or
    #   (and (= (_ bv4 4) (add8_single sumindices1 sumindices2))
    #        (= (_ bv1 4) sumindices3))
    #   (and (= (_ bv0 4) sumindices1)
    #        (= (_ bv0 4) sumindices2)
    #        (= (_ bv7 4) sumindices3))
    #   (and (tiles1 hand))))
    {match_assertions, sumindices_usages, tiles_used_usages} = for match_definition <- match_definitions, reduce: {[], [], []} do
      {match_assertions, sumindices_usages, tiles_used_usages} ->
        match_definition = strip_restart(match_definition)
        unique_ix = Enum.find_index(match_definition, & &1 == "unique")
        {assertions, mentioned_set_ixs, mentioned_tiles_ixs, sumindices_assertions, tiles_used_assertions} = for {[groups, num], group_ix} <- Enum.with_index(match_definition), num > 0, reduce: {[], [], [], [], []} do
          {assertions, mentioned_set_ixs, mentioned_tiles_ixs, sumindices_assertions, tiles_used_assertions} ->
            unique = unique_ix != nil and group_ix > unique_ix
            {set_ixs, tiles_ixs} = if unique do
              ix = Enum.find_index(all_tile_groups, & &1 == {groups, num, unique})
              if ix do [{[], [1+ix]}] else [] end
            else
              groups
              |> Enum.map(&remove_group_keywords/1)
              |> Enum.map(fn group -> {group, Enum.find_index(all_sets, & &1 == group), Enum.find_index(all_tile_groups, & &1 == {group, num, unique} or &1 == {[group], num, unique})} end)
              |> Enum.flat_map(fn {_group, ix_set, ix_tile_group} -> cond do
                is_integer(ix_set) -> [{[ix_set+1], []}]
                is_integer(ix_tile_group) -> [{[], [ix_tile_group+1]}]
                true -> [] # perhaps group contains tiles not in our encoding, and so was filtered out of all_tile_groups
              end end)
            end
            |> Enum.unzip()
            set_ixs = Enum.concat(set_ixs)
            tiles_ixs = Enum.concat(tiles_ixs)
            # first take care of sets
            sumindices_assertion = if not Enum.empty?(set_ixs) do
              sum = Enum.map(set_ixs, fn i -> "sumindices#{i}" end) |> make_chainable("add8_single")
              ["(= (_ bv#{num} 4) #{sum})"]
            else [] end

            # then take care of tiles
            tiles_used_assertion = if not Enum.empty?(tiles_ixs) do
              Enum.map(tiles_ixs, fn i -> "tiles#{i}_used" end)
            else [] end

            # IO.inspect({groups, set_ixs, tiles_ixs})
            {assertions ++ sumindices_assertion ++ tiles_used_assertion,
             set_ixs ++ mentioned_set_ixs, tiles_ixs ++ mentioned_tiles_ixs,
             sumindices_assertions ++ sumindices_assertion,
             tiles_used_assertions ++ tiles_used_assertion}
        end
        # zero out unmentioned sets and tiles (big optimization)
        nonexistent_tiles_ixs = Enum.to_list(tile_group_indices) -- mentioned_tiles_ixs
        assertions = if not Enum.empty?(nonexistent_tiles_ixs) do
          sum = Enum.map(nonexistent_tiles_ixs, fn i -> "tiles#{i}_used" end) |> Enum.join(" ")
          ["(not (or #{sum}))\n    " | assertions]
        else assertions end
        nonexistent_set_ixs = Enum.to_list(set_indices) -- mentioned_set_ixs
        assertions = if not Enum.empty?(nonexistent_set_ixs) do
          sum = Enum.map(nonexistent_set_ixs, fn i -> "sumindices#{i}" end) |> make_chainable("add8_single")
          ["\n    (= (_ bv0 4) #{sum})" | assertions]
        else assertions end

        # collect all sumindices and tiles_used assertions (big optimization)
        sumindices_usages = if Enum.empty?(sumindices_assertions) do sumindices_usages else [{mentioned_set_ixs, sumindices_assertions} | sumindices_usages] end
        tiles_used_usages = if Enum.empty?(tiles_used_assertions) do sumindices_usages else [{mentioned_tiles_ixs, tiles_used_assertions} | tiles_used_usages] end
        {["\n  (and #{Enum.join(assertions, " ")})" | match_assertions], sumindices_usages, tiles_used_usages}
    end
    _sumindices_usages = Enum.uniq(sumindices_usages)
    _tiles_used_usages = Enum.uniq(tiles_used_usages)
    # optimization1 = if Enum.empty?(all_sets) do [] else ["(assert ((_ at-most 1)\n  #{Enum.map(sumindices_usages, fn {_ixs, assertions} -> "(and #{Enum.join(assertions, "\n  ")})" end) |> Enum.join("\n  ")}))\n"] end
    # optimization2 = if Enum.empty?(all_tile_groups) do [] else ["(assert ((_ at-most 1)\n  #{Enum.map(tiles_used_usages, fn {_ixs, assertions} -> "(and #{Enum.join(assertions, " ")})" end) |> Enum.join("\n  ")}))\n"] end
    # optimization3 = if Enum.empty?(all_sets) do [] else Enum.map(sumindices_usages, fn {ixs, assertions} -> "(assert (or (and #{Enum.map(ixs, fn i -> "(= (_ bv0 4) sumindices#{i})" end) |> Enum.join(" ")}) (and #{Enum.join(assertions, "\n  ")})))\n" end) end
    # max_tiles_used_usages = tiles_used_usages |> Enum.map(fn {_ixs, assertions} -> length(assertions) end) |> Enum.max(&>=/2, fn -> 0 end)
    # optimization4 = if Enum.empty?(all_tile_groups) do [] else ["(assert ((_ at-most #{max_tiles_used_usages})\n  #{Enum.map(tile_group_indices, fn i -> "tiles#{i}_used" end) |> Enum.join(" ")}))\n"] end

    optimization_call_jokers = for {call, i} <- calls, {_tile, ix} <- Enum.with_index(call), length(hand)+i*3+ix in joker_ixs do
      tile = Utils.get_joker_meld_tile({"", call}, jokers, tile_behavior)
      "(assert (= joker#{length(hand)+i*3+ix} #{to_smt_tile(tile, encoding)}))\n"
    end |> Enum.join()

    optimizations = [optimization_call_jokers] #optimization1 ++ optimization2 #++ optimization3

    match_assertions = "(assert (or#{Enum.reverse(match_assertions)}))\n"

    tile_groups = all_tile_groups
    |> Enum.with_index()
    |> Enum.map(fn {{group, num, unique}, i} -> "(declare-const tiles#{i+1} (_ BitVec #{len}))\n(declare-const tiles#{i+1}_used Bool)\n#{tile_group_assertion(i+1, encoding, len, group, num, unique)}\n" end)

    smt = Enum.join([String.replace(@boilerplate, "<len>", "#{len}"), encoding_boilerplate] ++ set_definitions ++ [to_set_fun] ++ joker_constraints ++ hand_smt ++ calls_smt ++ tile_groups ++ index_smt ++ [match_assertions] ++ optimizations)
    if Debug.print_smt() do
      IO.puts(smt)
      # IO.inspect(encoding)
    end
    {:ok, _response} = GenServer.call(solver_pid, {:query, smt, true}, 60000)
    result = obtain_all_solutions(solver_pid, encoding, encoding_r, joker_ixs)
    # IO.inspect(result)
    result
  end

  def match_hand_smt_v2(solver_pid, hand, calls, all_tiles, match_definitions, tile_behavior) do
    case RiichiAdvanced.ETSCache.get({:match_hand_smt_v2, hand, calls, all_tiles, match_definitions, TileBehavior.hash(tile_behavior)}) do
      [] -> 
        result = _match_hand_smt_v2(solver_pid, hand, calls, all_tiles, match_definitions, tile_behavior)
        RiichiAdvanced.ETSCache.put({:match_hand_smt_v2, hand, calls, all_tiles, match_definitions, TileBehavior.hash(tile_behavior)}, result)
        result
      [result] -> result
    end
  end

end