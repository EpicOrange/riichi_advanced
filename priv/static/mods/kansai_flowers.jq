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
.buttons.flower.display_name = "Flower"
|
.buttons.flower.msg_name = "flower"
|
.buttons.flower.unskippable = true
|
.buttons.flower |= walk(if type == "array" and index("4z") then . - ["4z"] + ["1f", "2f", "3f", "4f"] else . end)
|
.auto_buttons._5_auto_flower.display_name = "F"
|
.auto_buttons._5_auto_flower.desc = "Automatically declare all flowers."
|
.auto_buttons._5_auto_flower.actions = [
        ["when", [{"name": "buttons_include", "opts": ["start_flower"]}], [["press_button", "start_flower"], ["press_first_call_button", "start_flower"]]],
        ["when", [{"name": "buttons_include", "opts": ["start_no_flower"]}], [["press_button", "start_no_flower"]]],
        ["when", [{"name": "buttons_include", "opts": ["flower"]}], [["press_button", "flower"], ["press_first_call_button", "flower"]]]
      ]
|
.auto_buttons._5_auto_flower.enabled_at_start = true
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
