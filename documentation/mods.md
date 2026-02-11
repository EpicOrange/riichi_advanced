# Mods

## Overview

Mods in Riichi Advanced are basically snippets of functionality that can be enabled, configured, etc. At time of writing we have like 341 mods across all variants. It would be really elegant if all rulesets were simply an empty ruleset but with a specific set of mods, but we're not really there yet.

This document is all about writing mods. Mods can technically be written in the Riichi Advanced client itself via the Config tab using [MahjongScript](./mahjongscript.md), a language specifically made for defining mahjong behavior.

If you're thinking of submitting a pull request in order to add your mod idea, or to make mods work in a new ruleset, then this is for you.

## How to specify available mods in a ruleset

Every mahjong variant with mods has two keys, `available_mods` and `default_mods`. Let's talk about the first one.

In the Riichi ruleset, `available_mods` looks like (MahjongScript):

    define_mod_category "Rules"
    define_mod honba, name: "Honba", order: -1, desc: "Enables honba."
    config_mod honba, name: "value", values: [100, 500, 1000]
    define_mod nagashi, name: "Nagashi", order: -1, desc: "Enable nagashi mangan. When you discards are all terminals and honors at exhaustive draw, and none of your discards have been called, then you are paid mangan tsumo at draw."
    config_mod nagashi, name: "is", values: ["Mangan", "Yakuman"]
    define_mod tobi, name: "Tobi", order: -1, desc: "Enable busting. Once anyone's points is reduced below zero, the game ends."
    config_mod tobi, name: "below", values: [0, 1, 1000, 1001]
    define_mod uma, name: "Uma", desc: "Enable uma. At the end of the game, points are awarded or deducted based on placement."
    config_mod uma, name: "_1st", values: [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], default: 10
    config_mod uma, name: "_2nd", values: [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], default: 5
    config_mod uma, name: "_3rd", values: [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], default: -5
    config_mod uma, name: "_4th", values: [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], default: -10
    ...

This is all to make it so that the mentioned mods appear in the 'Mods' tab in the 'Room settings' menu of Riichi Advanced. The mods themselves all live somewhere in `priv/static/mods`, whose filenames match the given identifier (e.g. `honba.majs`).

There are three majs commands above:

- `define_mod_category`: This just puts a text header in the 'Mods' tab, with a Toggle All button. Categories don't have any effect otherwise, it's purely visual.
- `define_mod`: This lists the given mod, and you can specify how it should look:
  + Example:
    ```
    define_mod shiro_pocchi, order: 2, deps: ["yaku/riichi"], conflicts: ["no_honors", "chinitsu"], name: "Shiro Pocchi", desc: "One of the white dragons is shiro pocchi. Shiro pocchi acts a joker tile when drawn while in riichi."
    ```
  + `name`: The display name of the mod. It will look for the corresponding mod in `priv/static/mods`, so if you want a subdirectory you would do something like `name: "yaku/daisharin"`
  + `desc`: A description to display when a mod is hovered (or pressed, if you're on mobile)
  + `order`: `order` is rather important, it is the mod loading order. By default, all mods are evaluated in the order they are defined. By specifying `order` (default 0) you can make certain mods load before and after each other. For example, all `order: -1` mods are loaded, then all `order: 0` (default) mods are loaded, then `order: `. Mods of the same `order` are evaluated in the order they are defined. There isn't many restrictions on what number `order` can be, but I keep it as integers since it looks nice.
  + `deps`: List of mod identifiers that should automatically enable when this mod is enabled.
  + `conflicts`: List of mod identifiers that should automatically disable when this mod is enabled.
- `config_mod`: This adds user-facing option dropdowns to the provided mod.
  + Example:
    ```
    config_mod uma, name: "_1st", values: [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30], default: 10
    ```
  + `name`: The display name of the option, also internally used as an identifier. If you want to have it start with a number, like `1st`, write `_1st` instead, and it will display like `1st` (this behavior may change)
  + `values`: The available values for a dropdown.
  + `default`: The default selected value for the dropdown.

There is also a fourth command, `define_preset`, which appears as a button in the Presets screen. When pressed, it sets your mods to be whatever you supplied in `define_preset`. See [`priv/static/rulesets/riichi.majs`](https://github.com/EpicOrange/riichi_advanced/blob/355cd2463280f0440be157fb397d2a6c6733f5f9/priv/static/rulesets/riichi.majs#L789) to see how this works.

# How mods work internally

All mods are actually `.jq` or `.majs` (which compiles to a safe subset of jq).

A ruleset `.json` then applies every mod in succession to create the modded ruleset.

(The base ruleset `.json` is shown below the game in the Room screen of Riichi Advanced.)

## Some variants are just modpacks

A modpack is just a pre-modded ruleset, and are defined in `lib/riichi_advanced/constants.ex`. The only confusing key in there is `globals`, which are global variables for mods to reference. (For example, some mods want to display "Han", but maybe we want to have the same mod except it displays "Fan". Instead of making two mods, the mod is implemented to use the `$han` global variable, which is supplied in `globals`.

User config (the aforementioned dropdowns) work the same way, they simply define variables for the mod.
