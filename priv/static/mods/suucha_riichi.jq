.before_turn_change.actions = [
  ["when", [{"name": "everyone_status", "opts": ["riichi"]}], [
    ["add_score", -1000],
    ["put_down_riichi_stick"],
    ["unset_status", "just_reached"],
    ["pause", 1000],
    ["abortive_draw", "Suucha Riichi"]
  ]]
] + .before_turn_change.actions
