
defmodule RiichiAdvanced.GameState.Debug do
  @debug true

  def debug do
    @debug
  end

  def set_wall(wall) do
    # wall = List.replace_at(wall, 52, :"1p") # first draw
    # wall = List.replace_at(wall, 53, :"4p")
    # wall = List.replace_at(wall, 54, :"3p")
    # wall = List.replace_at(wall, 55, :"3p")
    # wall = List.replace_at(wall, 56, :"1p") # second draw
    # wall = List.replace_at(wall, 57, :"3p")
    # wall = List.replace_at(wall, 58, :"3p")
    # wall = List.replace_at(wall, 59, :"3p")
    # wall = List.replace_at(wall, 60, :"3p")
    # wall = List.replace_at(wall, -15, :"1m") # last draw
    # wall = List.replace_at(wall, -6, :"9m") # first dora
    # wall = List.replace_at(wall, -8, :"9m") # second dora
    # wall = List.replace_at(wall, -2, :"2z") # first kan draw
    # wall = List.replace_at(wall, -1, :"3m") # second kan draw
    # wall = List.replace_at(wall, -4, :"4m") # third kan draw
    # wall = List.replace_at(wall, -3, :"6m") # fourth kan draw
    wall
  end
  def set_starting_hand(_wall) do
    hands = %{:east  => Utils.sort_tiles([:"1p", :"1p", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
              :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
              :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
              :north => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :south => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :west  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"]),
    #           :north => Utils.sort_tiles([:"1m", :"2m", :"3m", :"4m", :"5m", :"6m", :"7m", :"8m", :"9m", :"1p", :"2p", :"3p", :"4p"])}
    # hands = %{:east  => Utils.sort_tiles([:"1m", :"2m", :"3m", :"2m", :"2m", :"2m", :"4m", :"5m", :"3p", :"4p", :"5p", :"8p", :"8p"]),
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
