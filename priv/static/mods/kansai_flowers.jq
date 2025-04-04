# remove pei call
.buttons |= del(.pei)
|
# remove pei autobutton
.auto_buttons |= del(.["_5_auto_pei"])
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
.buttons.flower.unskippable = true
|
.buttons.flower |= walk(if type == "array" and index("4z") then . - ["4z"] + ["1f", "2f", "3f", "4f"] else . end)
|
.auto_buttons._5_auto_pei.display_name = "F"
|
.auto_buttons._5_auto_pei.desc = "Automatically declare all flowers."
|
# add flower dora indicators
.dora_indicators += {
  "1f": ["2f","3f","4f"],
  "2f": ["1f","3f","4f"],
  "3f": ["1f","2f","4f"],
  "4f": ["1f","2f","3f"]
}
|
# count flowers, stop counting pei
.before_win.actions += [
  ["add_counter", "flowers", "count_matches", ["flowers"], [[ "nojoker", [["1f","2f","3f","4f"], 1] ]]],
  ["set_counter", "nukidora", 0]
]
