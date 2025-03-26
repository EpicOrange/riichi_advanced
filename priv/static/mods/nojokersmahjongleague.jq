def change_button_name($button; $text):
  .display_name = $button
  |
  .actions |= map(if .[0] == "big_text" then .[1] = $text else . end);

.initial_score = 250
|
.score_calculation += {
  "han_fu_multiplier": 0.04,
  "han_fu_rounding_factor": 1,
  "fixed_fu": 30,
  "score_multiplier": 320,
  "limit_scores": [
    80, 80, 80,
    120,
    160,
    240,
    320
  ],
  "use_smt": false,
  "draw_tenpai_payments": [10, 15, 30],
  "draw_nagashi_payments": [20, 40],
  "riichi_value": 10,
  "honba_value": 1,
  "score_denomination": "¢",
  "point_name": "Pts",
  "win_by_discard_label": "Discard",
  "win_by_draw_label": "Draw",
  "win_by_discard_name": "Mah Jongg",
  "win_by_discard_name_2": "Mah Jongg",
  "win_by_discard_name_3": "Mah Jongg",
  "win_by_draw_name": "Mah Jongg",
  "win_with_pao_name": "Mah Jongg",
  "exhaustive_draw_name": "Draw",
}
|
if (.buttons | has("chii")) then
  .buttons.chii |= change_button_name("Run"; "Run")
else . end
|
if (.buttons | has("pon")) then
  .buttons.pon |= change_button_name("Pung"; "Pung")
else . end
|
if (.buttons | has("daiminkan")) then
  .buttons.daiminkan |= change_button_name("Kong"; "Kong")
else . end
|
if (.buttons | has("ankan")) then
  .buttons.ankan |= change_button_name("Concealed Kong"; "Kong")
else . end
|
if (.buttons | has("kakan")) then
  .buttons.kakan |= change_button_name("Kong"; "Kong")
else . end
|
if (.buttons | has("riichi")) then
  .buttons.riichi |= change_button_name("Declare Ready"; "Ready")
else . end
|
if (.buttons | has("ron")) then
  .buttons.ron |= change_button_name("Mah Jongg"; "Mah Jongg")
else . end
|
if (.buttons | has("chankan")) then
  .buttons.chankan |= change_button_name("Mah Jongg"; "Mah Jongg")
else . end
|
if (.buttons | has("tsumo")) then
  .buttons.tsumo |= change_button_name("Mah Jongg"; "Mah Jongg")
else . end
|
.translations = {
  "Riichi": "Miscellaneous #1 (Ready)",
  "Tsumo": "Miscellaneous #4 (Self Draw)",
  "Ippatsu": "Miscellaneous #3 (One-Shot)",
  "Chankan": "Miscellaneous #7 (Stealing a Kong)",
  "Rinshan": "Miscellaneous #6 (Replacement Tile)",
  "Haitei": "Miscellaneous #5 (Last Tile)",
  "Houtei": "Miscellaneous #5 (Last Tile)",
  "Pinfu": "Consecutive Run #5 (All Sequences)",
  "Tanyao": "2345678 #1 (All Simples)",
  "Iipeikou": "Consecutive Run #3 (Identical Runs)",
  "Seat Wind": "Honors #1 (Seat Wind)",
  "Round Wind": "Honors #1 (Round Wind)",
  "Haku": "Honors #1 (White Dragon)",
  "Hatsu": "Honors #1 (Green Dragon)",
  "Chun": "Honors #1 (Red Dragon)",
  "Double Riichi": "Miscellaneous #2 (Double Ready)",
  "Chiitoitsu": "Pungs and Pairs #1 (Seven Pairs)",
  "Chanta": "2345678 #2 (Half Outside Hand)",
  "Ittsu": "Consecutive Run #2 (Pure Straight)",
  "Sanshoku": "Consecutive Run #1 (Mixed Runs)",
  "Sanshoku Doukou": "Pungs and Pairs #3 (Mixed Triplets)",
  "Sankantsu": "Kongs #1 (Three Kongs)",
  "Toitoi": "Pungs and Pairs #2 (All Triplets)",
  "Sanankou": "Pungs and Pairs #4 (Three Concealed Triplets)",
  "Shousangen": "Honors #2 (Little Three Dragons)",
  "Honroutou": "2345678 #3 (Mixed Terminals)",
  "Ryanpeikou": "Consecutive Run #4 (Two Identical Runs)",
  "Junchan": "2345678 #4 (Pure Outside Hand)",
  "Honitsu": "One Suit #1 (Half Flush)",
  "Chinitsu": "One Suit #2 (Full Flush)",
  "Tenhou": "Miscellaneous #8 (Hand of Heaven)",
  "Chiihou": "Miscellaneous #8 (Hand of Earth)",
  "Daisangen": "Honors #3 (Big Three Dragons)",
  "Suuankou": "Pungs and Pairs #5 (Four Concealed Triplets)",
  "Tsuuiisou": "Honors #6 (All Honors)",
  "Ryuuiisou": "One Suit #3 (All Green)",
  "Chinroutou": "2345678 #5 (All Terminals)",
  "Chuurenpoutou": "One Suit #4 (Nine Gates)",
  "Kokushi Musou": "Honors #7 (Thirteen Orphans)",
  "Daisuushii": "Honors #5 (Big Four Winds)",
  "Shousuushii": "Honors #4 (Little Four Winds)",
  "Suukantsu": "Kongs #2 (Four Kongs)",
  "Dora": "Bonus Tile",
  "Ura": "Additional Bonus Tile"
}
|
.available_mods = [
  {"id": "show_waits", "name": "Show Waits", "desc": "Add some UI that shows waits."},
  {"id": "open_hands", "name": "Open Hands", "desc": "Everyone plays with tiles shown."}
]
|
.default_mods = []
