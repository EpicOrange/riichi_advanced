.yaku += [
  { "display_name": "Chankan", "value": 1, "when": ["won_by_call"] },
  { "display_name": "Rinshan", "value": 1, "when": [{"name": "status", "opts": ["kan"]}] },
  { "display_name": "Sankantsu", "value": 2, "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ [["daiminkan", "ankan", "kakan"], 3] ]]]}] }
]
|
.yakuman += [
  { "display_name": "Suukantsu", "value": 1, "when": [{"name": "match", "opts": [["calls"], [[[["daiminkan", "ankan", "kakan"], 4]]]]}] }
]
|
.functions.do_kan_draw = [
  # variable is to accommodate sanma
  ["set_status", "$status"],
  ["shift_tile_to_dead_wall", 1],
  ["draw", 1, "opposite_end"]
]
|
.functions.discard_passed |= [["as", "others", [["unset_status", "kan"]]]] + . + [
  # additional furiten check
  ["when_anyone",
    [[
      [
        {"name": "last_call_is", "opts": ["kakan"]},
        {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
      ],
      [
        {"name": "last_call_is", "opts": ["ankan"]},
        {"name": "match", "opts": [["hand", "calls", "draw"], ["kokushi_tenpai"]]},
        {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
      ]
    ]],
    [["set_status", "furiten"]]
  ]]
|
if (.buttons | has("ron")) then
  .buttons.ron.precedence_over += ["daiminkan"]
else . end
|
.buttons.daiminkan = {
  "display_name": "Kan",
  "call": [[0, 0, 0]],
  "call_style": {"kamicha": ["call_sideways", 0, 1, 2], "toimen": [0, "call_sideways", 1, 2], "shimocha": [0, 1, 2, "call_sideways"]},
  "show_when": ["not_our_turn", "not_no_tiles_remaining", "someone_else_just_discarded", {"name": "tile_not_drawn", "opts": [-4]}, "call_available"],
  "actions": [["big_text", "Kan"], ["call"], ["change_turn", "self"], ["run", "do_kan_draw", {"status": "kan"}]],
  "precedence_over": ["chii", "pon", "daiminkan"]
}
|
.buttons.ankan = {
  "display_name": "Ankan",
  "call": [[0, 0, 0]],
  "call_style": {"self": [["1x", 2], 0, 1, ["1x", 3]]},
  "show_when": ["our_turn", "not_no_tiles_remaining", "has_draw", {"name": "status_missing", "opts": ["just_reached"]}, {"name": "tile_not_drawn", "opts": [-4]}, "self_call_available"],
  "actions": [["big_text", "Kan"], ["self_call"], ["run", "do_kan_draw", {"status": "kan"}]]
}
|
.buttons.kakan = {
  "display_name": "Kan",
  "call": [[0, 0, 0]],
  "call_style": {
    "kamicha": [["sideways", 0], "call_sideways", 1, 2],
    "toimen": [0, ["sideways", 1], "call_sideways", 2],
    "shimocha": [0, 1, ["sideways", 2], "call_sideways"]
  },
  "upgrades": "pon",
  # not sure why we have "not_just_discarded", "not_just_called" instead of "has_draw"
  "show_when": ["our_turn", "not_no_tiles_remaining", "not_just_discarded", "not_just_called", "can_upgrade_call", {"name": "status_missing", "opts": ["just_reached"]}, {"name": "tile_not_drawn", "opts": [-4]}],
  "actions": [["big_text", "Kan"], ["upgrade_call"], ["run", "do_kan_draw", {"status": "kan"}]]
}
|
.buttons.chankan = {
  "display_name": "Ron",
  "show_when": [
    "not_our_turn",
    {"name": "match", "opts": [["hand", "calls"], ["tenpai"]]},
    {"name": "status_missing", "opts": ["furiten"]},
    {"name": "status_missing", "opts": ["just_reached"]},
    [
      [
        {"name": "last_call_is", "opts": ["kakan"]},
        {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
      ],
      [
        {"name": "last_call_is", "opts": ["ankan"]},
        {"name": "match", "opts": [["hand", "calls"], ["kokushi_tenpai"]]},
        {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
      ]
    ]
  ],
  "actions": [["big_text", "Ron"], ["pause", 1000], ["reveal_hand"], ["win_by_call"]],
  "precedence_over": ["chii", "pon", "daiminkan"]
}
