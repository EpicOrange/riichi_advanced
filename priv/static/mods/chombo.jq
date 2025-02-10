def make_chombo_button($text; $win_action; $winning_tile; $yaku_check; $yaku2_check; $check):
  .show_when = [{"name": "not_status", "opts": ["just_reached"]}] + $check
  |
  .actions = [
    ["ite", [{"name": "match", "opts": [["hand", "calls", $winning_tile], ["win"]]}, [{"name": $yaku_check, "opts": [1]}, {"name": $yaku2_check, "opts": [1]}]], [
      ["big_text", $text], ["pause", 1000], ["reveal_hand"], [$win_action]
    ], [["run", "chombo", {"text": $text}]]]
  ];

def disable_when_dead:
  .show_when = [{"name": "status_missing", "opts": ["dead_hand"]}] + .show_when;

if (.buttons | has("ron")) then
  .buttons.ron |= make_chombo_button("Ron"; "win_by_discard"; "last_discard"; "has_yaku_with_discard"; "has_yaku2_with_discard"; ["not_our_turn", "someone_else_just_discarded"])
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan |= make_chombo_button("Ron"; "win_by_call"; "last_called_tile"; "has_yaku_with_call"; "has_yaku2_with_call"; ["not_our_turn", {"name": "last_call_is", "opts": ["kakan", "ankan"]}])
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo |= make_chombo_button("Tsumo"; "win_by_draw"; "draw"; "has_yaku_with_hand"; "has_yaku2_with_hand"; ["our_turn", "has_draw"])
else . end
|
.functions.chombo = [
  ["set_status", "dead_hand"],
  ["unset_status", "nagashi"],
  ["big_text", "$text"], ["pause", 1000], ["reveal_hand"],
  ["pause", 500],
  ["big_text", "Chombo"],
  ["pause", 500],
  ["uninterruptible_advance_turn"],
  ["when", ["our_turn"], [["uninterruptible_advance_turn"]]]
]
|
.shown_statuses |= map(select(. != "furiten"))
|
.after_turn_change.actions |= [
  ["ite", [{"name": "everyone_status", "opts": ["dead_hand"]}], [
    ["abortive_draw", "Chombo Game"]
  ], [
    ["ite", [{"name": "status", "opts": ["dead_hand"]}], [["uninterruptible_advance_turn"]], .]
  ]]
]
|
# disable all buttons when dead
.buttons |= with_entries(.value |= disable_when_dead)
|
# make riichi always available
.buttons.riichi.show_when |= map(select(. != {"name": "match", "opts": [["hand", "calls", "draw"], ["tenpai_14"]]}))
|
# you can riichi discard any tile
.play_restrictions |= map(select(. != [["any"], [{"name": "status", "opts": ["riichi", "just_reached"]}, {"name": "needed_for_hand", "opts": ["tenpai"]}]]))
