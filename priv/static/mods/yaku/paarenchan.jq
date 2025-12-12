.after_initialization.actions += [["add_rule", "Yakuman", "Paarenchan", "The eighth consecutive dealer win is worth yakuman. Exhaustive and abortive draws break the streak. After 5 wins, the minimum han required for the dealer becomes 2 han.", 113]]
|
def ryanhan_shibari($check; $check_yakuman):
  [
    [
      {"name": "counter_at_most", "opts": ["paarenchan", 4]},
      {"name": $check, "opts": [1]}
    ],
    {"name": $check, "opts": [2]},
    {"name": $check_yakuman, "opts": [1]}
  ] as $cond
  |
  (map(type == "object" and .name == $check) | index(true)) as $ix
  |
  if $ix then (.[:$ix] + [$cond] + .[$ix+1:]) else (. + [$cond]) end;

# clear paarenchan if not dealer
.after_start.actions += [
  ["as", "not_east", [["set_counter", "paarenchan", 0]]]
]
|
# increment paarennchan if dealer
.before_win.actions += [
  ["when", [{"name": "seat_is", "opts": ["east"]}], [["add_counter", "paarenchan", 1]]]
]
|
# clear paarenchan on draws
.before_abortive_draw.actions += [
  ["set_counter_all", "paarenchan", 0]
]
|
.before_exhaustive_draw.actions += [
  ["set_counter_all", "paarenchan", 0]
]
|
# make paarenchan persistent
.persistent_counters += ["paarenchan"]
|
# add yakuman paarenchan
.yakuman += [
  {
    "display_name": "Paarenchan",
    "value": 1,
    "when": [{"name": "seat_is", "opts": ["east"]}, {"name": "counter_at_least", "opts": ["paarenchan", 8]}]
  }
]
|
# Ryanhan shibari for dealer at 5+ consecutive wins
if (.buttons | has("ron")) then
  .buttons.ron.show_when |= ryanhan_shibari("has_yaku_with_discard"; "has_yaku2_with_discard")
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when |= ryanhan_shibari("has_yaku_with_call"; "has_yaku2_with_call")
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when |= ryanhan_shibari("has_yaku_with_hand"; "has_yaku2_with_hand")
else . end
