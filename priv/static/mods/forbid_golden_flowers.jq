.functions.give_flower = [
  ["when", [{"name": "dice_equals", "opts": [5, 9]}], [["as", "east", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [2, 6, 10]}], [["as", "south", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [3, 7, 11]}], [["as", "west", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [4, 8, 12]}], [["as", "north", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]]
]
|
.functions.flip_gold_tile = [
  # check at most 9 tiles
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-2], ["jihai", "flower"]]}], [["tag_dora", "gold", -2], ["reveal_tile", -2]], [["run", "give_flower", {"flower": -2}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-4], ["jihai", "flower"]]}], [["tag_dora", "gold", -4], ["reveal_tile", -4]], [["run", "give_flower", {"flower": -4}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-6], ["jihai", "flower"]]}], [["tag_dora", "gold", -6], ["reveal_tile", -6]], [["run", "give_flower", {"flower": -6}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-8], ["jihai", "flower"]]}], [["tag_dora", "gold", -8], ["reveal_tile", -8]], [["run", "give_flower", {"flower": -8}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-10], ["jihai", "flower"]]}], [["tag_dora", "gold", -10], ["reveal_tile", -10]], [["run", "give_flower", {"flower": -10}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-12], ["jihai", "flower"]]}], [["tag_dora", "gold", -12], ["reveal_tile", -12]], [["run", "give_flower", {"flower": -12}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-14], ["jihai", "flower"]]}], [["tag_dora", "gold", -14], ["reveal_tile", -14]], [["run", "give_flower", {"flower": -14}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-16], ["jihai", "flower"]]}], [["tag_dora", "gold", -16], ["reveal_tile", -16]], [["run", "give_flower", {"flower": -16}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["gold"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-18], ["jihai", "flower"]]}], [["tag_dora", "gold", -18], ["reveal_tile", -18]], [["run", "give_flower", {"flower": -18}]]]]]
]
