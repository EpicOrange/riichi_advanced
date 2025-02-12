.num_players = 3
|
.initial_score = 35000
|
.max_rounds = 6
|
.default_mods -= ["suufon_renda", "suucha_riichi"]
|
# add no tsumo loss mod to the list
(.available_mods | index("Abortive Draws")) as $ix | .available_mods |= .[:$ix] + [
  {"id": "sanma_no_tsumo_loss", "name": "No Tsumo Loss", "desc": "When you tsumo, you get the same total points as if it was a ron payment. (Mangan tsumo gives you 8000 total instead of 4000+2000.)"}
] + .[$ix:]
|
# remove manzu from wall
.wall -= [
  "2m", "2m", "2m", "2m",
  "3m", "3m", "3m", "3m",
  "4m", "4m", "4m", "4m",
  "5m", "5m", "5m", "5m",
  "6m", "6m", "6m", "6m",
  "7m", "7m", "7m", "7m",
  "8m", "8m", "8m", "8m"
]
|
# we need this in case kan mod is not enabled
.functions.do_kan_draw = [
  ["set_status", "$status"],
  ["shift_tile_to_dead_wall", 1],
  ["draw", 1, "opposite_end"]
]
|
# change "pei" set to "pei_triplet" (since our call is named "pei")
.set_definitions |= del(.pei)
|
.set_definitions.pei_triplet = ["4z", "4z", "4z"]
|
walk(if . == "pei" then "pei_triplet" else . end)
|
# change tenpai payments and add tsumo loss
.score_calculation += {
  "draw_tenpai_payments": [1000, 2000, 0],
  "tsumo_loss": true
}
|
.functions.discard_passed |= [["as", "others", [["unset_status", "pei"]]]] + .
|
# nukidora
.extra_yaku += [
  {
    "display_name": "Pei",
    "value": "nukidora",
    "when": [{"name": "counter_at_least", "opts": ["nukidora", 1]}]
  }
]
|
.before_win.actions += [["add_counter", "nukidora", "count_matches", ["flowers"], [[[["pei"], 1]]]]]
|
# no chii
.buttons |= del(.chii)
|
# add pei
.buttons.pei = {
  "display_name": "Pei",
  "show_when": ["our_turn", "not_no_tiles_remaining", "has_draw", {"name": "not_status", "opts": ["just_reached"]}, {"name": "match", "opts": [["hand", "draw"], [[[["4z"], 1]]]]}, {"name": "tile_not_drawn", "opts": [-8]}],
  "actions": [["big_text", "Pei"], ["flower", "4z"], ["run", "do_kan_draw", {"status": "pei"}], ["unset_status", "kan"]]
}
|
# add auto pei
.auto_buttons["5_auto_pei"] = {
  "display_name": "K",
  "desc": "Automatically declare pei.",
  "actions": [
    ["when", [{"name": "buttons_include", "opts": ["pei"]}], [["press_button", "pei"], ["press_first_call_button", "pei"]]]
  ],
  "enabled_at_start": true
}
|
# don't let auto discard button skip pei
.auto_buttons["4_auto_discard"].actions[0][1] |= map(if type == "object" and .name == "buttons_exclude" then .opts += ["pei"] else . end)
