# sanma calls it pei_triplet
(if .set_definitions | has("pei_triplet") then "pei_triplet" else "pei" end) as $pei
|
.after_call.actions += [
  ["when", [{"name": "last_call_is", "opts": ["pon", "daiminkan"]}, {"name": "match", "opts": [["last_call"], [[[["haku", "hatsu", "chun"], 1]]]]}, {"name": "match", "opts": [["calls"], [[[["haku"], 1], [["hatsu"], 1], [["chun"], 1]]]]}], [["as", "callee", [["set_status", "pao"]]]]],
  ["when", [{"name": "last_call_is", "opts": ["pon", "daiminkan"]}, {"name": "match", "opts": [["last_call"], [[[["ton", "nan", "shaa", $pei], 1]]]]}, {"name": "match", "opts": [["calls"], [[[["ton"], 1], [["nan"], 1], [["shaa"], 1], [[$pei], 1]]]]}], [["as", "callee", [["set_status", "pao"]]]]]
]
|
.score_calculation.pao_eligible_yaku += ["Daisangen", "Daisuushii"]
|
.score_calculation.win_with_pao_name = "Sekinin Barai"
