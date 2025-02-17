defmodule RiichiAdvanced.UtilsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Utils, as: Utils
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior

  @galaxy_tile_behavior %TileBehavior{ aliases: %{
    "1m": %{[] => MapSet.new([:"11p", :"11s"]), ["original"] => MapSet.new([:"11m"]) },
    "2m": %{[] => MapSet.new([:"12p", :"12s"]), ["original"] => MapSet.new([:"12m"]) },
    "3m": %{[] => MapSet.new([:"13p", :"13s"]), ["original"] => MapSet.new([:"13m"]) },
    "4m": %{[] => MapSet.new([:"14p", :"14s"]), ["original"] => MapSet.new([:"14m"]) },
    "5m": %{[] => MapSet.new([:"0m", :"15p", :"15s"]), ["original"] => MapSet.new([:"15m"]) },
    "6m": %{[] => MapSet.new([:"16p", :"16s"]), ["original"] => MapSet.new([:"16m"]) },
    "7m": %{[] => MapSet.new([:"17p", :"17s"]), ["original"] => MapSet.new([:"17m"]) },
    "8m": %{[] => MapSet.new([:"18p", :"18s"]), ["original"] => MapSet.new([:"18m"]) },
    "9m": %{[] => MapSet.new([:"19p", :"19s"]), ["original"] => MapSet.new([:"19m"]) },
    "1p": %{[] => MapSet.new([:"11m", :"11s"]), ["original"] => MapSet.new([:"11p"]) },
    "2p": %{[] => MapSet.new([:"12m", :"12s"]), ["original"] => MapSet.new([:"12p"]) },
    "3p": %{[] => MapSet.new([:"13m", :"13s"]), ["original"] => MapSet.new([:"13p"]) },
    "4p": %{[] => MapSet.new([:"14m", :"14s"]), ["original"] => MapSet.new([:"14p"]) },
    "5p": %{[] => MapSet.new([:"0p", :"15m", :"15s"]), ["original"] => MapSet.new([:"15p"]) },
    "6p": %{[] => MapSet.new([:"16m", :"16s"]), ["original"] => MapSet.new([:"16p"]) },
    "7p": %{[] => MapSet.new([:"17m", :"17s"]), ["original"] => MapSet.new([:"17p"]) },
    "8p": %{[] => MapSet.new([:"18m", :"18s"]), ["original"] => MapSet.new([:"18p"]) },
    "9p": %{[] => MapSet.new([:"19m", :"19s"]), ["original"] => MapSet.new([:"19p"]) },
    "1s": %{[] => MapSet.new([:"11m", :"11p"]), ["original"] => MapSet.new([:"11s"]) },
    "2s": %{[] => MapSet.new([:"12m", :"12p"]), ["original"] => MapSet.new([:"12s"]) },
    "3s": %{[] => MapSet.new([:"13m", :"13p"]), ["original"] => MapSet.new([:"13s"]) },
    "4s": %{[] => MapSet.new([:"14m", :"14p"]), ["original"] => MapSet.new([:"14s"]) },
    "5s": %{[] => MapSet.new([:"0s", :"15m", :"15p"]), ["original"] => MapSet.new([:"15s"]) },
    "6s": %{[] => MapSet.new([:"16m", :"16p"]), ["original"] => MapSet.new([:"16s"]) },
    "7s": %{[] => MapSet.new([:"17m", :"17p"]), ["original"] => MapSet.new([:"17s"]) },
    "8s": %{[] => MapSet.new([:"18m", :"18p"]), ["original"] => MapSet.new([:"18s"]) },
    "9s": %{[] => MapSet.new([:"19m", :"19p"]), ["original"] => MapSet.new([:"19s"]) },
    "0z": %{[] => MapSet.new([:"16z", :"17z"]), ["original"] => MapSet.new([:"15z"]) },
    "1z": %{[] => MapSet.new([:"12z", :"13z", :"14z"]), ["original"] => MapSet.new([:"11z"]) },
    "2z": %{[] => MapSet.new([:"11z", :"13z", :"14z"]), ["original"] => MapSet.new([:"12z"]) },
    "3z": %{[] => MapSet.new([:"11z", :"12z", :"14z"]), ["original"] => MapSet.new([:"13z"]) },
    "4z": %{[] => MapSet.new([:"11z", :"12z", :"13z"]), ["original"] => MapSet.new([:"14z"]) },
    "5z": %{[] => MapSet.new([:"16z", :"17z"]), ["original"] => MapSet.new([:"15z"]) },
    "6z": %{[] => MapSet.new([:"15z", :"17z"]), ["original"] => MapSet.new([:"16z"]) },
    "7z": %{[] => MapSet.new([:"15z", :"16z"]), ["original"] => MapSet.new([:"17z"]) }
  } }

  test "same_tile" do
    # basic stuff
    assert Utils.same_tile(:"1m", :"1m")
    assert Utils.same_tile({:"1m", ["a"]}, :"1m")
    assert not Utils.same_tile(:"1m", {:"1m", ["a"]})

    # fun stuff
    assert Utils.apply_tile_aliases(:"1m", @galaxy_tile_behavior) == MapSet.new([:"1m", :"11p", :"11s"])
    assert Utils.apply_tile_aliases(:"5m", @galaxy_tile_behavior) == MapSet.new([:"5m", :"0m", :"15p", :"15s"])
    assert Utils.apply_tile_aliases(:"11m", @galaxy_tile_behavior) == MapSet.new([{:"1m", ["original"]}, :"1p", :"1s", :"11m", :"11p", :"11s"])
  end

end
