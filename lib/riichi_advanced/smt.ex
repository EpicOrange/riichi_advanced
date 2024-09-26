defmodule RiichiAdvanced.SMT do
  @print_smt true

  @boilerplate """
               (set-logic QF_FD)
               (define-fun zero () (_ BitVec 136) (_ bv0 136))
               (define-fun add8_single ((left (_ BitVec 4)) (right (_ BitVec 4))) (_ BitVec 4)
                 (bvor (bvand #x8 left) (bvand #x8 right) (bvadd (bvand #x7 left) (bvand #x7 right))))
               (define-fun octal_mask () (_ BitVec 136) #x7777777777777777777777777777777777)
               (define-fun carry_mask () (_ BitVec 136) #x8888888888888888888888888888888888)
               (define-fun add8 ((left (_ BitVec 136)) (right (_ BitVec 136))) (_ BitVec 136)
                 (bvor (bvand carry_mask left) (bvand carry_mask right) (bvadd (bvand octal_mask left) (bvand octal_mask right))))
               (define-fun fold_digits ((shift (_ BitVec 136)) (bv (_ BitVec 136))) (_ BitVec 136)
                 (bvand (bvsub (bvshl (_ bv1 136) shift) (_ bv1 136)) (add8 bv (bvlshr bv shift))))
               (define-fun sum_digits ((bv (_ BitVec 136))) (_ BitVec 4)
                 ((_ extract 3 0)
                   (fold_digits (_ bv4 136)
                   (fold_digits (_ bv8 136)
                   (fold_digits (_ bv12 136)
                   (fold_digits (_ bv20 136)
                   (fold_digits (_ bv36 136)
                   (fold_digits (_ bv68 136) bv))))))))
               (define-fun equal_digits ((left (_ BitVec 136)) (right (_ BitVec 136))) Bool
                 (and
                   (= ((_ extract 135 132) left) ((_ extract 135 132) right))
                   (= ((_ extract 131 128) left) ((_ extract 131 128) right))
                   (= ((_ extract 127 124) left) ((_ extract 127 124) right))
                   (= ((_ extract 123 120) left) ((_ extract 123 120) right))
                   (= ((_ extract 119 116) left) ((_ extract 119 116) right))
                   (= ((_ extract 115 112) left) ((_ extract 115 112) right))
                   (= ((_ extract 111 108) left) ((_ extract 111 108) right))
                   (= ((_ extract 107 104) left) ((_ extract 107 104) right))
                   (= ((_ extract 103 100) left) ((_ extract 103 100) right))
                   (= ((_ extract 99 96) left) ((_ extract 99 96) right))
                   (= ((_ extract 95 92) left) ((_ extract 95 92) right))
                   (= ((_ extract 91 88) left) ((_ extract 91 88) right))
                   (= ((_ extract 87 84) left) ((_ extract 87 84) right))
                   (= ((_ extract 83 80) left) ((_ extract 83 80) right))
                   (= ((_ extract 79 76) left) ((_ extract 79 76) right))
                   (= ((_ extract 75 72) left) ((_ extract 75 72) right))
                   (= ((_ extract 71 68) left) ((_ extract 71 68) right))
                   (= ((_ extract 67 64) left) ((_ extract 67 64) right))
                   (= ((_ extract 63 60) left) ((_ extract 63 60) right))
                   (= ((_ extract 59 56) left) ((_ extract 59 56) right))
                   (= ((_ extract 55 52) left) ((_ extract 55 52) right))
                   (= ((_ extract 51 48) left) ((_ extract 51 48) right))
                   (= ((_ extract 47 44) left) ((_ extract 47 44) right))
                   (= ((_ extract 43 40) left) ((_ extract 43 40) right))
                   (= ((_ extract 39 36) left) ((_ extract 39 36) right))
                   (= ((_ extract 35 32) left) ((_ extract 35 32) right))
                   (= ((_ extract 31 28) left) ((_ extract 31 28) right))
                   (= ((_ extract 27 24) left) ((_ extract 27 24) right))
                   (= ((_ extract 23 20) left) ((_ extract 23 20) right))
                   (= ((_ extract 19 16) left) ((_ extract 19 16) right))
                   (= ((_ extract 15 12) left) ((_ extract 15 12) right))
                   (= ((_ extract 11 8) left) ((_ extract 11 8) right))
                   (= ((_ extract 7 4) left) ((_ extract 7 4) right))
                   (= ((_ extract 3 0) left) ((_ extract 3 0) right))))
               (define-fun at_least_digits ((left (_ BitVec 136)) (right (_ BitVec 136))) Bool
                 (and
                   (bvuge ((_ extract 135 132) left) ((_ extract 135 132) right))
                   (bvuge ((_ extract 131 128) left) ((_ extract 131 128) right))
                   (bvuge ((_ extract 127 124) left) ((_ extract 127 124) right))
                   (bvuge ((_ extract 123 120) left) ((_ extract 123 120) right))
                   (bvuge ((_ extract 119 116) left) ((_ extract 119 116) right))
                   (bvuge ((_ extract 115 112) left) ((_ extract 115 112) right))
                   (bvuge ((_ extract 111 108) left) ((_ extract 111 108) right))
                   (bvuge ((_ extract 107 104) left) ((_ extract 107 104) right))
                   (bvuge ((_ extract 103 100) left) ((_ extract 103 100) right))
                   (bvuge ((_ extract 99 96) left) ((_ extract 99 96) right))
                   (bvuge ((_ extract 95 92) left) ((_ extract 95 92) right))
                   (bvuge ((_ extract 91 88) left) ((_ extract 91 88) right))
                   (bvuge ((_ extract 87 84) left) ((_ extract 87 84) right))
                   (bvuge ((_ extract 83 80) left) ((_ extract 83 80) right))
                   (bvuge ((_ extract 79 76) left) ((_ extract 79 76) right))
                   (bvuge ((_ extract 75 72) left) ((_ extract 75 72) right))
                   (bvuge ((_ extract 71 68) left) ((_ extract 71 68) right))
                   (bvuge ((_ extract 67 64) left) ((_ extract 67 64) right))
                   (bvuge ((_ extract 63 60) left) ((_ extract 63 60) right))
                   (bvuge ((_ extract 59 56) left) ((_ extract 59 56) right))
                   (bvuge ((_ extract 55 52) left) ((_ extract 55 52) right))
                   (bvuge ((_ extract 51 48) left) ((_ extract 51 48) right))
                   (bvuge ((_ extract 47 44) left) ((_ extract 47 44) right))
                   (bvuge ((_ extract 43 40) left) ((_ extract 43 40) right))
                   (bvuge ((_ extract 39 36) left) ((_ extract 39 36) right))
                   (bvuge ((_ extract 35 32) left) ((_ extract 35 32) right))
                   (bvuge ((_ extract 31 28) left) ((_ extract 31 28) right))
                   (bvuge ((_ extract 27 24) left) ((_ extract 27 24) right))
                   (bvuge ((_ extract 23 20) left) ((_ extract 23 20) right))
                   (bvuge ((_ extract 19 16) left) ((_ extract 19 16) right))
                   (bvuge ((_ extract 15 12) left) ((_ extract 15 12) right))
                   (bvuge ((_ extract 11 8) left) ((_ extract 11 8) right))
                   (bvuge ((_ extract 7 4) left) ((_ extract 7 4) right))
                   (bvuge ((_ extract 3 0) left) ((_ extract 3 0) right))))
               (define-fun tile_from_index ((ix (_ BitVec 8))) (_ BitVec 136)
                 (bvshl (_ bv1 136) (concat (_ bv0 128) (bvshl ix (_ bv2 8)))))
               (define-fun is_set_num ((num (_ BitVec 8))) Bool
                 (and (bvule (_ bv1 8) num) (bvule num (_ bv3 8))))
               """

  def to_smt_tile(tile, ix \\ -1, joker_ixs \\ %{}) do
    if is_list(tile) do
      smt_tile_list = for t <- tile, do: to_smt_tile(t, ix, joker_ixs)
      "(bvadd #{Enum.join(smt_tile_list, " ")})"
    else
      if ix in joker_ixs do
        "joker#{ix}"
      else
        case tile do
          :"1m" -> "#x0000000000000000000000000000000001"
          :"2m" -> "#x0000000000000000000000000000000010"
          :"3m" -> "#x0000000000000000000000000000000100"
          :"4m" -> "#x0000000000000000000000000000001000"
          :"5m" -> "#x0000000000000000000000000000010000"
          :"0m" -> "#x0000000000000000000000000000010000"
          :"6m" -> "#x0000000000000000000000000000100000"
          :"7m" -> "#x0000000000000000000000000001000000"
          :"8m" -> "#x0000000000000000000000000010000000"
          :"9m" -> "#x0000000000000000000000000100000000"
          :"1p" -> "#x0000000000000000000000001000000000"
          :"2p" -> "#x0000000000000000000000010000000000"
          :"3p" -> "#x0000000000000000000000100000000000"
          :"4p" -> "#x0000000000000000000001000000000000"
          :"5p" -> "#x0000000000000000000010000000000000"
          :"0p" -> "#x0000000000000000000010000000000000"
          :"6p" -> "#x0000000000000000000100000000000000"
          :"7p" -> "#x0000000000000000001000000000000000"
          :"8p" -> "#x0000000000000000010000000000000000"
          :"9p" -> "#x0000000000000000100000000000000000"
          :"1s" -> "#x0000000000000001000000000000000000"
          :"2s" -> "#x0000000000000010000000000000000000"
          :"3s" -> "#x0000000000000100000000000000000000"
          :"4s" -> "#x0000000000001000000000000000000000"
          :"5s" -> "#x0000000000010000000000000000000000"
          :"0s" -> "#x0000000000010000000000000000000000"
          :"6s" -> "#x0000000000100000000000000000000000"
          :"7s" -> "#x0000000001000000000000000000000000"
          :"8s" -> "#x0000000010000000000000000000000000"
          :"9s" -> "#x0000000100000000000000000000000000"
          :"1z" -> "#x0000001000000000000000000000000000"
          :"2z" -> "#x0000010000000000000000000000000000"
          :"3z" -> "#x0000100000000000000000000000000000"
          :"4z" -> "#x0001000000000000000000000000000000"
          :"0z" -> "#x0010000000000000000000000000000000"
          :"6z" -> "#x0100000000000000000000000000000000"
          :"7z" -> "#x1000000000000000000000000000000000"
          _ ->
            IO.puts("Unhandled smt tile #{inspect(tile)}")
            "#x0000000000000000000000000000000000"
        end
      end
    end
  end

  def from_smt_tile(smt_tile) do
    case smt_tile do
      0x0000000000000000000000000000000001 -> :"1m"
      0x0000000000000000000000000000000010 -> :"2m"
      0x0000000000000000000000000000000100 -> :"3m"
      0x0000000000000000000000000000001000 -> :"4m"
      0x0000000000000000000000000000010000 -> :"5m"
      0x0000000000000000000000000000100000 -> :"6m"
      0x0000000000000000000000000001000000 -> :"7m"
      0x0000000000000000000000000010000000 -> :"8m"
      0x0000000000000000000000000100000000 -> :"9m"
      0x0000000000000000000000001000000000 -> :"1p"
      0x0000000000000000000000010000000000 -> :"2p"
      0x0000000000000000000000100000000000 -> :"3p"
      0x0000000000000000000001000000000000 -> :"4p"
      0x0000000000000000000010000000000000 -> :"5p"
      0x0000000000000000000100000000000000 -> :"6p"
      0x0000000000000000001000000000000000 -> :"7p"
      0x0000000000000000010000000000000000 -> :"8p"
      0x0000000000000000100000000000000000 -> :"9p"
      0x0000000000000001000000000000000000 -> :"1s"
      0x0000000000000010000000000000000000 -> :"2s"
      0x0000000000000100000000000000000000 -> :"3s"
      0x0000000000001000000000000000000000 -> :"4s"
      0x0000000000010000000000000000000000 -> :"5s"
      0x0000000000100000000000000000000000 -> :"6s"
      0x0000000001000000000000000000000000 -> :"7s"
      0x0000000010000000000000000000000000 -> :"8s"
      0x0000000100000000000000000000000000 -> :"9s"
      0x0000001000000000000000000000000000 -> :"1z"
      0x0000010000000000000000000000000000 -> :"2z"
      0x0000100000000000000000000000000000 -> :"3z"
      0x0001000000000000000000000000000000 -> :"4z"
      0x0010000000000000000000000000000000 -> :"0z"
      0x0100000000000000000000000000000000 -> :"6z"
      0x1000000000000000000000000000000000 -> :"7z"
      _ ->
        IO.puts("Unhandled smt tile #{inspect(smt_tile)}")
        :"1m"
    end
  end

  def make_chainable(args, fun) do
    Enum.reduce(args, fn arg, acc -> "(#{fun} #{arg} #{acc})" end)
  end

  def obtain_all_solutions(solver_pid, joker_ixs, last_assignment \\ nil, result \\ []) do
    if length(joker_ixs) == 0 do
      [%{}]
    else
      contra = if last_assignment == nil do "" else Enum.map(joker_ixs, fn i -> "(equal_digits joker#{i} #{to_smt_tile(last_assignment[i])})" end) end
      contra = if last_assignment == nil do "" else "(assert (not (and #{Enum.join(contra, " ")})))\n" end
      query = "(get-value (#{Enum.join(Enum.map(joker_ixs, fn i -> "joker#{i}" end), " ")}))\n"
      smt = Enum.join([contra, "(check-sat)\n", query])
      if @print_smt do
        IO.puts(smt)
      end
      {:ok, response} = GenServer.call(solver_pid, {:query, [smt], false}, 5000)
      case ExSMT.Solver.ResponseParser.parse(response) do
        [:sat | assigns] ->
          new_assignment = Map.new(Enum.zip(joker_ixs, Enum.flat_map(assigns, &Enum.map(&1, fn [_, val] -> from_smt_tile(val) end))))
          obtain_all_solutions(solver_pid, joker_ixs, new_assignment, [new_assignment | result])
        [:unsat | _] -> result
      end
    end
  end

  def match_hand_smt_v2(solver_pid, hand, calls, match_definitions, tile_mappings \\ %{}) do
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
    |> Enum.map(fn {str, i} -> "(define-fun set#{i+1} () (_ BitVec 136) #x#{String.pad_leading(str, 34, "0")})\n" end)
    to_set_fun = 1..length(all_sets)
    |> Enum.map(fn i -> "\n  (ite (= num (_ bv#{i} 8)) set#{i}" end)
    to_set_fun = "(define-fun to_set ((num (_ BitVec 8))) (_ BitVec 136)" <> Enum.join(to_set_fun) <> " zero)" <> String.duplicate(")", length(all_sets)) <> "\n"

    calls = calls
    |> Enum.reject(fn {call_name, _call} -> call_name in ["flower", "start_flower", "start_joker"] end)
    |> Enum.with_index()
    |> Enum.map(fn {call, i} -> {Enum.take(Riichi.call_to_tiles(call), 3), i} end) # ignore kans
    IO.inspect(calls)

    # first figure out which tiles are jokers based on tile_mappings
    call_tiles = Enum.flat_map(calls, fn {call, _i} -> call end)
    {joker_ixs, joker_constraints} = hand ++ call_tiles
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _ix} -> Map.has_key?(tile_mappings, tile) end)
    |> Enum.map(fn {tile, ix} ->
      joker_choices = tile_mappings[tile]
      |> Enum.map(fn tile2 -> "(= joker#{ix} #{to_smt_tile(tile2)})" end)
      |> Enum.join("\n            ")
      {ix, "(declare-const joker#{ix} (_ BitVec 136))\n(assert (or #{joker_choices}))\n"}
    end)
    |> Enum.unzip()

    # hand part 2: declare hand
    # (declare-const hand (_ BitVec 136))
    # (assert (= hand (bvadd #x0001100001110000000200000000000000 joker1)))
    hand_smt = hand
    |> Enum.with_index()
    |> Enum.map(fn {tile, ix} -> "#{to_smt_tile(tile, ix, joker_ixs)}\n                       " end)
    hand_smt = ["(declare-const hand (_ BitVec 136))\n(assert (= hand (bvadd #{Enum.join(hand_smt)})))\n"]
    
    # hand part 2: declare variables for hand indices
    # (declare-const hand_indices1 (_ BitVec 136))
    # (declare-const hand_indices2 (_ BitVec 136))
    # (declare-const hand_indices3 (_ BitVec 136))
    # (assert (equal_digits hand (bvadd
    #   (bvmul hand_indices1 set1)
    #   (bvmul hand_indices2 set2)
    #   (bvmul hand_indices3 set3))))
    declare_hand_indices = Enum.map(1..length(all_sets), fn i -> "(declare-const hand_indices#{i} (_ BitVec 136))\n" end)
    hand_indices = Enum.map(1..length(all_sets), fn i -> "\n  (bvmul hand_indices#{i} set#{i})" end) |> Enum.join()
    assert_hand_indices = ["(assert (equal_digits hand (bvadd#{hand_indices})))\n"]

    IO.inspect(Enum.zip(joker_ixs, joker_constraints))

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
          |> Enum.map(fn {tile, ix} -> "#{to_smt_tile(tile, length(hand)+i*3+ix, joker_ixs)}" end)
          calls_decls ++ ["(declare-const call#{i+1} (_ BitVec 136))\n(assert (= call#{i+1} (bvadd #{Enum.join(call_smt, "\n                        ")})))\n"]
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
        (assert (equal_digits call#{i} (bvmul (tile_from_index call#{i}_index) (to_set call#{i}_set))))
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
        "(define-fun call_indices#{i} () (_ BitVec 136)\n  (bvadd #{Enum.join(call_sets, "\n         ")}))\n"
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
    declare_indices = Enum.map(1..length(all_sets), fn i -> "(declare-const indices#{i} (_ BitVec 136))\n" end)
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
    # (declare-const tiles1 (_ BitVec 136))
    # (assert (or
    #   (= tiles1 #x0000000000000000000000000000000001)
    #   (= tiles1 #x0000000000000000000000000100000000)
    #   (= tiles1 #x0000000000000000000000001000000000)
    #   (= tiles1 #x0000000000000000100000000000000000)
    #   (= tiles1 #x0000000000000001000000000000000000)
    #   (= tiles1 #x0000000100000000000000000000000000)
    #   (= tiles1 #x0000001000000000000000000000000000)
    #   (= tiles1 #x0000010000000000000000000000000000)
    #   (= tiles1 #x0000100000000000000000000000000000)
    #   (= tiles1 #x0001000000000000000000000000000000)
    #   (= tiles1 #x0010000000000000000000000000000000)
    #   (= tiles1 #x0100000000000000000000000000000000)
    #   (= tiles1 #x1000000000000000000000000000000000)))
    # ; e.g. 4 sets and a pair OR 7 pairs OR kokushi
    # (assert (or
    #   (and (= (_ bv4 4) (add8_single sumindices1 sumindices2))
    #        (= (_ bv1 4) sumindices3))
    #   (and (= (_ bv0 4) sumindices1)
    #        (= (_ bv0 4) sumindices2)
    #        (= (_ bv7 4) sumindices3))
    #   (and (equal_digits hand (bvadd tiles1 #x1111111100000001100000001100000001)))))
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
              ["\n    (= (_ bv#{num} 4) #{sum})" | assertions]
            else assertions end

            # then take care of tiles
            {assertions, tile_groups} = if not Enum.empty?(tiles) do
              {["\n    (equal_digits hand (bvmul (_ bv#{num} 136) tiles#{length(tile_groups)}))" | assertions], tile_groups ++ [Enum.map(tiles, &to_smt_tile/1)]}
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
    declare_tile_groups = Enum.map(0..length(tile_groups)-1, fn i -> "(declare-const tiles#{i} (_ BitVec 136))\n" end)
    assert_tile_groups = tile_groups |> Enum.with_index() |> Enum.map(fn {group, i} -> "(assert (or\n#{Enum.map(group, fn tiles -> "  (= tiles#{i} #{tiles})" end) |> Enum.join("\n")}))\n" end)

    smt = Enum.join([@boilerplate] ++ set_definitions ++ [to_set_fun] ++ joker_constraints ++ hand_smt ++ calls_smt ++ [declare_tile_groups, assert_tile_groups] ++ index_smt ++ [match_assertions])
    if @print_smt do
      IO.puts(smt)
    end
    {:ok, _response} = GenServer.call(solver_pid, {:query, [smt], true}, 5000)
    result = obtain_all_solutions(solver_pid, joker_ixs)
    # IO.inspect(result)
    result
  end

end