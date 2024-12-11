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
