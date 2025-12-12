.functions.give_flower = [
  ["when", [{"name": "dice_equals", "opts": [5, 9]}], [["as", "east", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [2, 6, 10]}], [["as", "south", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [3, 7, 11]}], [["as", "west", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]],
  ["when", [{"name": "dice_equals", "opts": [4, 8, 12]}], [["as", "north", [["draw", 1, "$flower"], ["trigger_custom_call", "start_flower", "hand", ["draw"]]]]]]
]
|
.functions.flip_gold_tile = [
  # check at most 9 tiles
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-2],  ["jihai", "flower"]]}], [["tag_dora", "jin", -2],  ["reveal_tile", -2],  ["copy_tiles", {"dead_wall": [-2]},  {"atop_wall": [-9]}], ["add_attr", [-2],  ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -2}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-4],  ["jihai", "flower"]]}], [["tag_dora", "jin", -4],  ["reveal_tile", -4],  ["copy_tiles", {"dead_wall": [-4]},  {"atop_wall": [-9]}], ["add_attr", [-4],  ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -4}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-6],  ["jihai", "flower"]]}], [["tag_dora", "jin", -6],  ["reveal_tile", -6],  ["copy_tiles", {"dead_wall": [-6]},  {"atop_wall": [-9]}], ["add_attr", [-6],  ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -6}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-8],  ["jihai", "flower"]]}], [["tag_dora", "jin", -8],  ["reveal_tile", -8],  ["copy_tiles", {"dead_wall": [-8]},  {"atop_wall": [-9]}], ["add_attr", [-8],  ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -8}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-10], ["jihai", "flower"]]}], [["tag_dora", "jin", -10], ["reveal_tile", -10], ["copy_tiles", {"dead_wall": [-10]}, {"atop_wall": [-9]}], ["add_attr", [-10], ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -10}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-12], ["jihai", "flower"]]}], [["tag_dora", "jin", -12], ["reveal_tile", -12], ["copy_tiles", {"dead_wall": [-12]}, {"atop_wall": [-9]}], ["add_attr", [-12], ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -12}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-14], ["jihai", "flower"]]}], [["tag_dora", "jin", -14], ["reveal_tile", -14], ["copy_tiles", {"dead_wall": [-14]}, {"atop_wall": [-9]}], ["add_attr", [-14], ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -14}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-16], ["jihai", "flower"]]}], [["tag_dora", "jin", -16], ["reveal_tile", -16], ["copy_tiles", {"dead_wall": [-16]}, {"atop_wall": [-9]}], ["add_attr", [-16], ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -16}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["ite", [{"name": "not_tiles_match", "opts": [[-18], ["jihai", "flower"]]}], [["tag_dora", "jin", -18], ["reveal_tile", -18], ["copy_tiles", {"dead_wall": [-18]}, {"atop_wall": [-9]}], ["add_attr", [-18], ["_skip_draw", "_hidden"]]], [["run", "give_flower", {"flower": -18}]]]]],
  ["when", [{"name": "not_tag_exists", "opts": ["jin"]}], [["tag", "jin", "4x"]]]
]
