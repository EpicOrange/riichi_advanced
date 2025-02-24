.after_initialization.actions += [["add_rule", "Local Yaku (Yakuman)", "(Ishino Uenimo Sannen) \"Three Years on a Rock\". Win with double riichi and haitei/houtei.", 113]]
|
.yakuman += [
  {
    "display_name": "Ishino Uenimo Sannen",
    "value": 1,
    "when": [{"name": "status", "opts": ["double_riichi"]}, "no_tiles_remaining"]
  }
]
