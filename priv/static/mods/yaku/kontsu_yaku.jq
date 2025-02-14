.set_definitions += {
  "kontsu_123": ["1z", "2z", "3z"],
  "kontsu_124": ["1z", "2z", "4z"],
  "kontsu_134": ["1z", "3z", "4z"],
  "kontsu_234": ["2z", "3z", "4z"],
  "kontsu_dragons": ["5z", "6z", "7z"],
  "fuun": ["1z", "2z", "3z", "4z"],
  "ryandoukon": [[0, 10, 20], [0, 10, 20]],
  "sandoukon": [[0, 10, 20], [0, 10, 20], [0, 10, 20]],
  "yondoukon": [[0, 10, 20], [0, 10, 20], [0, 10, 20], [0, 10, 20]]
}
|
# we need these to be set to 0.5 so that yaku precheck grant 0.5 han instead of 0
# TODO handle the case where you have 2+ dragon kontsu only, or 2+ wind kontsu only
.after_start.actions += [
  ["set_counter_all", "mini_sangen", 0.5],
  ["set_counter_all", "mixed_winds", 0.5]
]
|
.before_win.actions += [
  ["set_counter", "mini_sangen", 0],
  ["set_counter", "mixed_winds", 0],
  ["add_counter", "mini_sangen", "count_matches", ["hand", "calls", "winning_tile"], [[[["kontsu_dragons"], 1]]]],
  ["multiply_counter", "mini_sangen", 0.5],
  # count mixed winds that contain both prevalent and seat wind
  ["unless", [[{"name": "round_wind_is", "opts": ["north"]}, {"name": "seat_is", "opts": ["north"]}]], [["add_counter", "mixed_winds_123", "count_matches", ["hand", "calls", "winning_tile"], [[[["kontsu_123"], 1]]]]]],
  ["unless", [[{"name": "round_wind_is", "opts": ["west"]}, {"name": "seat_is", "opts": ["west"]}]], [["add_counter", "mixed_winds_124", "count_matches", ["hand", "calls", "winning_tile"], [[[["kontsu_124"], 1]]]]]],
  ["unless", [[{"name": "round_wind_is", "opts": ["south"]}, {"name": "seat_is", "opts": ["south"]}]], [["add_counter", "mixed_winds_134", "count_matches", ["hand", "calls", "winning_tile"], [[[["kontsu_134"], 1]]]]]],
  ["unless", [[{"name": "round_wind_is", "opts": ["east"]}, {"name": "seat_is", "opts": ["east"]}]], [["add_counter", "mixed_winds_234", "count_matches", ["hand", "calls", "winning_tile"], [[[["kontsu_234"], 1]]]]]],
  # the above counts will count fuuns, so subtract fuun count from each
  # "fuuns" in hand also contribute to double counting
  ["add_counter", "fuun_count", "count_matches", ["hand", "calls", "winning_tile"], [[[["fuun"], 1]]]],
  ["subtract_counter", "mixed_winds_123", "fuun_count"],
  ["subtract_counter", "mixed_winds_124", "fuun_count"],
  ["subtract_counter", "mixed_winds_134", "fuun_count"],
  ["subtract_counter", "mixed_winds_234", "fuun_count"],
  # add the counts up and multiply by 0.5
  ["when", [{"name": "counter_at_least", "opts": ["mixed_winds_123", 1]}], [["add_counter", "mixed_winds", "mixed_winds_123"]]],
  ["when", [{"name": "counter_at_least", "opts": ["mixed_winds_124", 1]}], [["add_counter", "mixed_winds", "mixed_winds_124"]]],
  ["when", [{"name": "counter_at_least", "opts": ["mixed_winds_134", 1]}], [["add_counter", "mixed_winds", "mixed_winds_134"]]],
  ["when", [{"name": "counter_at_least", "opts": ["mixed_winds_234", 1]}], [["add_counter", "mixed_winds", "mixed_winds_234"]]],
  ["when", [{"name": "counter_at_least", "opts": ["fuun_count", 1]}], [["add_counter", "mixed_winds", "fuun_count"]]],
  ["multiply_counter", "mixed_winds", 0.5]
]
|
.yaku += [
  { "display_name": "Mini-Sangen", "value": "mini_sangen", "when": [
    {"name": "counter_at_least", "opts": ["mini_sangen", 0.5]},
    {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["kontsu_dragons"], 1]]]]}
  ] },
  { "display_name": "Mixed Winds", "value": "mixed_winds", "when": [
    {"name": "counter_at_least", "opts": ["mixed_winds", 0.5]},
    [
      [{"name": "not_round_wind_is", "opts": ["north"]}, {"name": "not_seat_is", "opts": ["north"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["kontsu_123"], 1]]]]}],
      [{"name": "not_round_wind_is", "opts": ["west"]}, {"name": "not_seat_is", "opts": ["west"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["kontsu_124"], 1]]]]}],
      [{"name": "not_round_wind_is", "opts": ["south"]}, {"name": "not_seat_is", "opts": ["south"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["kontsu_134"], 1]]]]}],
      [{"name": "not_round_wind_is", "opts": ["east"]}, {"name": "not_seat_is", "opts": ["east"]}, {"name": "match", "opts": [["hand", "calls", "winning_tile"], [[[["kontsu_234"], 1]]]]}]
    ]
  ] },
  { "display_name": "Toikon", "value": 1, "when": [{"name": "match", "opts": [["hand", "calls", "winning_tile"], [[ "exhaustive", [["kontsu", "kontsu_123", "kontsu_124", "kontsu_134", "kontsu_234", "kontsu_dragons"], 4], [["pair"], 1]] ]]}] },
  {
    "display_name": "Ryandoukon",
    "value": 1,
    "when": [
      {"name": "has_no_call_named", "opts": ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"]},
      {"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], [[ "exhaustive", [["ryandoukon"], 1], [["shuntsu", "koutsu", "kontsu"], 2], [["pair"], 1]] ]]}
    ]
  },
  { "display_name": "Sandoukon", "value": 2, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], [[ "exhaustive", [["sandoukon"], 1], [["shuntsu", "koutsu", "kontsu"], 1], [["pair"], 1]] ]]}] }
]
|
# if kan mod doesn't add rinshan, we must
if .yaku | any(.display_name == "Rinshan") then . else
  .yaku += [{ "display_name": "Rinshan", "value": 1, "when": [{"name": "not_status_missing", "opts": ["kan", "fuun"]}]}]
end
|
.yakuman += [
  { "display_name": "Yondoukon", "value": 1, "when": [{"name": "match", "opts": [["hand", "call_tiles", "winning_tile"], [[[["yondoukon"], 1], [["pair"], 1]]]]}] }
]
|
.meta_yaku += [
  { "display_name": "Toikon", "value": 1, "when": [{"name": "has_no_call_named", "opts": ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"]}, {"name": "has_existing_yaku", "opts": ["Toikon"]}] },
  { "display_name": "Sandoukon", "value": 1, "when": [{"name": "has_no_call_named", "opts": ["ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan"]}, {"name": "has_existing_yaku", "opts": ["Sandoukon"]}] }
]
|
.yaku_precedence["Sanshoku Doukou"] += ["Sandoukon"]
|
.yaku_precedence["Kokushi Musou"] += ["Mixed Winds", "Mini-Sangen"]
|
.yaku_precedence["Kokushi Musou Juusan Menmachi"] += ["Mixed Winds", "Mini-Sangen"]
