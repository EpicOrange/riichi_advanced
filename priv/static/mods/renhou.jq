# add renhou yakuman after chiihou
(.yakuman | if . then map(.display_name == "Chiihou") else [] end | index(true)) as $ix
|
if $ix then
  .yakuman |= .[:$ix+1] + [
    {
      "display_name": "Renhou",
      "value": 1,
      "when": [{"name": "status", "opts": ["discards_empty"]}, {"name": "status_missing", "opts": ["call_made"]}, "won_by_discard"]
    }
  ] + .[$ix+1:]
else . end
