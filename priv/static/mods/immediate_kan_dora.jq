# TODO make this a config option for kandora mod instead

def insert_after_kan_draw($arr):
  (map(. == ["run", "do_kan_draw"]) | index(true)) as $ix
  |
  if $ix then (.[:$ix+1] + $arr + .[$ix+1:]) else . end;

.after_initialization.actions += [
  ["delete_rule", "Kandora"],
  ["add_rule", "Kandora", "Every kan reveals another dora indicator immediately."]
]
|
# dora flips immediately after daiminkan
# set status to prevent dora flip after turn change
if (.buttons | has("daiminkan")) then
  .buttons.daiminkan.actions |= insert_after_kan_draw([["run", "flip_dora"], ["set_status", "skip_kan_dora_flip"]])
else . end
|
# dora flips immediately after kakan
# set status to prevent dora flip after turn change
if (.buttons | has("kakan")) then
  .buttons.kakan.actions |= insert_after_kan_draw([["run", "flip_dora"], ["set_status", "skip_kan_dora_flip"]])
else . end
