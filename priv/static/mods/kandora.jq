(.before_turn_change.actions | map(. as $e | if type == "array" and $e[0] == "unset_status" and ($e | index("kan")) then true else false end)
  | index(true)) as $idx
| 
.before_turn_change.actions |= 
(
  .[:$idx] + [
    ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_4"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_5"]}], [["reveal_tile", "doraindicator_5"]]],
    ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_3"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_4"]}], [["reveal_tile", "doraindicator_4"]]],
    ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_2"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_3"]}], [["reveal_tile", "doraindicator_3"]]],
    ["when", [{"name": "status", "opts": ["kan"]}, {"name": "not_status", "opts": ["ankan"]}, {"name": "tile_revealed", "opts": ["doraindicator_1"]}, {"name": "tile_not_revealed", "opts": ["doraindicator_2"]}], [["reveal_tile", "doraindicator_2"]]]
  ] + .[$idx:]
)
