[{"name": "last_called_tile_matches", "opts": ["kuikae"]}] as $to_remove
|
.play_restrictions |= map(.[1][0]? |= map(select(. != $to_remove)))
