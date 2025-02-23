.after_initialization.actions += [["update_rule", "Chankan", "You may also call ron on concealed kans, but only if you are tenpai for kokushi musou."]]
|
[
  {"name": "last_call_is", "opts": ["kakan"]},
  {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
] as $check
|
[
  $check,
  [
    {"name": "last_call_is", "opts": ["ankan"]},
    {"name": "match", "opts": [["hand", "calls"], ["kokushi_tenpai"]]},
    {"name": "match", "opts": [["hand", "calls", "last_called_tile"], ["win"]]}
  ]
] as $new_check
|
if (.buttons | has("chankan")) then
  .buttons.chankan.show_when |= map(if . == $check then $new_check else . end)
else . end
