.after_start.actions += [
  ["push_system_message", "Declare your starting yaku"],
  ["set_status_all", "declaring_yaku"]
]
|
.play_restrictions += [
  [["any"], [{"name": "status", "opts": ["declaring_yaku"]}]]
]
|
.buttons |= with_entries(.value.show_when = [{"name": "status_missing", "opts": ["declaring_yaku"]}] + .value.show_when)
|
.buttons.declare_yaku = {
  "display_name": "Declare yaku",
  "show_when": [{"name": "status", "opts": ["declaring_yaku"]}],
  "actions": [
    ["choose_yaku"],
    ["unset_status", "declaring_yaku"]
  ],
  "unskippable": true,
  "cancellable": false
}
|
.declarable_yaku = [
  "Riichi",
  "Tsumo",
  "Ippatsu",
  "Chankan",
  "Rinshan",
  "Haitei",
  "Houtei",
  "Pinfu",
  "Tanyao",
  "Iipeikou",
  "Seat Wind",
  "Round Wind",
  "North Wind",
  "Haku",
  "Hatsu",
  "Chun",
  "Double Riichi",
  "Chiitoitsu",
  "Chanta",
  "Ittsu",
  "Sanshoku Doukou",
  "Sankantsu",
  "Toitoi",
  "Sanankou",
  "Shousangen",
  "Honroutou",
  "Ryanpeikou",
  "Junchan",
  "Honitsu",
  "Chinitsu",
  "Tenhou",
  "Chiihou",
  "Renhou",
  "Daisangen",
  "Suuankou",
  "Tsuuiisou",
  "Ryuuiisou",
  "Chinroutou",
  "Chuurenpoutou",
  "Kokushi Musou",
  "Daisuushii",
  "Shousuushii",
  "Suukantsu"
]
|
if (.buttons | has("ron")) then
  .buttons.ron.show_when += [{"name": "has_declared_yaku_with_hand", "opts": ["yaku", "meta_yaku", "yakuman", "meta_yakuman"]}]
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when += [{"name": "has_declared_yaku_with_hand", "opts": ["yaku", "meta_yaku", "yakuman", "meta_yakuman"]}]
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo.show_when += [{"name": "has_declared_yaku_with_hand", "opts": ["yaku", "meta_yaku", "yakuman", "meta_yakuman"]}]
else . end
