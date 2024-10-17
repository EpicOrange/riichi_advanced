defmodule RiichiAdvanced.SMT do
  @print_smt true

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
      length(result) >= 100  -> result
      true ->
        contra = if last_assignment == nil do "" else Enum.map(joker_ixs, fn i -> "(equal_digits joker#{i} #{to_smt_tile(last_assignment[i], encoding)})" end) end
        contra = if last_assignment == nil do "" else "(assert (not (and #{Enum.join(contra, " ")})))\n" end
        query = "(get-value (#{Enum.join(Enum.map(joker_ixs, fn i -> "joker#{i}" end), " ")}))\n"
        smt = Enum.join([contra, "(check-sat)\n", query])
        if @print_smt do
          IO.puts(smt)
        end
        {:ok, response} = GenServer.call(solver_pid, {:query, smt, false}, 5000)
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
    equal_digits = """
    (define-fun equal_digits ((left (_ BitVec #{len})) (right (_ BitVec #{len}))) Bool
      (and
        #{Enum.join(equal_calls, "\n    ")}))
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

  def match_hand_smt_v2(solver_pid, hand, calls, all_tiles, match_definitions, ordering, tile_mappings \\ %{}) do
    calls = calls
    |> Enum.reject(fn {call_name, _call} -> call_name in ["flower", "start_flower", "start_joker"] end)
    |> Enum.with_index()
    |> Enum.map(fn {call, i} -> {Enum.take(Riichi.call_to_tiles(call), 3), i} end) # ignore kans

    # IO.puts("Hand to be encoded into SMT is #{inspect(hand)}")
    # IO.puts("Calls to be encoded into SMT is #{inspect(calls)}")
    jokers = Map.keys(tile_mappings)
    all_tiles = all_tiles
    |> Enum.uniq()
    |> Enum.reject(fn tile -> tile in jokers && tile not in tile_mappings[tile] end)
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
    all_sets = match_definitions
    |> Enum.concat()
    |> Enum.reject(&Kernel.is_binary/1)
    |> Enum.map(fn [groups, _num] -> groups end)
    |> Enum.concat()
    |> Enum.filter(fn group -> is_list(group) && is_integer(Enum.at(group, 0)) end)
    |> Enum.uniq() # [[0, 0], [0, 1, 2], [0, 0, 0]]
    set_definitions = all_sets
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.map(&Map.values/1)
    |> Enum.map(&Enum.reverse/1) # [[2], [1, 1, 1], [3]]
    |> Enum.map(fn vals -> Enum.map(vals, fn a -> Integer.to_string(a) end) end)
    |> Enum.map(&Enum.join/1) # ["2", "111", "3"]
    |> Enum.with_index()
    |> Enum.map(fn {str, i} -> "(define-fun set#{i+1} () (_ BitVec #{len}) #x#{String.pad_leading(str, Integer.floor_div(len, 4), "0")})\n" end)
    to_set_fun = 1..length(all_sets)
    |> Enum.map(fn i -> "\n  (ite (= num (_ bv#{i} 8)) set#{i}" end)
    to_set_fun = "(define-fun to_set ((num (_ BitVec 8))) (_ BitVec #{len})" <> Enum.join(to_set_fun) <> " zero)" <> String.duplicate(")", length(all_sets)) <> "\n"

    # first figure out which tiles are jokers based on tile_mappings
    call_tiles = Enum.flat_map(calls, fn {call, _i} -> call end)
    {joker_ixs, joker_constraints} = hand ++ call_tiles
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _ix} -> Map.has_key?(tile_mappings, tile) end)
    |> Enum.map(fn {tile, ix} ->
      joker_choices = tile_mappings[tile]
      |> Enum.map(fn tile2 -> "(= joker#{ix} #{to_smt_tile(tile2, encoding)})" end)
      |> Enum.join("\n            ")
      {ix, "(declare-const joker#{ix} (_ BitVec #{len}))\n(assert (or #{joker_choices}))\n"}
    end)
    |> Enum.unzip()

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
    # (assert (or
    #   (equal_digits hand (bvadd
    #     (bvmul hand_indices1 set1)
    #     (bvmul hand_indices2 set2)
    #     (bvmul hand_indices3 set3)))
    #   (equal_digits zero (bvadd hand_indices1 hand_indices2 hand_indices3))))
    declare_hand_indices = Enum.map(1..length(all_sets), fn i -> "(declare-const hand_indices#{i} (_ BitVec #{len}))\n" end)
    hand_indices = Enum.map(1..length(all_sets), fn i -> "\n    (shift_set hand_indices#{i} set#{i})" end) |> Enum.join()
    assert_hand_indices = ["(assert (or\n  (equal_digits hand (bvadd#{hand_indices}))\n  (equal_digits zero (bvadd#{Enum.map(1..length(all_sets), fn i -> " hand_indices#{i}" end)}))))\n"]

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
          |> Enum.take(3) # ignore kans
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
      call_indices = Enum.map(1..length(all_sets), fn i ->
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
    declare_indices = Enum.map(1..length(all_sets), fn i -> "(declare-const indices#{i} (_ BitVec #{len}))\n" end)
    assert_indices = Enum.map(1..length(all_sets), fn i -> "(assert (= indices#{i} (bvadd hand_indices#{i}#{if has_calls do " call_indices#{i}" else "" end})))\n" end)
    declare_sumindices = Enum.map(1..length(all_sets), fn i -> "(declare-const sumindices#{i} (_ BitVec 4))\n" end)
    assert_sumindices = Enum.map(1..length(all_sets), fn i -> "(assert (= sumindices#{i} (sum_digits indices#{i})))\n" end)
    assert_indices_total = Enum.map(1..length(all_sets), fn i -> "sumindices#{i}" end) |> make_chainable("add8_single")
    assert_indices_total = "(assert (= #x0 (bvand #x8 #{assert_indices_total})))\n"
    # assert_indices = Enum.map(1..length(all_sets), fn i -> "(assert (= indices#{i} (bvadd hand_indices#{i} call_indices#{i})))\n" end)

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
    {match_assertions, tile_groups} = for match_definition <- match_definitions, reduce: {[], []} do
      {match_assertions, tile_groups} ->
        {assertions, mentioned_set_ixs, tile_groups} = for [groups, num] <- match_definition, reduce: {[], [], tile_groups} do
          {assertions, mentioned_set_ixs, tile_groups} ->
            {set_ixs, tiles} = groups
            |> Enum.map(fn group -> {group, Enum.find_index(all_sets, fn set -> set == group end)} end)
            |> Enum.map(fn {group, ix} -> if is_integer(ix) do ix+1 else
              if is_binary(group) do Utils.to_tile(group) else Enum.map(group, &Utils.to_tile/1) end
            end end)
            |> Enum.split_with(fn i -> is_integer(i) end)
            # first take care of sets
            assertions = if not Enum.empty?(set_ixs) do
              sum = Enum.map(set_ixs, fn i -> "sumindices#{i}" end) |> make_chainable("add8_single")
              if num < 0 do
                ["\n    (bvult (_ bv#{-num} 4) #{sum})" | assertions]
              else
                ["\n    (= (_ bv#{num} 4) #{sum})" | assertions]
              end
            else assertions end

            # then take care of tiles
            {assertions, tile_groups} = if not Enum.empty?(tiles) do
              {["\n    (tiles#{length(tile_groups)} hand)" | assertions], tile_groups ++ [{Enum.map(tiles, &to_smt_tile(&1, encoding)), num}]}
            else {assertions, tile_groups} end
            # IO.inspect({groups, set_ixs, tiles})
            {assertions, set_ixs ++ mentioned_set_ixs, tile_groups}
        end
        # zero out unmentioned sets (big optimization)
        nonexistent_set_ixs = Enum.reject(1..length(all_sets), fn i -> Enum.member?(mentioned_set_ixs, i) end)
        assertions = if not Enum.empty?(nonexistent_set_ixs) do
          sum = Enum.map(nonexistent_set_ixs, fn i -> "sumindices#{i}" end) |> make_chainable("add8_single")
          ["\n    (= (_ bv0 4) #{sum})" | assertions]
        else assertions end
        {["\n  (and #{Enum.join(assertions, " ")})" | match_assertions], tile_groups}
    end
    match_assertions = "(assert (or#{match_assertions}))\n"
    # IO.inspect(tile_groups)

    # TODO tile_groups
    tile_groups = tile_groups |> Enum.with_index() |> Enum.map(fn {{group, num}, i} -> "(define-fun tiles#{i} ((h (_ BitVec #{len}))) Bool\n  ((_ at-least #{num})\n#{Enum.map(group, fn tiles -> "    (nonzero (bvand h (bvmul (_ bv7 #{len}) #{tiles})))" end) |> Enum.join("\n")}))\n" end)

    smt = Enum.join([String.replace(@boilerplate, "<len>", "#{len}"), encoding_boilerplate] ++ set_definitions ++ [to_set_fun] ++ joker_constraints ++ hand_smt ++ calls_smt ++ tile_groups ++ index_smt ++ [match_assertions])
    if @print_smt do
      IO.puts(smt)
      # IO.inspect(encoding)
    end
    {:ok, _response} = GenServer.call(solver_pid, {:query, smt, true}, 5000)
    result = obtain_all_solutions(solver_pid, encoding, encoding_r, joker_ixs)
    # IO.inspect(result)
    result
  end

end