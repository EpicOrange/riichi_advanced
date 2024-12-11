def replace_tenpai_check($source):
  {"name": "match", "opts": [["hand", "calls"], ["tenpai"]]} as $from
  |
  [{"name": "match", "opts": [["hand", "calls"], ["tenpai"]]}, {"name": "match", "opts": [["hand", "calls", $source], ["1861a 1865b NNN SSS"]]}] as $to
  |
  map(if . == $from then $to else . end);

(if .buttons | has("ton") then ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan", "anfuun", "ankan"] else ["chii", "pon", "daiminkan", "kakan", "ankan"] end) as $all_calls
|
.yakuman += [
  {
    "display_name": "American Civil War",
    "value": 1,
    "when": [
      {"name": "has_no_call_named", "opts": $all_calls},
      {"name": "match", "opts": [["hand", "winning_tile"], ["1861a 1865b NNN SSS"]]}
    ]
  }
]
|
.win_definition += ["1861a 1865b NNN SSS"]
|
# replace tenpai check
.buttons.ron.show_when |= replace_tenpai_check("last_discard")
|
.buttons.chankan.show_when |= replace_tenpai_check("last_called_tile")
|
.buttons.tsumo.show_when |= replace_tenpai_check("draw")
