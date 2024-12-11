# replace another 5p in wall with 0p
(.wall | index("5p")) as $idx | if $idx then .wall[$idx] = "0p" else . end
