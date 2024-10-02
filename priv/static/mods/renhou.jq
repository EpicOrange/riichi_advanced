# add renhou yaku after chiihou
(.yakuman | map(.display_name == "Chiihou") | index(true)) as $ix
|
.yakuman |= .[:$ix+1] + [
  {
    "display_name": "Renhou",
    "value": 1,
    "when": [{"name": "status", "opts": ["discards_empty"]}, {"name": "status_missing", "opts": ["call_made"]}, "won_by_discard"]
  },
] + .[$ix+1:]
