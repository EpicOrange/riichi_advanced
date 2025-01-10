# replace another 5m, 5s in wall with 0m, 0s
(.wall | index("5m")) as $idx | if $idx then .wall[$idx] = "0m" else . end
|
(.wall | index("5s")) as $idx | if $idx then .wall[$idx] = "0s" else . end
