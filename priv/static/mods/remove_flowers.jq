.wall |= map(select(IN("1f","2f","3f","4f","1g","2g","3g","4g") | not))
|
.after_start.actions += [
  ["unset_status_all", "match_start"]
]
|
.yaku |= map(select(.display_name | IN("No Flowers", "Seat Flower", "Seat Season", "All Flowers", "All Seasons", "Seven Flowers", "Eight Flowers") | not))
