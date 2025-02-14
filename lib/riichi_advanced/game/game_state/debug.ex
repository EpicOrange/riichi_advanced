
defmodule RiichiAdvanced.GameState.Debug do
  alias RiichiAdvanced.Utils, as: Utils

  @debug false
  @debug_status false
  @debug_fast_ai false
  @debug_saki_card_ours nil
  @debug_saki_card_opponent nil
  @debug_am_match_definitions []
  @debug_actions false
  @debug_buttons false
  @debug_conditions true
  @debug_ai false
  @debug_log true
  @debug_tutorial false
  @print_mods false
  @print_smt false
  @skip_ruleset_caching false

  def debug, do: @debug
  def debug_status, do: @debug_status
  def debug_fast_ai, do: @debug_fast_ai
  def debug_saki_card_ours, do: @debug_saki_card_ours
  def debug_saki_card_opponent, do: @debug_saki_card_opponent
  def debug_am_match_definitions, do: @debug_am_match_definitions
  def debug_actions, do: @debug_actions
  def debug_buttons, do: @debug_buttons
  def debug_conditions, do: @debug_conditions
  def debug_ai, do: @debug_ai
  def debug_log, do: @debug_log
  def print_smt, do: @print_smt
  def skip_ruleset_caching, do: @skip_ruleset_caching
  @print_wins false
  def debug, do: Process.get(:ignore_type_error, @debug)
  def debug_status, do: Process.get(:ignore_type_error, @debug_status)
  def debug_fast_ai, do: Process.get(:ignore_type_error, @debug_fast_ai)
  def debug_saki_card_ours, do: Process.get(:ignore_type_error, @debug_saki_card_ours)
  def debug_saki_card_opponent, do: Process.get(:ignore_type_error, @debug_saki_card_opponent)
  def debug_am_match_definitions, do: Process.get(:ignore_type_error, @debug_am_match_definitions)
  def debug_actions, do: Process.get(:ignore_type_error, @debug_actions)
  def debug_buttons, do: Process.get(:ignore_type_error, @debug_buttons)
  def debug_conditions, do: Process.get(:ignore_type_error, @debug_conditions)
  def debug_ai, do: Process.get(:ignore_type_error, @debug_ai)
  def debug_log, do: Process.get(:ignore_type_error, @debug_log)
  def debug_tutorial, do: Process.get(:ignore_type_error, @debug_tutorial)
  def print_mods, do: Process.get(:ignore_type_error, @print_mods)
  def print_smt, do: Process.get(:ignore_type_error, @print_smt)
  def print_wins, do: Process.get(:ignore_type_error, @print_wins)
  def skip_ruleset_caching, do: Process.get(:ignore_type_error, @skip_ruleset_caching)

  def set_wall(wall) do
    # wall = List.replace_at(wall, 52, :"2s") # first draw
    # wall = List.replace_at(wall, 53, :"2p")
    # wall = List.replace_at(wall, 54, :"5m")
    # wall = List.replace_at(wall, 55, :"7m")
    # wall = List.replace_at(wall, 56, :"1z") # second draw
    # wall = List.replace_at(wall, 57, :"1m")
    # wall = List.replace_at(wall, 58, :"1m")
    # wall = List.replace_at(wall, 59, :"1m")
    # wall = List.replace_at(wall, 60, :"9m") # third draw
    # wall = List.replace_at(wall, 61, :"7p")
    # wall = List.replace_at(wall, 62, :"7p")
    # wall = List.replace_at(wall, 63, :"7p")
    # wall = List.replace_at(wall, 64, :"7p") # fourth draw
    # wall = List.replace_at(wall, 65, :"7p")
    # wall = List.replace_at(wall, 66, :"7p")
    # wall = List.replace_at(wall, 67, :"7p")
    # wall = List.replace_at(wall, 68, :"7p") # fifth draw
    # wall = List.replace_at(wall, 80, :"7p") # seventh draw
    # wall = List.replace_at(wall, -15, :"1m") # last draw
    # wall = List.replace_at(wall, 48, :"2m") # first draw (shouhai)
    # wall = List.replace_at(wall, 49, :"3m")
    # wall = List.replace_at(wall, 50, :"4m")
    # wall = List.replace_at(wall, 51, :"5m")
    # wall = List.replace_at(wall, 52, :"10s") # second draw (shouhai)
    # wall = List.replace_at(wall, 64, :"1j") # first draw (taiwanese)
    # wall = List.replace_at(wall, 65, :"1j")
    # wall = List.replace_at(wall, 66, :"1j")
    # wall = List.replace_at(wall, 67, :"8m")
    # wall = List.replace_at(wall, 68, :"8m") # second draw (taiwanese)
    # wall = List.replace_at(wall, 69, :"5m")
    # wall = List.replace_at(wall, 70, :"8m")
    # wall = List.replace_at(wall, 71, :"8m")
    # wall = List.replace_at(wall, 72, :"8m") # third draw (taiwanese)
    # wall = List.replace_at(wall, 73, :"8m")
    # wall = List.replace_at(wall, 74, :"8m")
    # wall = List.replace_at(wall, 75, :"8m")
    # wall = List.replace_at(wall, 76, :"8m") # fourth draw (taiwanese)
    # wall = List.replace_at(wall, 77, :"8m")
    # wall = List.replace_at(wall, 78, :"8m")
    # wall = List.replace_at(wall, 79, :"8m")
    # wall = List.replace_at(wall, 80, :"8m") # fifth draw (taiwanese)
    # wall = List.replace_at(wall, 81, :"8m")
    # wall = List.replace_at(wall, 82, :"8m")
    # wall = List.replace_at(wall, 83, :"8m")
    # wall = List.replace_at(wall, -6, :"6m") # first dora indicator
    # wall = List.replace_at(wall, -8, :"2p") # second dora indicator
    # wall = List.replace_at(wall, -10, :"8s") # third dora indicator
    # wall = List.replace_at(wall, -12, :"2p") # fourth dora indicator
    # wall = List.replace_at(wall, -14, :"2p") # fifth dora indicator
    # wall = List.replace_at(wall, -5, :"2s") # first ura indicator
    # wall = List.replace_at(wall, -7, :"2p") # second ura indicator
    # wall = List.replace_at(wall, -9, :"2p") # third ura indicator
    # wall = List.replace_at(wall, -11, :"2p") # fourth ura indicator
    # wall = List.replace_at(wall, -13, :"2p") # fifth ura indicator
    # wall = List.replace_at(wall, -1, :"1s") # first kan draw
    # wall = List.replace_at(wall, -2, :"6p") # second kan draw
    # wall = List.replace_at(wall, -3, :"6p") # third kan draw
    # wall = List.replace_at(wall, -4, :"2m") # fourth kan draw
    wall
  end
  def set_starting_hand(wall) do
    hands = %{:east  => Enum.slice(wall, 0..12),
              :south => Enum.slice(wall, 13..25),
              :west  => Enum.slice(wall, 26..38),
              :north => Enum.slice(wall, 39..51)}

    # # random hand
    # hands = %{:east  => Utils.sort_tiles([:"3m", :"4m", :"5m", :"2p", :"2p", :"4p", :"4p", :"4p", :"5p", :"6p", :"7p", :"3s", :"3s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # naked tanki setup
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"3m", :"3m", :"5m", :"5m", :"7m", :"7m", :"9m", :"1z", :"1z", :"1z", :"1z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # FF 2024a 2222b 2222c w/ zombie blanks
    # hands = %{:east  => Utils.sort_tiles([:"1f", :"2f", :"2p", :"5z", :"2p", :"4p", :"2m", :"2m", :"2m", :"2m", :"2s", :"2s", :"2s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # junsei ryuuiisou
    # hands = %{:east  => Utils.sort_tiles([:"2s", :"2s", :"2s", :"2s", :"4s", :"3s", :"3s", :"3s", :"4s", :"4s", :"4s", :"4s", :"4s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # random hand 77889999m778899p
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"7m", :"8m", :"8m", :"9m", :"9m", :"9m", :"9m", :"7p", :"7p", :"8p", :"8p", :"9p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # almost FF XXXX0a NEWS XXXX0b
    # hands = %{:east  => Utils.sort_tiles([:"9m", :"9m", :"9m", :"8s", :"9s", :"9s", :"1z", :"2z", :"3z", :"4z", :"1f", :"3f", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # FF XXXX0a NEWS XXXX0b
    # hands = %{:east  => Utils.sort_tiles([:"9m", :"9m", :"9m", :"9s", :"9s", :"9s", :"1z", :"2z", :"3z", :"4z", :"1f", :"3f", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # pon precedence
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"1z", :"1p", :"1p", :"2p", :"2p", :"3p", :"3p"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"1z", :"1p", :"1p", :"2p", :"2p", :"3p", :"3p"]),
    #           :west  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"1z", :"1p", :"1p", :"2p", :"2p", :"3p", :"3p"]),
    #           :north => Enum.slice(wall, 39..51)}

    # # 111a 33a 5555b 77c 999c
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"9m", :"9m", :"9m", :"5p", :"5p", :"5p", :"1s", :"1s", :"1s", :"3s", :"3s", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # XX0a XXXXX1a XX0b XXXXX1b
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"2m", :"2m", :"2m", :"1p", :"1p", :"2p", :"2p", :"2p", :"2p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chinitsu ryuuisou
    # hands = %{:east  => Utils.sort_tiles([:"2s", :"2s", :"2s", :"3s", :"3s", :"3s", :"3s", :"3s", :"3s", :"4s", :"8s", :"8s", :"8s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # not knitted hand
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"6m", :"1p", :"2p", :"3p", :"4p", :"9p", :"1s", :"4s", :"2z", :"6z", :"12j", :"14j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # juusan kokushi
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"9p", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # non-juusan kokushi
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted hand
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"7m", :"1p", :"4p", :"7p", :"1s", :"1s", :"7s", :"1z", :"6z", :"7z", :"14j", :"15j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # seat wind
    # hands = %{:east  => Enum.slice(wall, 0..12),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"3z", :"3z", :"9m", :"3z"]),
    #           :north => Enum.slice(wall, 39..51)}

    # # joker in pung
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"3m", :"3m", :"3m", :"7m", :"7m", :"7m", :"9m", :"19j", :"1z", :"4m", :"6m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # sanankou
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"3m", :"3m", :"3m", :"7m", :"7m", :"7m", :"9m", :"9m", :"9m", :"4m", :"6m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # ryanankou
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"3m", :"3m", :"3m", :"7m", :"7m", :"7m", :"9m", :"9m", :"1z", :"4m", :"6m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # minefield ippatsu sanankou
    # hands = %{:east  => Enum.slice(wall, 0..19) ++ [:"1m", :"1m", :"1m", :"3m", :"3m", :"3m", :"7m", :"7m", :"7m", :"9m", :"9m", :"9m", :"5m", :"5m"],
    #           :south => [],
    #           :west  => List.duplicate(:"5m", 34),
    #           :north => []}

    # # honitsu
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"2z", :"2z", :"9m", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # uushin tsuukan
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"4z", :"6m", :"7m", :"8m", :"9m", :"2z", :"2z", :"4z", :"4z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # american civil war
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"8m", :"6m", :"1m", :"1p", :"8p", :"6p", :"5p", :"2z", :"2z", :"2z", :"4z", :"4z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # hyakuman goku
    # hands = %{:east  => Utils.sort_tiles([:"6m", :"7m", :"8m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"9m", :"9m", :"9m", :"8m"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # shiisanpuutaa
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chiishin_uushii
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chinpeikou
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"1p", :"1p", :"2p", :"2p", :"3p", :"3p", :"1p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # shanron chonchu
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"1s", :"2s", :"3s", :"4m", :"5m", :"6m", :"4s", :"5s", :"6s", :"1p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # ittsu chanta
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1s", :"1s", :"1s", :"1p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # tanyao
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"3m", :"4m", :"4m", :"5m", :"6m", :"7p", :"7p", :"7p", :"8s", :"8s", :"8s", :"6p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chinitsu
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"5s", :"5s", :"7s", :"8s", :"9s", :"9s", :"9s", :"10s", :"10s", :"10s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # daisharin
    # hands = %{:east  => Utils.sort_tiles([:"2p", :"2p", :"3p", :"3p", :"4p", :"4p", :"5p", :"5p", :"6p", :"6p", :"7p", :"7p", :"8p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # mixed winds
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1z", :"2z", :"3z", :"2z", :"3z", :"1z", :"1z", :"2z", :"3z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # mini-sangen
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"5p", :"5p", :"5p", :"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # suuankou
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"5p", :"5p", :"5p", :"1z", :"1z", :"1z", :"3z", :"3z", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # multiple ankan
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"5p", :"5p", :"5p", :"0p", :"1z", :"1z", :"1z", :"1z", :"6p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # sanma
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"1z", :"1z", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # taiwanese 7 flowers
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"2m", :"2m", :"2m", :"1s", :"1s", :"9m", :"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"1m", :"2m", :"2m", :"2m", :"1s", :"1s", :"1s", :"8s", :"8s", :"8s", :"3m", :"4m", :"5m", :"4g"]),
    #           :west  => Enum.slice(wall, 32..47),
    #           :north => Enum.slice(wall, 48..63)}

    # # taiwanese
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"2m", :"2m", :"2m", :"1s", :"1s", :"1s", :"8s", :"8s", :"8s", :"3m", :"4m", :"7m", :"9m"]),
    #           :south => Enum.slice(wall, 16..31),
    #           :west  => Enum.slice(wall, 32..47),
    #           :north => Enum.slice(wall, 48..63)}

    # # washizu
    # hands = %{:east  => Utils.sort_tiles([
    #   {:"1s", ["revealed", "transparent"]},
    #   {:"2s", ["revealed", "transparent"]},
    #   :"3s",
    #   {:"4s", ["revealed", "transparent"]},
    #   {:"5s", ["revealed", "transparent"]},
    #   {:"6s", ["revealed", "transparent"]},
    #   {:"7s", ["revealed", "transparent"]},
    #   {:"8s", ["revealed", "transparent"]},
    #   :"3m",
    #   {:"3m", ["revealed", "transparent"]},
    #   {:"3m", ["revealed", "transparent"]},
    #   {:"2z", ["revealed", "transparent"]},
    #   {:"2z", ["revealed", "transparent"]}]),
    #           :south => Enum.slice(wall, 13..25) ++ [{:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}],
    #           :west  => Enum.slice(wall, 26..38) ++ [{:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}],
    #           :north => Enum.slice(wall, 39..51) ++ [{:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}, {:"3m", ["revealed", "transparent"]}]}

    # # shouhai
    # hands = %{:east  => Enum.slice(wall, 0..11),
    #           :south => Enum.slice(wall, 12..23),
    #           :west  => Enum.slice(wall, 24..35),
    #           :north => Enum.slice(wall, 36..47)}

    # # chinitsu shouhai
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"2s", :"2s", :"2s", :"4s", :"4s", :"4s", :"7s", :"7s", :"7s", :"8s"]),
    #           :south => Enum.slice(wall, 12..23),
    #           :west  => Enum.slice(wall, 24..35),
    #           :north => Enum.slice(wall, 36..47)}

    # # ten mod in SBR
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"4m", :"8m", :"9m", :"10m", :"2s", :"3s", :"4s", :"5s", :"6s", :"6s", :"1z"]),
    #           :south => Utils.sort_tiles([:"4m", :"4m", :"4m", :"8m", :"9m", :"10m", :"2z", :"3z", :"4z", :"5z", :"6z", :"6z", :"1z"]),
    #           :west  => Utils.sort_tiles([:"4m", :"4m", :"4m", :"8m", :"9m", :"10m", :"2z", :"3z", :"4z", :"5z", :"6z", :"6z", :"1z"]),
    #           :north => Utils.sort_tiles([:"4m", :"4m", :"4m", :"8m", :"9m", :"10m", :"2z", :"3z", :"4z", :"5z", :"6z", :"6z", :"1z"])}

    # # NFNL
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1s", :"1s", :"1s", :"8s", :"8s", :"8s", :"3m", :"4m", :"8m", :"9m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # toriuchi
    # hands = %{:east  => Utils.sort_tiles([:"1z", :"1z", :"1z", :"1s", :"1s", :"1s", :"8s", :"8s", :"8s", :"6m", :"7m", :"8m", :"9m"]),
    #           :south => Utils.sort_tiles([:"1z", :"1z", :"1z", :"1s", :"1s", :"1s", :"8p", :"8p", :"8p", :"6m", :"7m", :"8m", :"7p"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # kindora
    # hands = %{:east  => Utils.sort_tiles([:"27z", :"26z", :"7z", :"7z", :"6z", :"6z", :"3p", :"4p", :"7z", :"6m", :"7m", :"8m", :"9m"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # any joker test
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"1p", :"1p", :"2p", :"2p", :"2p", :"5p", :"6p", :"6p", :"8p", :"9p", :"12j", :"13j"]),
    #           :south => Utils.sort_tiles([:"1p", :"1p", :"1p", :"2p", :"2p", :"2p", :"5p", :"6p", :"6p", :"8p", :"9p", :"12j", :"13j"]),
    #           :west  => Utils.sort_tiles([:"1p", :"1p", :"1p", :"2p", :"2p", :"2p", :"5p", :"6p", :"6p", :"8p", :"9p", :"12j", :"13j"]),
    #           :north => Utils.sort_tiles([:"1p", :"1p", :"1p", :"2p", :"2p", :"2p", :"5p", :"6p", :"6p", :"8p", :"9p", :"12j", :"13j"])}

    # # seven consecutive pairs
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"5p", :"5p", :"6m", :"6m", :"7m", :"7m", :"8p", :"8p", :"9m", :"9m", :"3m"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # big high value hand
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"5m", :"5m", :"6m", :"6m", :"4p", :"4p", :"5p", :"5p", :"6p", :"6p", :"6p"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chanta
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"7p", :"8p", :"9p", :"1s", :"1p", :"1p", :"1p", :"3z", :"3z", :"3z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # double knitted short straight with joker
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"4m", :"2p", :"5p", :"3s", :"6s", :"2p", :"3s", :"4m", :"5p", :"18j", :"7m", :"1z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted short straight with jokers
    # hands = %{:east  => Utils.sort_tiles([:"5m", :"8m", :"3p", :"3p", :"4p", :"5p", :"5p", :"6p", :"7s", :"17j", :"18j", :"14j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted honors with all three suits
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"1p", :"4p", :"2z", :"1s", :"7s", :"1z", :"1z", :"3z", :"0z", :"7z", :"18j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted honors without all three suits
    # hands = %{:east  => Utils.sort_tiles([:"7p", :"1p", :"4p", :"2z", :"1s", :"7s", :"1z", :"1z", :"3z", :"0z", :"7z", :"18j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # 13 unconnected (riichi)
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"1p", :"4p", :"7p", :"1s", :"7s", :"1z", :"4z", :"3z", :"5z", :"6z", :"7z", :"2z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # 13 unconnected (B30FJ)
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"1p", :"4p", :"7p", :"1s", :"7s", :"1z", :"1z", :"3z", :"0z", :"7z", :"18j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted straight tenpai
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2p", :"3s", :"4m", :"5p", :"6s", :"7m", :"8p", :"7z", :"2z", :"3z", :"4z", :"4z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # testing call priority
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"0z", :"5m", :"5m"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"13j", :"5m", :"5m", :"12j"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"0z", :"5m", :"13j"]),
    #           :north => Utils.sort_tiles([:"1m", :"2m", :"3m", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"0z", :"5m", :"6m"])}

    # # 8 flowers
    # hands = %{:east  => Utils.sort_tiles([:"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g", :"4g", :"1y", :"1y", :"1y", :"1y", :"2y"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # ittsu
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"3m", :"3m", :"3m", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # FF 11a 33a 55a 55b 77b 99b
    # hands = %{:east  => Utils.sort_tiles([:"1f", :"1g", :"1m", :"1m", :"3m", :"3m", :"5m", :"5m", :"5p", :"5p", :"7p", :"7p", :"9p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # XX0a DDDa XX0b DDDb XXXX0c
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"7z", :"7z", :"7z", :"1p", :"1p", :"0z", :"0z", :"0z", :"1s", :"1j", :"1s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FF 2024a 2222b 2222c
    # hands = %{:east  => Utils.sort_tiles([:"1f", :"2f", :"2p", :"0z", :"2p", :"4p", :"2m", :"2m", :"2m", :"2m", :"2s", :"2s", :"2s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # NN EEE 2024a WWW SS (valid)
    # hands = %{:east  => Utils.sort_tiles([:"4z", :"4z", :"1z", :"1z", :"1z", :"2m", :"0z", :"2m", :"4m", :"3z", :"3z", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # NN EEE 2024a WWW SS (invalid)
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"4m", :"1z", :"1z", :"3z", :"4z", :"4z", :"0z", :"1j", :"1j", :"1j", :"1j", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # XXX0a XXX1a XXXX2a XXXX3a
    # hands = %{:east  => Utils.sort_tiles([:"3m", :"3m", :"3m", :"4m", :"4m", :"1j", :"5m", :"5m", :"5m", :"1j", :"6m", :"6m", :"6m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # EEE WWW XXXX0a XXXX1b
    # hands = %{:east  => Utils.sort_tiles([:"1z", :"1z", :"1z", :"3z", :"3z", :"3z", :"5p", :"1j", :"5p", :"6s", :"6s", :"6s", :"6s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FFFF 33a 66a 999a DDDb
    # hands = %{:east  => Utils.sort_tiles([:"3s", :"6s", :"6s", :"9s", :"9s", :"9s", :"4f", :"1g", :"3s", :"1j", :"7z", :"7z", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FFFFF DDDDa XXXXX0b
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"1f", :"3g", :"4g", :"3f", :"7z", :"7z", :"1j", :"7z", :"1j", :"1j", :"1j", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FF NN EEE WWW SSSS
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"1f", :"4z", :"4z", :"1z", :"1z", :"1z", :"3z", :"3z", :"3z", :"2z", :"2z", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FFFFF X0a X1a X2a XXX3b XXX3c
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"1f", :"3f", :"4f", :"1j", :"1j", :"1m", :"2m", :"3m", :"4p", :"4p", :"4p", :"4s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FF XXXX0a NEWS XXXX0b
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"1f", :"8m", :"8m", :"8m", :"8m", :"8p", :"8p", :"8p", :"1z", :"2z", :"3z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FFFF XXX0a XXXX0b XXX0c
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"3f", :"3g", :"8m", :"8m", :"8m", :"8p", :"8p", :"8p", :"8s", :"8s", :"8s", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FF DDDDa NEWS DDDDb
    # hands = %{:east  => Utils.sort_tiles([:"2f", :"2f", :"0z", :"0z", :"0z", :"0z", :"1z", :"2z", :"3z", :"4z", :"6z", :"6z", :"1j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # FF 2024a 4444b 4444c
    # hands = %{:east  => Utils.sort_tiles([:"1f", :"2f", :"2m", :"0z", :"2m", :"4m", :"1j", :"2p", :"2p", :"2p", :"2s", :"2s", :"2s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # # 222a 000 2222b 4444b
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"2p", :"3p", :"3p", :"4p", :"4p", :"5p", :"5p", :"6z", :"6z", :"7z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"1p", :"1p", :"1p", :"4p", :"5p", :"1z", :"2z", :"3z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4m", :"5m", :"6m", :"7s", :"8s", :"9s", :"5z", :"5z", :"5z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"6p", :"7p", :"1s", :"3s", :"4s", :"5s", :"8s", :"9s", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"4m", :"4m", :"5p", :"5p", :"1z", :"1z", :"2z", :"2z", :"3z"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"4m", :"4m", :"5p", :"5p", :"1z", :"1z", :"2z", :"2z", :"3z"]),
    #           :west  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"4m", :"4m", :"5p", :"5p", :"1z", :"1z", :"2z", :"2z", :"3z"]),
    #           :north => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"4m", :"4m", :"5p", :"5p", :"1z", :"1z", :"2z", :"2z", :"3z"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9j", :"1p", :"7j", :"1s", :"8j", :"1z", :"5j", :"3z", :"4z", :"6j", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"3m", :"3m", :"5m", :"6m", :"6m", :"8m", :"6p", :"6p", :"0z", :"6p", :"4m", :"0z", :"15j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"3m", :"3m", :"5m", :"6m", :"6m", :"8m", :"6p", :"6p", :"0z", :"12j", :"19j", :"4j", :"15j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"2p", :"3p", :"6p", :"7p", :"2s", :"3s", :"1z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"4p", :"2m", :"5m", :"3s", :"6s", :"1m", :"7m", :"2p", :"8p", :"3s", :"1z", :"1z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"4p", :"7p", :"2m", :"5m", :"8m", :"3s", :"6s", :"9s", :"1z", :"1z", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4z", :"3z", :"1p", :"4p", :"7p", :"1s", :"4s", :"4s", :"7s", :"4m", :"7m", :"1z", :"6z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2s", :"4p", :"5s", :"6m", :"9m", :"1z", :"2z", :"3z", :"4z", :"0z", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"5p", :"5p", :"1z", :"1z", :"2z", :"2z", :"3z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"5m", :"5s", :"8m", :"8s", :"2z", :"3z", :"6m", :"6m", :"2m", :"2p", :"2s", :"5z", :"5z"]),
    #           :south => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"5z", :"8p", :"4z", :"4z"]),
    #           :west  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"1z", :"1z", :"8p", :"8p"]),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"4m", :"4m", :"8m", :"0z", :"0z", :"6z", :"6z", :"7z", :"7z", :"12j", :"13j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"7m", :"7m", :"9m", :"4j", :"9m", :"1s", :"1s", :"3s", :"3s", :"8s", :"8s"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"7m", :"7m", :"9m", :"4j", :"9m", :"1s", :"1s", :"3s", :"3s", :"8s", :"8s"]),
    #           :west  => Utils.sort_tiles([:"1m", :"1m", :"7m", :"7m", :"9m", :"4j", :"9m", :"1s", :"1s", :"3s", :"3s", :"8s", :"8s"]),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"3m", :"4m", :"5m", :"5m", :"27z", :"1m", :"1s", :"2s", :"3s", :"8s", :"7z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"3m", :"4m", :"5m", :"5m", :"5m", :"6m", :"6m", :"1z", :"2z", :"3z", :"6z", :"7z"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"7m", :"7m", :"9m", :"7z", :"9m", :"1s", :"1s", :"3s", :"3s", :"8s", :"8s"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
    #           :south => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1z", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"2m", :"3m", :"1z", :"1z", :"2p", :"3p", :"4p", :"2s", :"2s", :"3s", :"3s", :"1s"]),
    #           :south => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1z", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1z", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"3m", :"3m", :"5m", :"5m", :"8m", :"8m", :"1z", :"9m", :"7m", :"7m", :"9m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1p", :"2p", :"3p", :"1s", :"2s", :"3s", :"2s", :"3s", :"1s", :"7p", :"8p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"3z", :"3z", :"3z", :"4s", :"4s", :"4s", :"3s", :"3s", :"9s", :"1m", :"9m", :"7m", :"8m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"3z", :"3z", :"3z", :"3z", :"4s", :"4s", :"4s", :"3s", :"9s", :"3s", :"3s", :"7m", :"8m"]),
    #           :south => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"2z", :"2z", :"2z", :"2z", :"1z", :"1z", :"1z", :"1z"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1s", :"4s", :"4s", :"4s", :"4s", :"9s", :"3s", :"3s", :"7m", :"8m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"1s", :"4s", :"4s", :"4s", :"3s", :"3s", :"3s", :"7m", :"7m", :"8m", :"9s"]),
    #           :south => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"2m", :"2m", :"7m", :"8m"]),
    #           :west  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"2m", :"2m", :"7m", :"8m"]),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"2m", :"1z", :"7m", :"8m"]),
    #           :south => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"7z", :"7z", :"7z", :"6z"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"1m", :"1m", :"1p", :"1p", :"5s", :"5s", :"1z", :"2z", :"3z", :"4z", :"7s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"3m", :"3m", :"5m", :"5m", :"8m", :"8m", :"1z", :"2z", :"7m", :"7m", :"9m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"1m", :"2m", :"2m", :"2m"]),
    #           :south => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"9s", :"1m", :"1m", :"5z", :"5z"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2s", :"3s", :"3s", :"4s", :"4s", :"9s", :"9s", :"9s", :"9s", :"1z", :"1z", :"6z", :"6z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"1m", :"2m", :"3m", :"1p", :"1p", :"1p", :"2p", :"3p", :"1s", :"2s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"19j", :"9m", :"7j", :"9p", :"18j", :"9s", :"1z", :"2z", :"3z", :"16j", :"15j", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"3m", :"6m", :"9m", :"19j", :"7m", :"8m", :"9m", :"2m", :"3m", :"4m", :"1m", :"1m", :"12j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"5m", :"6m", :"8m", :"8m", :"8m", :"4p", :"0p", :"6p", :"7z", :"7z", :"1z", :"7m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1m", :"1m", :"9m", :"19j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"5z", :"6z", :"6z", :"6z", :"5z", :"6z", :"1z", :"1z", :"1z", :"2s", :"3s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"6m", :"6m", :"8m", :"9m", :"6z", :"26z", :"7m", :"27z", :"7z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"5m", :"6m", :"9m", :"9m", :"1s", :"1s", :"1s", :"4s", :"4s", :"8s", :"3j", :"2j"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1z", :"5p", :"5s", :"0p", :"5m", :"0s", :"0m", :"15s", :"2p", :"3p", :"4p", :"15m", :"15p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # 05667779m56p222z
    # hands = %{:east  => Utils.sort_tiles([:"0m", :"5m", :"6m", :"6m", :"7m", :"7m", :"7m", :"9m", :"5p", :"6p", :"2z", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2s", :"2s", :"2s", :"2s", :"3s", :"4s", :"5s", :"6s", :"6s", :"7s", :"7s", :"8s", :"8s"]),
    #           :south => Utils.sort_tiles([:"2s", :"2s", :"2s", :"2s", :"3s", :"4s", :"5s", :"6s", :"6s", :"7s", :"7s", :"8s", :"8s"]),
    #           :west  => Utils.sort_tiles([:"2s", :"2s", :"2s", :"2s", :"3s", :"4s", :"5s", :"6s", :"6s", :"7s", :"7s", :"8s", :"8s"]),
    #           :north => Utils.sort_tiles([:"2s", :"2s", :"2s", :"2s", :"3s", :"4s", :"5s", :"6s", :"6s", :"7s", :"7s", :"8s", :"8s"])}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"3m", :"3m", :"4m", :"4m", :"5p", :"5p", :"6m", :"7m", :"8m", :"9p", :"9p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"1p", :"1p", :"1p", :"3p", :"3p", :"3p", :"1s", :"2s", :"3s", :"2s"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"6p", :"8p", :"2m", :"3m", :"4m", :"6m", :"7m", :"8m", :"3p", :"4p", :"5p", :"4p", :"5p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"6s", :"8s", :"2m", :"3m", :"4m", :"6m", :"7m", :"8m", :"3p", :"4p", :"5p", :"4s", :"1z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"3m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"4m", :"7m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"7z", :"7z", :"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"4s", :"4s", :"4s"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"]),
    #           :west  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"]),
    #           :north => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2s", :"5s", :"8s", :"3p", :"6p", :"9p", :"2j", :"0z", :"6z", :"6j"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"]),
    #           :west  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"]),
    #           :north => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m", :"1m"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"2s", :"2s", :"2s", :"3p", :"3p", :"4p", :"5p", :"6p", :"7p", :"7p"]),
    #           :south => Utils.sort_tiles([:"1m", :"1m", :"1m", :"2s", :"2s", :"2z", :"3p", :"3z", :"4p", :"5p", :"6p", :"9p", :"9p"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"8p", :"9p", :"4s", :"4m", :"5z", :"1m", :"7z", :"6m", :"5m", :"4s", :"2z", :"3z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"8p", :"9p", :"4s", :"14s", :"5z", :"1m", :"7z", :"16s", :"15p", :"4s", :"13z", :"3z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"18m", :"8m", :"2s", :"3s", :"4s", :"4s", :"5s", :"8s", :"7m", :"17s", :"7m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"3m", :"3m", :"6m", :"6m", :"8m", :"8m", :"2m", :"2m", :"1p", :"1p", :"2p"]),
    #           :south => Enum.slice(wall, 13..24),
    #           :west  => Enum.slice(wall, 26..37),
    #           :north => Enum.slice(wall, 39..50)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"2j", :"7z", :"6m", :"6m", :"6m", :"3j", :"2z", :"2z", :"2z", :"4m", :"0z", :"6z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"9m", :"9m", :"9m", :"1s", :"1s", :"1s", :"2s", :"2s", :"2m", :"2m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"6z", :"7z", :"2m"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"6z", :"7z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"1z", :"1z", :"4z", :"4z", :"4z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Enum.slice(wall, 13..25),
    #           :south => Utils.sort_tiles([:"3m", :"4m", :"5m", :"7m", :"8m", :"9m", :"2s", :"2s", :"2s", :"1z", :"1z", :"3z", :"3z"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Utils.sort_tiles([:"2s", :"2s", :"3s", :"3s", :"4s", :"4s", :"5s", :"6s", :"1m", :"2m", :"3m", :"2m", :"2m"])}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"1p", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :north => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :north => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"2m", :"2m", :"3m", :"3m", :"8p", :"8p", :"3p", :"4p", :"5p", :"8p", :"8p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9j", :"2m", :"2m", :"4m", :"4m", :"4m", :"4m", :"3p", :"4p", :"5p", :"8p", :"8p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"6z"]),
    #           :south => Utils.sort_tiles([:"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p", :"6z"]),
    #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
    #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
    # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"5z", :"6z", :"7z", :"1z", :"1z", :"2z", :"2z"]),
    #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"1z", :"1z", :"1z", :"1z", :"1z", :"1z"]),
    #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
    #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
    # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"1m", :"1m", :"1m", :"1z", :"1z", :"2z", :"2z"]),
    #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"1z", :"1z", :"1z", :"1z", :"1z", :"1z"]),
    #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
    #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
    # hands = %{:east  => Utils.sort_tiles([:"5z", :"5z", :"6z", :"6z", :"7z", :"7z", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
    #           :south => Utils.sort_tiles([:"5z", :"5z", :"5z", :"5z", :"5z", :"5z", :"6m", :"6m", :"6m", :"6m", :"6m", :"6m", :"6m"]),
    #           :west  => Utils.sort_tiles([:"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z", :"6z"]),
    #           :north => Utils.sort_tiles([:"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z", :"7z"])}
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
    #           :south => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
    #           :west  => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"]),
    #           :north => Utils.sort_tiles([:"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"5m", :"5m", :"6m", :"6m"])}
    # hands = %{:east  => Utils.sort_tiles([:"1p", :"2p", :"3p", :"2m", :"3m", :"5m", :"5m", :"1s", :"2s", :"3s", :"4s", :"5s", :"6s"]),
    #           :south => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"]),
    #           :west  => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"]),
    #           :north => Utils.sort_tiles([:"1m", :"4m", :"7m", :"2p", :"5p", :"8p", :"3s", :"6s", :"9s", :"1z", :"2z", :"3z", :"4z"])}
    #           :south => Utils.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"8p", :"8p", :"4p", :"5p"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"8p", :"8p", :"6p", :"7p"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"2p", :"0s", :"5s", :"5s", :"5s", :"5s", :"1z", :"1z", :"1z", :"1z"]),
    #           :west  => Utils.sort_tiles([:"1z", :"1z", :"6z", :"7z", :"2z", :"2z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"5z"]),
    #           :north => Utils.sort_tiles([:"1m", :"2m", :"2m", :"5m", :"5m", :"7m", :"7m", :"9m", :"9m", :"1z", :"1z", :"2z", :"3z"])}
    hands
  end
end
