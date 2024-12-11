[["any"], ["just_called", {"name": "last_called_tile_matches", "opts": ["kuikae"]}]] as $to_remove
|
.play_restrictions |= map(select(. != $to_remove))
