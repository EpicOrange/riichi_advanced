# start with nagashi set
.after_start.actions |= map(if .[0] == "set_status_all" then (. + ["nagashi"]) else . end)
|
# unset nagashi when called from
.before_call.actions += [["unset_status", "nagashi"]]
|
# unset nagashi when playing tanyaohai
.play_effects += [["tanyaohai", [["unset_status", "nagashi"]]]]
