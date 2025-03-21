# remove pei call
.buttons |= del(.pei)
|
# remove pei autobutton
.auto_buttons |= del(.["_5_auto_pei"])
|
# pei pair gives yakuhai 2 fu
.score_calculation.north_wind_yakuhai = true
|
# add flowers
.wall += ["1f", "2f", "3f", "4f"]
|
# add flower bonus
.extra_yaku += [
  {
    "display_name": "Flower",
    "value": "flowers",
    "when": [{"name": "counter_at_least", "opts": ["flowers", 1]}]
  }
]
|
# add flower call (identical to pei call, but is forced)
.buttons.flower = {
  "display_name": "Flower",
  "show_when": ["our_turn", "not_no_tiles_remaining", "has_draw", {"name": "not_status", "opts": ["just_reached"]}, {"name": "match", "opts": [["hand", "draw"], [[[["1f", "2f", "3f", "4f"], 1]]]]}, {"name": "tile_not_drawn", "opts": [-8]}],
  "actions": [["big_text", "Flower"], ["flower", "1f", "2f", "3f", "4f"], ["run", "do_kan_draw", {"status": "pei"}], ["unset_status", "kan"]],
  "unskippable": true
}
|
# add flower autobutton
.auto_buttons["_5_auto_flower"] = {
  "display_name": "F",
  "desc": "Automatically declare all flowers.",
  "actions": [
    ["when", [{"name": "buttons_include", "opts": ["flower"]}], [["press_button", "flower"], ["press_first_call_button", "flower"]]]
  ],
  "enabled_at_start": true
}
|
# add flower dora indicators
.dora_indicators += {
  "1f": ["2f","3f","4f"],
  "2f": ["1f","3f","4f"],
  "3f": ["1f","2f","4f"],
  "4f": ["1f","2f","3f"]
}
|
# count flowers
.before_win.actions += [
  ["add_counter", "flowers", "count_matches", ["flowers"], [[ "nojoker", [["1f","2f","3f","4f"], 1] ]]]
]
