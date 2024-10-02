.before_call.actions |= map(if .[0] == "unset_status" then (. + ["nagashi"]) else . end)
|
.play_effects += [["tanyaohai", [["unset_status", "nagashi"]]]]
|
.after_start.actions |= map(if .[0] == "set_status_all" then (. + ["nagashi"]) else . end)
