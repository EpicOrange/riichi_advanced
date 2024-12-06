.wall |= (to_entries | map(if (.key % 4 != 0) then .value = [.value, "revealed", "transparent"] else . end) | map(.value))
