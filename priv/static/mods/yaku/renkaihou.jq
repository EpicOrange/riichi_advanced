.yaku += [
  {
    "display_name": "Renkaihou",
    "value": 2,
    "when": [{"name": "status", "opts": ["double_kan"]}]
  }
]
|
.yaku_precedence += {
  "Renkaihou": ["Rinshan"]
}
|
.functions.discard_passed += [
  ["as", "others", [["unset_status", "double_kan"]]]
]
|
.functions.do_kan_draw = [
  ["when", [{"name": "status", "opts": ["kan"]}], [["set_status", "double_kan"]]]
] + .functions.do_kan_draw
