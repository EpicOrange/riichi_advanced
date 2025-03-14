.after_initialization.actions += [["add_rule", "Rules", "Wall", "(Chinitsu) The wall is composed of 16 copies of each bamboo tile.", -99]]
|
[
  "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", "1s", 
  "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", "2s", 
  "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", "3s", 
  "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", "4s", 
  "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", "5s", 
  "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", "6s", 
  "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", "7s", 
  "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", "8s", 
  "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s", "9s"
] as $wall
|
# ten support
(if any(.wall[]; . == "10s") then
  $wall + ["10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s", "10s"]
else
  $wall
end) as $wall
|
.wall = $wall
|
# skip sichuan voided suit prompt
if (.buttons | has("void_souzu")) then
  .after_charleston.actions += [["as", "everyone", [["unset_status", "round_start"], ["set_status", "void_manzu"]]]]
  |
  .
  .buttons |= del(.void_manzu, .void_pinzu, .void_souzu)
else . end
