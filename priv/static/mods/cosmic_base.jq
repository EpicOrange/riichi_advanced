# add cosmic mods in front
.available_mods = [
  "Cosmic",
  {"id": "cosmic", "deps": ["space", "kontsu", "cosmic_calls"], "name": "Cosmic", "desc": "Base mod for Cosmic Riichi. Adds most relevant yaku and sets up the score table for things like haneyakuman."},
  {"id": "kontsu", order: 2, "name": "Kontsu", "desc": "Add mixed triplets, or kontsu. If you have the same number in three suits, that counts as one of your sets towards four sets and a pair. For example, 1m1s1p is a kontsu. Also considered kontsu: 3 different winds, or one of each dragon."},
  {"id": "cosmic_calls", order: 2, "deps": ["kontsu"], "name": "Cosmic Calls", "desc": "Add the following calls: Ton (calls a pair), Chon (calls kontsu), and Fuun (calls a set of 4 different winds). The precedence is Ton < Chii < Chon < Fuun < Pon < Kan."},
  {"id": "yaku/kontsu_yaku", "deps": ["kontsu"], "name": "Kontsu Yaku", "desc": "A wind kontsu counts as 0.5 han if it contains both the round wind and seat wind. A dragon kontsu is always 0.5 han, and is called mini-sangen. Having two of the same kontsu in a closed hand is 1 han (ryandoukon), having three is 2 han open 3 han closed (sandoukon), and having four is yakuman (yondoukon)."},
  {"id": "yaku/chanfuun", "deps": ["kontsu", "cosmic_calls"], "name": "Chanfuun", "desc": "1 han for winning off the tile that upgrades a wind kontsu to a fuun."},
  {"id": "yaku/fuunburi", "deps": ["kontsu", "cosmic_calls"], "name": "Fuunburi", "desc": "1 han if you win off the tile discarded by a player who just called fuun."},
  {"id": "yaku/uumensai_cosmic", "deps": ["kontsu"], "name": "Uumensai (cosmic)", "desc": "2 han if each of your four sets is of a different kind: sequence, triplet, mixed triplet (kontsu), kan, mixed quad (fuun)."},
  {"id": "yaku/sanankon", "deps": ["kontsu"], "name": "Sanankon", "desc": "Local yaku. 1 han for having three concealed kontsu. 3 han for having four, and 6 han for having four waiting on your pair."},
  {"id": "yakuman_13_han", "order": 100, "name": "Yakuman 13 Han", "desc": "This is a utility mod for Cosmic Riichi that changes all yakuman to be 13 han. You may disable it if you don't want yakuman to stack with normal yaku."}
] + .available_mods
|
.win_timer = 20
