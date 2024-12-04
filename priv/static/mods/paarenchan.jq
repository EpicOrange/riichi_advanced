# clear paarenchan if not dealer
.after_start.actions += [
  ["when_anyone", [{"name": "not_seat_is", "opts": ["east"]}], [["set_counter", "paarenchan", 0]]]
]
|
# increment paarennchan if dealer
.before_win.actions += [
  ["when", [{"name": "seat_is", "opts": ["east"]}], [["add_counter", "paarenchan", 1]]]
]
|
# clear paarenchan on draws
.before_abortive_draw.actions += [
  ["when_anyone", [], [["set_counter", "paarenchan", 0]]]
]
|
.before_exhaustive_draw.actions += [
  ["when_anyone", [], [["set_counter", "paarenchan", 0]]]
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
