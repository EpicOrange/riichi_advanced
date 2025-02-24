.after_initialization.actions += [["add_rule", "Nagashi", "If you end with an exhaustive draw, and no one has called any of your discards, and your discards are all terminal or honor tiles, a nagashi payment occurs, which is equivalent to a \($is) tsumo."]]
|
# start with nagashi set
.after_start.actions |= map(if .[0] == "set_status_all" then (. + ["nagashi"]) else . end)
|
# unset nagashi when called from
.before_call.actions += [["unset_status", "nagashi"]]
|
# unset nagashi when playing tanyaohai
.play_effects += [["tanyaohai", [["unset_status", "nagashi"]]]]
|
.score_calculation.draw_nagashi_payments = if $is == "Mangan" then [2000, 4000] else [8000, 16000] end
|
.score_calculation.nagashi_name = "Nagashi Mangan"
