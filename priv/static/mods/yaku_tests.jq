.run_yaku_tests = true
|
.yaku_tests = [
  {
    "name": "open tanyao sanshoku",
    "hand": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m"],
    "calls": [["pon", ["5m", "5m", "5m"]]],
    "winning_tile": "7m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Tanyao", 1], ["Sanshoku", 1]]
  },
  {
    "name": "non-pinfu closed tsumo sanshoku",
    "hand": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m", "7m", "8m", "9m"],
    "calls": [],
    "winning_tile": "7m",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Tsumo", 1], ["Sanshoku", 2]]
  },
  {
    "name": "pinfu tsumo",
    "hand": ["2m", "3m", "4m", "2s", "3s", "4s", "2p", "3p", "4p", "7m", "8m", "9m", "9m"],
    "calls": [],
    "winning_tile": "9m",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Tsumo", 1], ["Pinfu", 1], ["Sanshoku", 2]]
  },
  {
    "name": "yakuless closed",
    "hand": ["2m", "3m", "2s", "2s", "2s", "7s", "8s", "9s", "4p", "0p", "6p", "6p", "6p"],
    "calls": [],
    "winning_tile": "1m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "yakuless open pinfu",
    "hand": ["1m", "2m", "3m", "6m", "7m", "8m", "5p", "5p", "7p", "8p"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "6p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "pinfu chankan",
    "hand": ["2m", "3m", "4m", "6m", "7m", "8m", "5p", "6p", "7p", "8p", "9p", "9p", "9p"],
    "calls": [],
    "winning_tile": "7p",
    "win_source": "call",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chankan", 1], ["Pinfu", 1]]
  },
  {
    "name": "rinshan",
    "hand": ["6m", "7m", "8m", "5p", "6p", "7p", "8p", "9p", "9p", "9p"],
    "calls": [["daiminkan", ["2m", "2m", "2m", "2m"]]],
    "status": ["kan"],
    "winning_tile": "7p",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Rinshan", 1]]
  },
  {
    "name": "double east",
    "hand": ["1m", "2m", "3m", "1z", "1z", "1z", "5p", "5p", "7p", "8p"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "6p",
    "round": 3,
    "seat": "east",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Seat Wind", 1], ["Round Wind", 1]]
  },
  {
    "name": "south round east wind",
    "hand": ["1m", "2m", "3m", "1z", "1z", "1z", "5p", "5p", "7p", "8p"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "6p",
    "round": 4,
    "seat": "east",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Seat Wind", 1]]
  },
  {
    "name": "south round double south",
    "hand": ["1m", "2m", "3m", "2z", "2z", "2z", "5p", "5p", "7p", "8p"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "6p",
    "round": 4,
    "seat": "south",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Seat Wind", 1], ["Round Wind", 1]]
  },
  {
    "name": "south round wrong winds",
    "hand": ["3z", "3z", "3z", "1z", "1z", "1z", "5m", "5m", "7m", "8m"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "6p",
    "round": 5,
    "seat": "north",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "open iipeikou chun",
    "hand": ["7z", "7z", "7z", "1m", "1m", "2m", "2m", "3m", "7m", "7m"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "3m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chun", 1]]
  },
  {
    "name": "closed iipeikou chun",
    "hand": ["7z", "7z", "7z", "1m", "1m", "2m", "2m", "3m", "7m", "7m", "2p", "3p", "4p"],
    "winning_tile": "3m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Iipeikou", 1], ["Chun", 1]]
  },
  {
    "name": "chiitoitsu",
    "hand": ["1m", "1m", "4m", "4m", "5m", "5m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
    "winning_tile": "4p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chiitoitsu", 2]]
  },
  {
    "name": "invalid chiitoitsu with quad",
    "hand": ["1m", "1m", "4m", "4m", "4m", "4m", "2p", "2p", "4p", "6s", "6s", "1z", "1z"],
    "winning_tile": "4p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "ryanpeikou with quad",
    "hand": ["1m", "1m", "2m", "2m", "3m", "3m", "3m", "4m", "4m", "5m", "5m", "1s", "1s"],
    "winning_tile": "3m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Pinfu", 1], ["Ryanpeikou", 3]]
  },
  {
    "name": "ryanpeikou with closed quad",
    "hand": ["1m", "1m", "2m", "2m", "3m", "3m", "3m", "3m", "4m", "5m", "5m", "1s", "1s"],
    "winning_tile": "4m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Ryanpeikou", 3]]
  },
  {
    "name": "big wheels",
    "hand": ["2p", "2p", "3p", "3p", "4p", "4p", "5p", "5p", "6p", "6p", "7p", "7p", "8p"],
    "winning_tile": "8p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Pinfu", 1], ["Tanyao", 1], ["Ryanpeikou", 3], ["Chinitsu", 6]]
  },
  {
    "name": "open chanta sanshoku",
    "hand": ["1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "2z", "2z"],
    "calls": [["chii", ["1m", "2m", "3m"]]],
    "winning_tile": "9p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chanta", 1], ["Sanshoku", 1]]
  },
  {
    "name": "closed chanta",
    "hand": ["1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s", "2z", "2z"],
    "winning_tile": "9p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chanta", 2]]
  },
  {
    "name": "open junchan",
    "hand": ["1m", "1m", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s"],
    "calls": [["chii", ["1p", "2p", "3p"]]],
    "winning_tile": "9p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Junchan", 2]]
  },
  {
    "name": "closed junchan",
    "hand": ["1m", "1m", "1p", "2p", "3p", "1s", "2s", "3s", "7p", "8p", "9s", "9s", "9s"],
    "winning_tile": "9p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Junchan", 3]]
  },
  {
    "name": "open ittsu",
    "hand": ["1m", "1m", "4p", "5p", "6p", "7p", "8p"],
    "calls": [["chii", ["1p", "2p", "3p"]], ["chii", ["7p", "8p", "9p"]]],
    "winning_tile": "6p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Ittsu", 1]]
  },
  {
    "name": "false open ittsu",
    "hand": ["1m", "1m", "3p", "4p", "5p", "6p", "7p"],
    "calls": [["chii", ["1p", "2p", "3p"]], ["chii", ["7p", "8p", "9p"]]],
    "winning_tile": "5p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "closed ittsu",
    "hand": ["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "7p", "8p", "9p", "9s", "9s"],
    "winning_tile": "9m",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Pinfu", 1], ["Ittsu", 2]]
  },
  {
    "name": "sanshoku doukou",
    "hand": ["2m", "2m", "2m", "8p", "9p", "9s", "9s"],
    "calls": [["pon", ["2p", "2p", "2p"]], ["pon", ["2s", "2s", "2s"]]],
    "winning_tile": "7p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Sanshoku Doukou", 2]]
  },
  {
    "name": "sankantsu",
    "hand": ["8p", "9p", "9s", "9s"],
    "calls": [["daiminkan", ["2p", "2p", "2p", "2p"]], ["kakan", ["2m", "2m", "2m", "2m"]], ["ankan", ["7z", "7z", "7z"]]],
    "winning_tile": "7p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Chun", 1], ["Sankantsu", 2]]
  },
  {
    "name": "open toitoi shousangen honitsu",
    "hand": ["7p", "7p", "9s", "9s", "9s", "6z", "6z"],
    "calls": [["daiminkan", ["5z", "5z", "5z", "5z"]], ["pon", ["7z", "7z", "7z"]]],
    "winning_tile": "7p",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Haku", 1], ["Chun", 1], ["Toitoi", 2], ["Shousangen", 2]]
  },
  {
    "name": "closed honitsu honroutou",
    "hand": ["1m", "1m", "1m", "9m", "9m", "9m", "2z", "2z", "2z", "3z", "3z", "5z", "5z"],
    "winning_tile": "5z",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Haku", 1], ["Toitoi", 2], ["Sanankou", 2], ["Honroutou", 2], ["Honitsu", 3]]
  },
  {
    "name": "sanankou open one pon",
    "hand": ["1m", "1m", "1m", "7s", "7s", "7s", "3z", "3z", "5z", "5z"],
    "calls": [["pon", ["2p", "2p", "2p"]]],
    "winning_tile": "3z",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Toitoi", 2], ["Sanankou", 2]]
  },
  {
    "name": "sanankou open one chii",
    "hand": ["1m", "1m", "1m", "7s", "7s", "7s", "3z", "3z", "5z", "5z"],
    "calls": [["chii", ["2p", "3p", "4p"]]],
    "winning_tile": "3z",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Sanankou", 2]]
  },
  {
    "name": "no sanankou one pon",
    "hand": ["1m", "1m", "1m", "7s", "8s", "9s", "3z", "3z", "5z", "5z"],
    "calls": [["pon", ["2p", "2p", "2p"]]],
    "winning_tile": "3z",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": []
  },
  {
    "name": "sanankou after completing sequence",
    "hand": ["1m", "1m", "1m", "7s", "8s", "3z", "3z", "3z", "5z", "5z"],
    "calls": [["ankan", ["2p", "2p", "2p", "2p"]]],
    "winning_tile": "9s",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Tsumo", 1], ["Sanankou", 2]]
  },
  {
    "name": "haitei",
    "hand": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z"],
    "calls": [["chii", ["2s", "3s", "4s"]]],
    "conditions": ["no_draws_remaining"],
    "winning_tile": "3z",
    "win_source": "draw",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Haitei", 1]]
  },
  {
    "name": "houtei",
    "hand": ["4m", "4m", "4m", "6m", "7m", "8m", "1p", "1p", "3z", "3z"],
    "calls": [["chii", ["2s", "3s", "4s"]]],
    "conditions": ["no_draws_remaining"],
    "winning_tile": "3z",
    "win_source": "discard",
    "yaku_lists": ["yaku"],
    "expected_yaku": [["Houtei", 1]]
  },
  {
    "name": "daisangen tsuuiisou suuankou",
    "hand": ["5z", "5z", "5z", "6z", "6z", "6z", "2z", "2z", "3z", "3z"],
    "calls": [["ankan", ["7z", "7z", "7z", "7z"]]],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "2z",
    "win_source": "draw",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Daisangen", 1], ["Suuankou", 1], ["Tsuuiisou", 1]]
  },
  {
    "name": "suuankou with tenhou (upgrades into tanki)",
    "hand": ["5m", "5m", "5m", "7m", "7m", "7m", "2p", "2p", "7s", "7s"],
    "calls": [["ankan", ["1s", "1s", "1s", "1s"]]],
    "winning_tile": "2p",
    "win_source": "draw",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Tenhou", 1], ["Suuankou Tanki", 2]]
  },
  {
    "name": "suuankou with chiihou (no upgrade)",
    "hand": ["5m", "5m", "5m", "7m", "7m", "7m", "2p", "2p", "7s", "7s"],
    "calls": [["ankan", ["1s", "1s", "1s", "1s"]]],
    "conditions": ["make_discards_exist"],
    "winning_tile": "2p",
    "win_source": "draw",
    "seat": "south",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Chiihou", 1], ["Suuankou", 1]]
  },
  {
    "name": "typical open ryuuiisou",
    "hand": ["2s", "2s", "3s", "3s", "3s", "4s", "4s", "4s", "6z", "6z"],
    "calls": [["pon", ["6s", "6s", "6s"]]],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "2s",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Ryuuiisou", 1]]
  },
  {
    "name": "open chinroutou",
    "hand": ["1m", "1m", "1m", "1p", "1p", "1p", "9p", "9p", "9s", "9s"],
    "calls": [["pon", ["1s", "1s", "1s"]]],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "9s",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Chinroutou", 1]]
  },
  {
    "name": "open chuurenpoutou",
    "hand": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m"],
    "calls": [["pon", ["9m", "9m", "9m"]]],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "9m",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": []
  },
  {
    "name": "closed chuurenpoutou",
    "hand": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "6m",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Chuurenpoutou", 1]]
  },
  {
    "name": "junsei chuurenpoutou",
    "hand": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m", "9m", "9m"],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "5m",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Junsei Chuurenpoutou", 2]]
  },
  {
    "name": "chuurenpoutou with tenhou (upgrades into junsei)",
    "hand": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
    "winning_tile": "6m",
    "win_source": "draw",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Tenhou", 1], ["Junsei Chuurenpoutou", 2]]
  },
  {
    "name": "chuurenpoutou with chiihou (no upgrade)",
    "hand": ["1m", "1m", "1m", "2m", "3m", "4m", "5m", "7m", "7m", "8m", "9m", "9m", "9m"],
    "calls": [["ankan", ["1s", "1s", "1s", "1s"]]],
    "conditions": ["make_discards_exist"],
    "winning_tile": "6m",
    "win_source": "draw",
    "seat": "south",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Chiihou", 1], ["Chuurenpoutou", 1]]
  },
  {
    "name": "juusan kokushi",
    "hand": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "2z", "3z", "4z", "5z", "6z", "7z"],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "1z",
    "win_source": "draw",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Kokushi Musou Juusan Menmachi", 2]]
  },
  {
    "name": "kokushi with tenhou (upgrades into juusan)",
    "hand": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "5z", "6z", "7z"],
    "winning_tile": "2z",
    "win_source": "draw",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Tenhou", 1], ["Kokushi Musou Juusan Menmachi", 2]]
  },
  {
    "name": "kokushi with chiihou (no upgrade)",
    "hand": ["1m", "9m", "1p", "9p", "1s", "9s", "1z", "1z", "3z", "4z", "5z", "6z", "7z"],
    "calls": [["ankan", ["1s", "1s", "1s", "1s"]]],
    "conditions": ["make_discards_exist"],
    "winning_tile": "2z",
    "win_source": "draw",
    "seat": "south",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Chiihou", 1], ["Kokushi Musou", 1]]
  },
  {
    "name": "daisuushii suukantsu",
    "hand": ["1p"],
    "calls": [["ankan", ["1z", "1z", "1z", "1z"]], ["daiminkan", ["2z", "2z", "2z", "2z"]], ["daiminkan", ["3z", "3z", "3z", "3z"]], ["kakan", ["4z", "4z", "4z", "4z"]]],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "1p",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Daisuushii", 2], ["Suukantsu", 1]]
  },
  {
    "name": "shousuushii tsuuiisou",
    "hand": ["1z", "1z", "1z", "2z", "2z", "2z", "3z", "3z", "4z", "4z", "4z", "5z", "5z"],
    "status": [],
    "conditions": ["make_discards_exist"],
    "winning_tile": "5z",
    "win_source": "discard",
    "yaku_lists": ["yakuman"],
    "expected_yaku": [["Tsuuiisou", 1], ["Shousuushii", 1]]
  }
]
