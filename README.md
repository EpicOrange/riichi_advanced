# Riichi Advanced

![](priv/static/images/title.png)

- Play now: <https://riichiadvanced.com/>
- Discord: <https://discord.gg/5QQHmZQavP>

Infinitely extensible mahjong web client featuring the following:

- Many base rulesets, including Riichi, Hong Kong Old Style, Sichuan Bloody, and Bloody 30-Faan Jokers. You can even play Riichi Mahjong with Saki powers!
- Support for 3-player modes like Sanma, and 2-player modes like Minefield!
- A variety of mods for each ruleset! Play with head bump, sequences wrapping from 9 to 1, a "ten" tile for each suit, and more!
- Multiplayer lobby system with public/private rooms! Invite your friends, or play against AI!
- Infinitely customizable ruleset! Change the rules by copying an existing ruleset, and play your modified ruleset directly in the client!

Join the [Discord](https://discord.gg/5QQHmZQavP) for development updates and bug reporting! (There are a lot of funny bugs, don't miss out!)

If interested in contributing, check out the [contributing doc](CONTRIBUTING.md)!

## Table of contents

- [Changelog](#changelog)
- [Supported rulesets](#supported-rulesets)
- [Custom rulesets](#custom-rulesets)
- [How can I contribute?](#how-can-i-contribute)
- [Developer information](#developer-information)
- [Running the server locally](#running-the-server-locally)
- [Acknowledgments](#acknowledgments)

## Changelog

- __17 Feb 2025__: v1.1.1:
  + Added tutorial for cosmic riichi and galaxy mahjong
  + Added rules and strategy document for MCR
  + Added shiny dora mod
  + Added ability to hover over a winning hand to break it into sets
  + Added lots of tests
  + Added like a million jokers (with corresponding Riichi mods)
  + Added custom aka
  + Added four local yaku: ketsupaihou, chinchii toushii, rentsuu honitsu, and dorahairi chinroutou chiitoitsu
  + Added the ability to have attributes be transparent to the tile checker by prefixing with `_` 
  + Added play button to tutorial menu
  + Fixed dora/aka/ura awarding
  + Fixed any-tile jokers in hand turning every tile in hand into an any-tile joker
  + Fixed chankan and anfuun for cosmic mahjong
  + Fixed cosmic mod support with kan mod
  + Fixed animation for calls (specifically added kan and added-added kan in cosmic)
  + Fixed `"set_tile_ordering_all"` only setting the current player's tile ordering
  + Fixed `"set_tile_ordering_all"` also removing all tile aliases
  + Fixed `"has_hell_wait"` condition never being true
  + Fixed 0.5-han yaku not letting you ron even if they combine to 1+ han
  + Fixed fu calculation for added pon and added-added-kan in cosmic
  + Fixed weird navigation where you go home -> room -> lobby -> home (now it's home -> room -> home)
  + Fixed agariyame and tenpaiyame ending the game prematurely
  + Fixed bamboo tiles being hard to read (hopefully)
  + Fixed AI thinking they're tenpai when they're very much not
  + Fixed cache stuff (things run faster now, especially AI)
  + Fixed rigging the wall using `"starting_hands"` leading to incorrect distribution of tiles in the wall
  + Fixed layout errors when using Safari
- __12 Feb 2025__: v1.1.0:
  + Added [CONTRIBUTING.md](CONTRIBUTING.md)
  + Added tutorial screen as well as a way to create and share custom tutorials! If you are interested in creating a tutorial just select any ruleset in the main menu and hit Learn -> Create your own tutorial! [Here is the tutorial JSON documentation.](documentation/tutorials.md)
  + Added some rules documentation for Vietnamese mahjong
  + Added documentation for all available tiles
  + Added a lot of test machinery (we can actually simulate test games now)
  + Added Shiny Dora mod
  + Added It's All Aka? mod
  + Added Riichi mod (extracted from Riichi ruleset)
  + Added Kan mod (extracted from Riichi ruleset)
  + Added aka versions of every standard tile + blue and gold fives
  + Added like two dozen new jokers + some riichi mods that add them to the game
  + Added galaxy shuugi (+1 shuugi when galaxy tile is used as their original value) for galaxy mahjong
  + Added AI names
  + Added Heavenly Hand to American mahjong (thanks Sophie)
  + Added MahjLife card to American mahjong (thanks Sophie)
  + Added seven strategies for awarding points when tsumo loss is off
  + Added support for `"points2"` multiplier for `"multiplier"` scoring method
  + Added `"tag_tiles"` and `"tag_dora"` actions
  + Added `"add_attr_tagged"` action
  + Added a new `"name"` argument to `"ryuukyoku"` action
  + Renamed `"save_tile_aliases"`/`"load_tile_aliases"` to `"save_tile_behavior"`/`"load_tile_behavior"`
  + Fixed flower yaku emitting errors in MCR
  + Fixed fully concealed calls from being "visible" to the tile counter
  + Fixed fully concealed calls from printing its contents to the message log
  + Fixed sanma going into West round when it shouldn't
  + Fixed some log crashes (log replays are still very unstable)
  + Fixed lots of miscellaneous crashes
  + Fixed kazoe yakuman mod upgrading everyone's limit hand by one tier
  + Fixed flower not being callable in american mahjong
  + Fixed dead hand marker in american mahjong
  + Fixed chiitoitsu not working if you have jokers in hand
  + Fixed golden chun mod compatibility with other mods
  + Fixed incorrect fu calculation for shanpon and kontsu waits
  + Some optimizations
- __4 Feb 2025__: v1.0.2:
  + Added ability to view running public games in lobby screen
  + Added auto-pei autobutton to Sanma
  + Added Kansai Sanma ruleset
  + Added Milky Way yakuman to Galaxy Mahjong (thanks Sophie)
  + Added more details about `match` and `mark` in documentation
  + Changed SBR to penalize having a voided suit rather than disallow having a voided suit (thanks Sophie)
  + Fixed revealing seven dora/ura instead of five in sanma
  + Fixed ten tiles not being able to form kontsu (thanks jake but lowercase)
  + Fixed seats not being reserved for disconnected players
- __3 Feb 2025__: v1.0.1:
  + Added ability to join running games (though you still cannot view running games)
  + Added documentation for SBR and Galaxy Mahjong (thanks Sophie)
  + Added kansai chiitoitsu mod
  + Added no tsumo loss mod
  + Added `"save_tile_aliases"` and `"load_tile_aliases"` actions
  + Added session tracking to mitigate disconnection issues (needs testing)
  + Fixed "unique" specifier for match definition
  + Fixed chanta not accepting honor sequences in space mahjong
  + Fixed crash in Singaporean when checking for multisided wait
  + Fixed crash when call buttons contain malformed actions
  + Fixed crash when checking if ankan changes your waits while in riichi.
  + Fixed crash when navigating between pages
  + Fixed flowers being treated as calls
  + Fixed nagashi being achievable by a dead hand (Chombo mod)
  + Fixed replacement tiles not being drawn from dead wall visually
- __1 Feb 2025__: v1.0.0: 17 rulesets, hundreds of mods, multiplayer, it's all there.

## Supported rulesets

- [__Riichi__](documentation/riichi.md): The classic riichi ruleset, now with an assortment of mods to pick and choose at your liking.
- [__Sanma__](documentation/sanma.md): Three-player Riichi.
- __Space Mahjong__: Riichi, but sequences can wrap (891, 912), and you can make sequences from winds and dragons. In addition, you can chii from any direction, and form open kokushi (3 han).
- __Cosmic Riichi__: A Space Mahjong variant with mixed triplets, more yaku, and more calls.
- [__Galaxy Mahjong__](documentation/galaxy.md): Riichi, but one of each tile is replaced with a blue galaxy tile that acts as a wildcard of its number. Galaxy winds are wind wildcards, and galaxy dragons are dragon wildcards.
- [__Kansai Sanma__](documentation/kansai.md): Sanma, but you draw until the last visible dora indicator. In addition, all fives are akadora, fu is fixed at 30, there is no tsumo loss, and scores are rounded to the nearest 1000. Flowers act as nukidora in place of north winds, which are now yakuhai. Exhaustive draws in south round always result in a repeat regardless of who's tenpai.
- [__Chinitsu__](documentation/chinitsu_challenge.md): Two-player variant where the only tiles are bamboo tiles. Try not to chombo!
- __Minefield__: Two-player variant where you start with 34 tiles to make a mangan+ hand, and your remaining tiles are your discards.
- __Sakicards v1.3__: Riichi, but everyone gets a different Saki power, which changes the game quite a bit. Some give you bonus han every time you use your power. Some let you recover dead discards. Some let you swap tiles around the entire board, including the dora indicator.
- [__Hong Kong__](documentation/hk.md): Hong Kong Old Style mahjong. Three point minimum, everyone pays for a win, and win instantly if you have seven flowers.
- [__Sichuan Bloody__](documentation/sichuan.md): Sichuan Bloody mahjong. Trade tiles, void a suit, and play until three players win (bloody end rules).
- [__MCR__](documentation/mcr.md): Mahjong Competition Rules. Has a scoring system of a different kind of complexity than Riichi.
- __Taiwanese__: 16-tile mahjong with riichi mechanics.
- [__Bloody 30-Faan Jokers__](documentation/bloody30faan.md): Bloody end rules mahjong, with Vietnamese jokers, and somehow more yaku than MCR.
- [__American (2024 NMJL)__](documentation/american.md): American mahjong. Assemble hands with jokers, and declare other players' hands dead.
- [__Vietnamese__](documentation/vietnamese.md): Mahjong with eight differently powerful joker tiles.
- __Malaysian__: Three-player mahjong with 16 flowers, a unique joker tile, and instant payouts.
- __Singaporean__: Mahjong with various instant payouts and various unique ways to get penalized by pao.
- __Custom__: Create and play your own custom ruleset.

Each ruleset has optional mods like chombo and aotenjo, you'll have to check out each one to discover its variants!

## Custom rulesets

Once you enter the lobby or room for a ruleset you can scroll down to view the JSON object defining the ruleset.

If you're looking to make a custom ruleset using the game's JSON-based ruleset format, that documentation is available [here](documentation/documentation.md). To play a custom ruleset, simply select Custom on the main page, click Room Settings, and paste and edit your ruleset in the box provided.

## How can I contribute?

Mostly we need people to play and [report bugs](https://github.com/EpicOrange/riichi_advanced/issues), of which there are likely many. We also accept pull requests so if you see an [issue](https://github.com/EpicOrange/riichi_advanced/issues) you'd like to tackle, feel free to do so!

Also if you know of any English-based mahjong rulesets available online, do tell us in Discord and we'll add it to the list!

Monetary contributions are not accepted at this time.

## Developer information

This project is written in Elixir with the Phoenix framework, making heavy use of the LiveView library. Like all Phoenix projects, it has two moving parts:

- `lib/riichi_advanced`: Model
- `lib/riichi_advanced_web`: Combined View/Controller

Here is a breakdown of all the directories:

    ├── assets (node modules, js, css)
    ├── config (elixir project config)
    ├── documentation (all documentation linked in-game is here)
    ├── lib
    │   ├── delta (operational transform library)
    │   ├── ex_jq (jq binding library)
    │   ├── ex_smt (z3 binding library)
    │   ├── riichi_advanced (all application logic)
    │   │   ├── game (everything related to the game screen)
    │   │   ├── lobby (everything related to the lobby screen)
    │   │   ├── log (everything related to the log viewing screen)
    │   │   ├── messages (everything related to the messages panel)
    │   │   ├── room (everything related to the room screen)
    │   │   ├── application.ex (main thing! OTP root application/supervisor)
    │   │   ├── cache.ex (general-purpose ETS cache)
    │   │   ├── exit_monitor.ex (general-purpose disconnection monitor process)
    │   │   ├── mailer.ex (unused)
    │   │   ├── repo.ex (unused)
    │   │   └── session_supervisor.ex (DynamicSupervisor instance)
    │   └── riichi_advanced_web
    │       ├── components (stock Phoenix except for components/layouts/root.html.heex)
    │       ├── controllers (stock Phoenix)
    │       ├── views (all LiveViews and live components)
    │       ├── endpoint.ex (main thing! serves all the other files as plugs)
    │       ├── gettext.ex (unused)
    │       ├── router.ex (LiveView routes)
    │       └── telemetry.ex (unused)
    ├── priv
    │   ├── gettext (unused)
    │   ├── repo (unused)
    │   └── static
    │       ├── audio (all audio)
    │       ├── images (all spritesheets and svgs)
    │       ├── logs (save location for all logs)
    │       ├── mods (all mods)
    │       ├── rulesets (all rulesets)
    │       ├── favicon.ico
    │       └── robots.txt
    └── test (all tests)

## Running the server locally

First, install Elixir (≥ 1.14), `npm`, `z3`, and `jq`.

Then run:

    git clone "https://github.com/EpicOrange/riichi_advanced.git"
    cd riichi_advanced

    # Get Elixir dependencies
    mix deps.get

    # Generate self-signed certs for local https
    mix phx.gen.cert

    # Get Node dependencies
    (cd assets; npm i)

    # Start the server
    HTTPS_PORT=4000 iex -S mix phx.server

This should start the server up at `https://localhost:4000`. (Make sure to use `https`! `http` doesn't work locally for some reason.) Phoenix should live-reload all your changes to Elixir/JS/CSS files while the server is running.

## Acknowledgments

The basic [tileset](documentation/tiles.md) used in this game is taken [from this repository](https://github.com/FluffyStuff/riichi-mahjong-tiles). Thank you to @FluffyStuff!

In addition, special thanks to the following sites for offering English-based rulesets:

- [Mahjong Pros](https://mahjongpros.com/)
- [Sloperama](https://www.sloperama.com/mahjongg/index.html)
- [Mahjong Picture Guide](www.mahjongpictureguide.com)

A big thank you to our beta testers on Discord:

- #yuriaddict
- 5𝔷ł𝔬𝔱𝔶𝔠𝔥-𝔨𝔲𝔫
- Anton00
- averyoriginalname
- BluePotion
- Buckwheat
- Caballo
- DragonRider JC
- GameRaccoon
- Glassy
- GOAT^
- Hyperistic
- JustKidding
- KlorofinMaster
- L_
- lorena.davletiar
- Miisuya
- Nehalem
- nilay
- schi
- Sophie
- stuf
- tomato
- UltimateNeutrino
- モカ妹紅（MochaMoko）
