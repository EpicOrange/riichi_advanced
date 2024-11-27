(.yaku | map(.display_name == "Concealed Hand") | index(true)) as $ix
|
.yaku |= .[:$ix] + [
  {
    "display_name": "Concealed Hand",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan", "flower"]}]
  }
] + .[$ix+1:]
