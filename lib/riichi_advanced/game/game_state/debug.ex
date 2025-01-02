
defmodule RiichiAdvanced.GameState.Debug do
  @debug false
  @debug_status false
  @debug_fast_ai false
  @debug_saki_card_ours nil
  @debug_saki_card_opponent nil
  @debug_actions false
  @debug_log false
  @debug_ai false
  @debug_buttons false
  @debug_conditions false
  @print_smt false
  @skip_ruleset_caching false

  def debug, do: @debug
  def debug_status, do: @debug_status
  def debug_fast_ai, do: @debug_fast_ai
  def debug_saki_card_ours, do: @debug_saki_card_ours
  def debug_saki_card_opponent, do: @debug_saki_card_opponent
  def debug_actions, do: @debug_actions
  def debug_buttons, do: @debug_buttons
  def debug_conditions, do: @debug_conditions
  def debug_ai, do: @debug_ai
  def debug_log, do: @debug_log
  def print_smt, do: @print_smt
  def skip_ruleset_caching, do: @skip_ruleset_caching

  def set_wall(wall) do
    # wall = List.replace_at(wall, 52, :"6p") # first draw
    # wall = List.replace_at(wall, 53, :"6p")
    # wall = List.replace_at(wall, 54, :"6p")
    # wall = List.replace_at(wall, 55, :"6p")
    # wall = List.replace_at(wall, 56, :"8s") # second draw
    # wall = List.replace_at(wall, 57, :"8s")
    # wall = List.replace_at(wall, 58, :"8s")
    # wall = List.replace_at(wall, 59, :"8s")
    # wall = List.replace_at(wall, 60, :"8s") # third draw
    # wall = List.replace_at(wall, 61, :"8s")
    # wall = List.replace_at(wall, 62, :"8s")
    # wall = List.replace_at(wall, 63, :"8s")
    # wall = List.replace_at(wall, 64, :"3m") # fourth draw
    # wall = List.replace_at(wall, 65, :"1z")
    # wall = List.replace_at(wall, 66, :"1z")
    # wall = List.replace_at(wall, 67, :"5z")
    # wall = List.replace_at(wall, 68, :"5z") # fifth draw
    # wall = List.replace_at(wall, 80, :"8m") # seventh draw
    # wall = List.replace_at(wall, -15, :"1m") # last draw
    # wall = List.replace_at(wall, -6, :"6p") # first dora indicator
    # wall = List.replace_at(wall, -8, :"2p") # second dora indicator
    # wall = List.replace_at(wall, -10, :"8s") # third dora indicator
    # wall = List.replace_at(wall, -12, :"2p") # fourth dora indicator
    # wall = List.replace_at(wall, -14, :"2p") # fifth dora indicator
    # wall = List.replace_at(wall, -5, :"7p") # first ura indicator
    # wall = List.replace_at(wall, -7, :"2p") # second ura indicator
    # wall = List.replace_at(wall, -9, :"2p") # third ura indicator
    # wall = List.replace_at(wall, -11, :"2p") # fourth ura indicator
    # wall = List.replace_at(wall, -13, :"2p") # fifth ura indicator
    # wall = List.replace_at(wall, -1, :"2m") # first kan draw
    # wall = List.replace_at(wall, -2, :"2m") # second kan draw
    # wall = List.replace_at(wall, -3, :"2m") # third kan draw
    # wall = List.replace_at(wall, -4, :"2m") # fourth kan draw
    wall
  end
  def set_starting_hand(wall) do
    hands = %{:east  => Enum.slice(wall, 0..12),
              :south => Enum.slice(wall, 13..25),
              :west  => Enum.slice(wall, 26..38),
              :north => Enum.slice(wall, 39..51)}

    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"6m", :"7m", :"8m", :"2p", :"2p", :"2s", :"2s", :"2s", :"6s", :"7s"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # seven consecutive pairs
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"5p", :"5p", :"6m", :"6m", :"7m", :"7m", :"8p", :"8p", :"9m", :"9m", :"3m"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # high value hand
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"4m", :"5m", :"5m", :"6m", :"6m", :"4p", :"4p", :"5p", :"5p", :"6p", :"6p", :"6p"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # chanta
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"7p", :"8p", :"9p", :"1s", :"1p", :"1p", :"1p", :"3z", :"3z", :"3z"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted honors
    # hands = %{:east  => Utils.sort_tiles([:"7p", :"1p", :"4p", :"2z", :"1s", :"7s", :"1z", :"1z", :"3z", :"0z", :"7z", :"18j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # 13 disconnected
    # hands = %{:east  => Utils.sort_tiles([:"7m", :"1p", :"4p", :"7p", :"1s", :"7s", :"1z", :"1z", :"3z", :"0z", :"7z", :"18j", :"15j"]),
    #           :south => Enum.slice(wall, 26..38),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # knitted straight tenpai
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2p", :"3s", :"4m", :"5p", :"6s", :"7m", :"8p", :"1m", :"2m", :"3m", :"2z", :"2z"]),
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

    # # iitsu
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"2s", :"3s", :"4s", :"5s", :"6s", :"7s", :"8s", :"3m", :"3m", :"3m", :"2z", :"2z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}

    # # kokushi
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"6z", :"7z"]),
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
    # hands = %{:east  => Utils.sort_tiles([:"2m", :"2m", :"2m", :"0z", :"0z", :"0z", :"2p", :"2p", :"2p", :"2p", :"4p", :"4p", :"4p"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
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
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"1m", :"1m", :"1m", :"5p", :"5p", :"5p", :"0p", :"8s", :"3z", :"1z", :"2z", :"4z"]),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
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
