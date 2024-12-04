.before_win.actions += [
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-6]}], [["add_counter", "shuugi_payment", "count_dora", -5, ["hand", "calls", "winning_tile"]]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-8]}], [["add_counter", "shuugi_payment", "count_dora", -7, ["hand", "calls", "winning_tile"]]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-10]}], [["add_counter", "shuugi_payment", "count_dora", -9, ["hand", "calls", "winning_tile"]]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-12]}], [["add_counter", "shuugi_payment", "count_dora", -11, ["hand", "calls", "winning_tile"]]]],
  ["when", [{"name": "status", "opts": ["riichi"]}, {"name": "tile_revealed", "opts": [-14]}], [["add_counter", "shuugi_payment", "count_dora", -13, ["hand", "calls", "winning_tile"]]]],
  ["when", [{"name": "status", "opts": ["aka_m"]}], [["add_counter", "shuugi_payment", 1]]],
  ["when", [{"name": "status", "opts": ["aka_p"]}], [["add_counter", "shuugi_payment", 1]]],
  ["when", [{"name": "status", "opts": ["aka_s"]}], [["add_counter", "shuugi_payment", 1]]],
  ["when", [{"name": "status", "opts": ["ippatsu"]}, {"name": "status_missing", "opts": ["call_made"]}], [["add_counter", "shuugi_payment", 1]]],
  ["add_counter", "shuugi_payment", "toriuchi"], # toriuchi support (toriuchi must be loaded before shuugi)
  ["set_counter_all", "shuugi_payment", "shuugi_payment"],
  ["when", ["won_by_discard"], [
    ["push_message", "is paid 1 shuugi from discarder for each aka dora, ura dora, and ippatsu in hand"],
    ["as", "last_discarder", [["subtract_counter", "shuugi", "shuugi_payment"]]],
    ["add_counter", "shuugi", "shuugi_payment"]
  ]],
  ["when", ["won_by_draw"], [
    ["push_message", "is paid 1 shuugi from each player for each aka dora, ura dora, and ippatsu in hand"],
    ["as", "others", [["subtract_counter", "shuugi", "shuugi_payment"]]],
    ["add_counter", "shuugi", "shuugi_payment"],
    ["add_counter", "shuugi", "shuugi_payment"],
    ["add_counter", "shuugi", "shuugi_payment"]
  ]]
]
|
.after_start.actions += [["when_anyone", [], [["add_counter", "shuugi", 0]]]]
|
.before_conclusion.actions += [
  ["push_system_message", "Converted each shuugi to 2000 points."],
  ["as", "everyone", [
    ["set_counter", "shuugi_payout", "shuugi"],
    ["multiply_counter", "shuugi_payout", 2000],
    ["add_score", "shuugi_payout"]
  ]]
]
|
.persistent_counters += ["shuugi"]
|
.shown_statuses_public += ["shuugi"]