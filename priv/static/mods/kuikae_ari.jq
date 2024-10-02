[
  {"name": "last_called_tile_matches", "opts": ["not_same"]}, 
  {"name": "last_called_tile_matches", "opts": ["not_kuikae"]}
] as $to_remove
|
.play_restrictions |= map(.[1][0]? |= map(select(. != $to_remove)))
