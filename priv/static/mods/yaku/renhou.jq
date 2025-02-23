.after_initialization.actions += [["add_rule", "Local Yaku (\($is))", "(Renhou) \($is) if you win off the first tile someone dropped before your first draw. Calls invalidate."]]
|
if $is == "Mangan" then
  .yaku_renhou += [
    {
      "display_name": "Renhou",
      "value": 5,
      "when": [
        {"name": "not_has_points", "opts": [5]},
        {"name": "status", "opts": ["discards_empty"]},
        "won_by_discard"
      ]
    }
  ]
  |
  .yaku_precedence += {
    "Renhou": [1, 2, 3, 4]
  }
  |
  if .score_calculation.yaku_lists | any(index("yaku_renhou")) then . else
    .score_calculation.yaku_lists += ["yaku_renhou"]
  end
else
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
end