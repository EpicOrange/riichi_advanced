.wall |= map(select(IN("1f","2f","3f","4f","1g","2g","3g","4g") | not))
|
.after_start.actions += [
  ["unset_status_all", "match_start"]
]
|
.yaku |= map(select(.display_name | IN("No Flowers", "Seat Flower", "Seat Season", "Improper Flower", "Improper Season", "Proper Flower", "Proper Season", "All Flowers", "All Seasons", "Four Flowers", "Four Seasons", "Seven Flowers", "Eight Flowers") | not))
