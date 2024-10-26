
defmodule RiichiAdvanced.GameState.Debug do
  @debug false
  @debug_status false
  @debug_fast_ai false
  @debug_saki_card nil
  @debug_saki_card_2 nil

  def debug, do: @debug
  def debug_status, do: @debug_status
  def debug_fast_ai, do: @debug_fast_ai
  def debug_saki_card, do: @debug_saki_card
  def debug_saki_card_2, do: @debug_saki_card_2

  def set_wall(wall) do
    # wall = List.replace_at(wall, 52, :"1z") # first draw
    # wall = List.replace_at(wall, 53, :"1z")
    # wall = List.replace_at(wall, 54, :"1z")
    # wall = List.replace_at(wall, 55, :"1z")
    # wall = List.replace_at(wall, 56, :"3z") # second draw
    # wall = List.replace_at(wall, 57, :"7m")
    # wall = List.replace_at(wall, 58, :"9s")
    # wall = List.replace_at(wall, 59, :"9s")
    # wall = List.replace_at(wall, 60, :"9s") # third draw
    # wall = List.replace_at(wall, 61, :"9s")
    # wall = List.replace_at(wall, 62, :"9s")
    # wall = List.replace_at(wall, 63, :"2z")
    # wall = List.replace_at(wall, 64, :"2z") # fourth draw
    # wall = List.replace_at(wall, 65, :"6z")
    # wall = List.replace_at(wall, 66, :"6z")
    # wall = List.replace_at(wall, 67, :"5z")
    # wall = List.replace_at(wall, 68, :"5z") # fifth draw
    # wall = List.replace_at(wall, 80, :"8m") # seventh draw
    # wall = List.replace_at(wall, -15, :"1m") # last draw
    wall = List.replace_at(wall, -6, :"9s") # first dora indicator
    # wall = List.replace_at(wall, -8, :"9s") # second dora indicator
    # wall = List.replace_at(wall, -2, :"9m") # first kan draw for hk
    # wall = List.replace_at(wall, -1, :"1z") # first kan draw for saki
    # wall = List.replace_at(wall, -2, :"9m") # second kan draw for saki
    # wall = List.replace_at(wall, -3, :"4m") # third kan draw for saki
    # wall = List.replace_at(wall, -4, :"6m") # fourth kan draw for saki
    # wall = List.replace_at(wall, -2, :"9m") # first kan draw for riichi
    # wall = List.replace_at(wall, -1, :"9s") # second kan draw for riichi
    # wall = List.replace_at(wall, -4, :"9m") # third kan draw for riichi
    # wall = List.replace_at(wall, -3, :"9s") # fourth kan draw for riichi
    wall
  end
  def set_starting_hand(wall) do
    # hands = %{:east  => Enum.slice(wall, 0..12),
    #           :south => Enum.slice(wall, 13..25),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    hands = %{:east  => Utils.sort_tiles([:"1m", :"9m", :"1p", :"9p", :"1s", :"9s", :"1z", :"2z", :"3z", :"4z", :"5z", :"6z", :"7z"]),
              :south => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1z", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
              :west  => Enum.slice(wall, 26..38),
              :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"4m", :"2m", :"3m", :"1z", :"1z", :"2p", :"3p", :"4p", :"2s", :"2s", :"3s", :"3s", :"1s"]),
    #           :south => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1z", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
    #           :west  => Enum.slice(wall, 26..38),
    #           :north => Enum.slice(wall, 39..51)}
    # hands = %{:east  => Utils.sort_tiles([:"1s", :"1s", :"1s", :"1s", :"1p", :"2p", :"3p", :"4p", :"5p", :"6p", :"7p", :"8p", :"9p"]),
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
              # :north => Enum.slice(wall, 39..51)}
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
