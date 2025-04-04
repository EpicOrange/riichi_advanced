.after_initialization.actions += [
  ["add_rule", "Rules", "Flowers", "- Declared flowers invalidate Concealed Hand."],
  ["add_rule", "1 Fan", "Concealed Hand", "- Declared flowers also invalidate Concealed Hand."]
]
|
(.yaku | map(.display_name == "Concealed Hand") | index(true)) as $ix
|
.yaku |= .[:$ix] + [
  {
    "display_name": "Concealed Hand",
    "value": 1,
    "when": [{"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan", "flower"]}]
  }
] + .[$ix+1:]
