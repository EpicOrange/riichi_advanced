# remove some preapplied mods
.default_mods |= map(select(IN("dora", "aka", "nagashi") | not))
|
# add kansai mods in front
.available_mods = [
  "Kansai",
  {"id": "kansai_draw", "name": "Draw To Dora Indicator", "desc": "The game ends once the next draw is the last dora indicator."},
  {"id": "kansai_flowers", "name": "Kansai Flowers (beta)", "desc": "Instead of north wind being nukidora, four flowers are added to the game and act as nukidora. North winds are now always yakuhai. This is in beta since north wind pairs do not yet grant 2 fu."},
  {"id": "kansai_aka", "name": "Kansai Aka", "desc": "Every five is akadora."},
  {"id": "kansai_yaku", "name": "Kansai Yaku", "desc": "Adds the following yaku: Three Consecutive Triplets (2 han), Four Consecutive Triplets (yakuman), Honitsu Chiitoitsu (6 han), Chinitsu Chiitoitsu (yakuman). In addition, Tsumo invalidates Pinfu."},
  {"id": "nagashi_yakuman", "name": "Nagashi Yakuman", "desc": "Nagashi is worth yakuman instead of mangan."},
  {"id": "kansai_no_furiten_riichi", "order": 1, "name": "No Furiten Riichi", "desc": "Riichi is disallowed while in furiten."},
  {"id": "kansai_30_fu", "conflicts": ["kansai_40_fu"], "name": "30 Fu", "desc": "Fu is fixed at 30."},
  {"id": "kansai_40_fu", "conflicts": ["kansai_30_fu"], "name": "40 Fu", "desc": "Fu is fixed at 40."}
] + .available_mods
|
.default_mods += ["kansai_draw", "kansai_flowers", "kansai_aka", "kansai_yaku", "nagashi_yakuman", "kansai_no_furiten_riichi", "kansai_30_fu"]
|
.score_calculation += {
  "tsumo_loss": false,
  "han_fu_rounding_factor": 1000
}
