defmodule RiichiAdvanced.RiichiFuritenTest do
  use ExUnit.Case, async: true

  alias RiichiAdvanced.{GameState, LogControlState, TestUtils, Utils}

  @made ~w(7z 7z 7z 4s 5s 6s 2p 3p 4p 6z 6z)
  @before_tenpai @made ++ ~w(7p 1z)
  @other_hand ~w(1m 9m 1p 4p 8p 1s 3s 6s 8s 9s 2z 3z 5z)

  for ruleset <- ["riichi", "sanma"] do
    test "#{ruleset} permits ron after the new waits no longer include the old discard" do
      ruleset = unquote(ruleset)
      game = enter_discard_furiten(ruleset, ~w(6p) ++ after_south(ruleset) ++ ~w(7p 6z))

      discard(game, :south, "6p")
      assert_rejected_win(game, :east, "ron")
      assert GameState.calculate_wait_label(state(game), :east, :"6p", nil, nil) == "Furiten"

      discard_draws(game, after_south(ruleset))
      pass_buttons(game)
      discard(game, :east, "8p", :hand)

      pass_buttons(game)
      discard(game, :south, "6z")
      press(game, :east, "ron")
      assert :east in state(game).winner_seats
    end
  end

  test "a called-away discard blocks ron but still permits tsumo" do
    south = ~w(9p 9p 1m 9m 1p 4p 7p 1s 3s 6s 9s 2z 3z)
    game = start_game("sanma", @before_tenpai, ~w(9p 3p 8p 6p 4s 6p), %{"south" => south})

    discard(game, :east, "9p")
    press(game, :south, "pon")
    assert pass_buttons(game).players.east.pond == []
    assert Utils.strip_attrs(state(game).players.east.discards) == [:"9p"]

    discard(game, :south, "2z", :hand)
    discard_draws(game, ~w(3p))
    pass_buttons(game)
    discard(game, :east, "1z", :hand)
    pass_buttons(game)
    discard(game, :south, "6p")
    assert_rejected_win(game, :east, "ron")

    discard_draws(game, ~w(4s))
    pass_buttons(game)
    press(game, :east, "tsumo")
    assert :east in pass_buttons(game).winner_seats
  end

  test "passing ron blocks other waits until the next draw" do
    game = start_game("sanma", @made ++ ~w(7p 8p), ~w(1z 9p 6p 2s 6p))

    discard_draws(game, ~w(1z 9p))
    assert "ron" in state(game).players.east.buttons
    assert "furiten" in pass_buttons(game).players.east.status

    discard(game, :west, "6p")
    assert_rejected_win(game, :east, "ron")
    refute "furiten" in state(game).players.east.status

    discard_draws(game, ~w(2s 6p))
    press(game, :east, "ron")
    assert :east in pass_buttons(game).winner_seats
  end

  test "discard furiten also blocks chankan" do
    assert_rejected_win(chankan_position("9p"), :east, "chankan")
    control = chankan_position("1s")
    press(control, :east, "chankan")
    assert :east in pass_buttons(control).winner_seats
  end

  defp enter_discard_furiten(ruleset, remaining_draws) do
    initial_draws = ~w(9p) ++ first_lap(ruleset)
    game = start_game(ruleset, @before_tenpai, initial_draws ++ ~w(8p) ++ remaining_draws)

    discard_draws(game, initial_draws)
    pass_buttons(game)
    discard(game, :east, "1z", :hand)
    pass_buttons(game)
    game
  end

  defp chankan_position(first_discard) do
    ruleset = "riichi"
    south = ~w(6p 6p 1m 9m 1p 4p 7p 1s 3s 8s 9s 2z 3z)
    after_pon = after_south(ruleset)
    draws = [first_discard | ~w(2s 6p)] ++ after_pon ++ ~w(8p 6p)

    game = start_game(ruleset, @before_tenpai, draws, %{"south" => south})

    discard_draws(game, [first_discard | ~w(2s 6p)])
    press(game, :south, "pon")
    assert [{"pon", _}] = pass_buttons(game).players.south.calls
    discard(game, :south, "2z", :hand)
    discard_draws(game, after_pon)
    pass_buttons(game)
    discard(game, :east, "1z", :hand)
    pass_buttons(game)
    press(game, :south, "kakan")
    assert [{"kakan", _}] = state(game).players.south.calls
    game
  end

  defp first_lap("riichi"), do: ~w(2s 5s 2m)
  defp first_lap("sanma"), do: ~w(2s 5s)
  defp after_south("riichi"), do: ~w(3p 6m)
  defp after_south("sanma"), do: ~w(3p)

  defp start_game(ruleset, east, draws, other_hands \\ %{}) do
    seats = if ruleset == "sanma", do: ~w(south west), else: ~w(south west north)

    hands =
      Map.new(seats, &{&1, @other_hand})
      |> Map.put("east", east)
      |> Map.merge(other_hands)

    config =
      Jason.encode!(%{
        "starting_hand" => hands,
        "starting_draws" => draws,
        "starting_dice" => [2, 3]
      })

    %{game_state_pid: game} =
      TestUtils.initialize_test_state(
        ruleset,
        ~w(dora kandora ura cancellable_riichi),
        [],
        config
      )

    on_exit(fn -> GenServer.cast(game, :terminate_game) end)

    game
  end

  defp state(game), do: GenServer.call(game, :get_state, 15_000)

  defp discard_draws(game, draws) do
    for tile <- draws do
      pass_buttons(game)
      discard(game, state(game).turn, tile)
    end
  end

  defp discard(game, seat, tile, source \\ :draw) do
    current = state(game)
    assert seat == current.turn
    player = current.players[seat]
    pool = Map.fetch!(player, source)
    index = Enum.find_index(pool, &(Utils.strip_attrs(&1) == Utils.to_tile(tile)))
    assert index != nil, "expected #{seat} to have #{tile} in #{source}"
    offset = if source == :draw, do: length(player.hand), else: 0
    GenServer.cast(game, {:play_tile, seat, offset + index})
    updated = state(game).players[seat].discards
    assert length(updated) == length(player.discards) + 1
    assert Utils.strip_attrs(List.last(updated)) == Utils.to_tile(tile)
  end

  defp pass_buttons(game) do
    snapshot = state(game)
    LogControlState.skip_buttons(%{game_state_pid: game, game_state: snapshot}, snapshot.turn)
    state(game)
  end

  defp press(game, seat, button) do
    assert button in state(game).players[seat].buttons
    GenServer.cast(game, {:press_button, seat, button})
    state(game)
  end

  defp assert_rejected_win(game, seat, button) do
    offered? = button in state(game).players[seat].buttons
    GenServer.cast(game, {:press_button, seat, button})
    refute seat in pass_buttons(game).winner_seats, "server accepted #{button} while in furiten"
    refute offered?, "server offered #{button} while in furiten"
  end
end
