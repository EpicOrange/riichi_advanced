.buttons.riichi.actions += [
  ["when", [{"name": "everyone_status", "opts": ["riichi"]}], [
    ["add_score", -1000],
    ["put_down_riichi_stick"],
    ["pause", 1000],
    ["abortive_draw", "Suucha Riichi"]
  ]]
]
