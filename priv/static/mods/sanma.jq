def fix_kan:
  .show_when |= map(if type == "object" and .name == "tile_not_drawn" then .opts = [-8] else . end)
  |
  .actions |= map(if type == "array" and .[0] == "run" and .[1] == "do_kan_draw" then .[2] = {"status": "kan"} else . end);

.num_players = 3
|
.initial_score = 35000
|
.default_mods -= ["suufon_renda", "suucha_riichi"]
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
# change "pei" set to "pei_triplet" (since our call is named "pei")
.set_definitions |= del(.pei)
|
.set_definitions.pei_triplet = ["4z", "4z", "4z"]
|
walk(if . == "pei" then "pei_triplet" else . end)
|
# change tenpai payments and add tsumo loss (TODO: no tsumo loss mod)
.score_calculation += {
  "draw_tenpai_payments": [1000, 2000, 0],
  "tsumo_loss": true
}
|
.functions.discard_passed += [["as", "others", [["unset_status", "pei"]]]]
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
.before_win.actions += [["add_counter", "nukidora", "count_matches", ["calls"], [[[["pei"], 1]]]]]
|
# no chii
.buttons |= del(.chii)
|
# fix kans
.buttons.daiminkan |= fix_kan
|
.buttons.kakan |= fix_kan
|
.buttons.ankan |= fix_kan
|
# add pei
.buttons.pei = {
  "display_name": "Pei",
  "show_when": ["our_turn", "has_draw", "not_just_discarded", {"name": "not_status", "opts": ["just_reached"]}, {"name": "match", "opts": [["hand", "draw"], [[[["4z"], 1]]]]}, {"name": "tile_not_drawn", "opts": [-8]}],
  "actions": [["big_text", "Pei"], ["flower", "4z"], ["run", "do_kan_draw", {"status": "pei"}], ["unset_status", "kan"]]
}
