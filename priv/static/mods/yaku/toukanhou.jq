.after_initialization.actions += [["add_rule", "Local Yaku (Yakuman)", "(Toukanhou) \"First Kan Win\". Win with rinshan from a kan (concealed or from a player) made before discarding any tile. Any call from an opponent invalidates this.", 113]]
|
.yakuman += [
  {
    "display_name": "Toukanhou",
    "value": 1,
    "when": [{"name": "status", "opts": ["toukanhou"]}]
  }
]
|
.before_call.actions = [
  ["when", [{"name": "status", "opts": ["discards_empty"]}], [["set_status", "tenhou_invalidated"]]]
] + .before_call.actions
|
.functions.discard_passed += [
  ["as", "others", [["unset_status", "toukanhou"]]]
]
|
.functions.do_kan_draw = [
  ["when", [{"name": "status", "opts": ["tenhou_invalidated"]}], [["set_status", "toukanhou"]]]
] + .functions.do_kan_draw
