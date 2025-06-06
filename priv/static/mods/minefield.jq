.default_mods |= map(select(IN("riichi_kan", "yaku/riichi", "kandora", "aka", "yaku/renhou_yakuman", "kyuushu_kyuuhai", "pao", "suufon_renda", "suucha_riichi", "suukaikan", "show_waits") | not))
|
.available_mods |= map(select(type != "object" or (.id | IN("riichi_kan", "yaku/riichi") | not)))
|
.starting_tiles = 34
|
.num_players = 2
|
.after_turn_change.actions |= map(
  if .[0] == "ite" and .[1] == ["no_tiles_remaining"] then
    .[1] = [{"name": "aside_tile_count", "opts": [4]}]
    |
    .[3] = []
  else . end
)
|
.functions.discard_passed += [
  ["when_everyone", [{"name": "status", "opts": ["match_start"]}, "not_has_aside"], [["pause", 1000], ["ryuukyoku"]]]
]
|
.play_restrictions = [
  [["any"], ["not_is_drawn_tile"]]
]
|
.yaku |= map(select(.display_name != "Round Wind"))
|
# remove all calls except for ron
.buttons |= del(.chii, .pon, .daiminkan, .kakan, .ankan, .riichi, .chankan, .tsumo)
|
.after_start.actions += [["set_status_all", "building"]]
|
.buttons += {
  "build": {
    "display_name": "Choose 13 tiles to form a mangan+ hand",
    "show_when": [{"name": "status", "opts": ["building"]}],
    "actions": [
      ["mark", [["hand", 13, ["self"]]]],
      ["move_tiles", {"hand": ["marked"]}, "aside"],
      ["clear_marking"],
      ["swap_tiles", "hand", "aside"],
      ["unset_status", "building"],
      ["when", [{"name": "not_anyone_status", "opts": ["building"]}], [
        ["set_status_all", "match_start", "just_reached", "riichi", "ippatsu"],
        ["as", "everyone", [["run", "place_riichi_stick"]]]
      ]]
    ],
    "unskippable": true,
    "cancellable": false
  },
  "discard": {
    "display_name": "Select a tile to discard",
    "show_when": ["our_turn", {"name": "status", "opts": ["match_start"]}, "not_has_draw", "not_just_discarded"],
    "actions": [
      ["mark", [["aside", 1, ["self"]]]],
      ["move_tiles", {"aside": ["marked"]}, "discard"],
      ["register_last_discard"],
      ["when", [{"name": "not_last_discard_matches", "opts": ["yaochuuhai"]}], [["unset_status", "nagashi"]]],
      ["clear_marking"],
      ["unset_status", "discards_empty"],
      ["recalculate_buttons"], # allow for ron to pop up
      ["run", "discard_passed"],
      ["advance_turn"]
    ],
    "unskippable": true,
    "cancellable": false
  }
}
|
if (.functions | has("calculate_dora")) then
  .functions.calculate_dora += [
    # ura doesn't count if we haven't actually won yet
    ["when", ["not_won"], [["set_counter", "ura", 0]]]
  ]
else . end
|
.buttons.ron.show_when |= [{"name": "status", "opts": ["match_start"]}] + .
|
.auto_buttons["_2_auto_ron"].enabled_at_start = true
|
.auto_buttons |= del(.["_3_auto_no_call"])
|
.auto_buttons["_4_auto_discard"].actions = [
  ["when", [{"name": "buttons_include", "opts": ["discard"]}], [["press_button", "discard"]]]
]
|
.auto_buttons["_4_auto_discard"].enabled_at_start = true
|
.display_riichi_sticks = false
|
.display_round_marker = false
|
.display_wall = false
|
# this is just to make aside clickable
.four_rows_discards = true
|
# dora counts towards mangan
.score_calculation.extra_yaku_lists = []
|
.available_mods |= map(if type == "object" then
  if .id == "tobi" then
    # set tobi default to <1000; we lose as we can't riichi
    .config[0].default = 1000
  elif .id == "min_han" then
    # default min han mod to mangan
    .config[0].default = "Mangan"
  else . end
else . end)
|
# note: doesn't handle washizu mod's 0.1x score multiplier
.available_mods |= map(if type == "object" and .id == "tobi" then .config[0].default = 1000 else . end)
|
.win_timer = 20
|
.display_riichi_sticks = true
