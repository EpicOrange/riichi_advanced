# Riichi Advanced

![](priv/static/images/title.png)

- Play now: <https://riichiadvanced.com/>
- Discord: <https://discord.gg/5QQHmZQavP>

Infinitely extensible mahjong web client featuring the following:

- 24+ base rulesets, including:
  + Riichi,
  + Hong Kong Old Style,
  + Sichuan Bloody,
  + Space Mahjong,
  + Kansai Sanma,
  + MCR,
  + Bloody 30-Faan Jokers,
  + you can even play Riichi Mahjong with Saki powers!
- A variety of mods for each ruleset! Play with:
  + head bump,
  + sequences wrapping from 9 to 1,
  + a "ten" tile for each suit
  + every local yaku in existence
  + transparent Washizu tiles
  + every tile is aka dora
  + and more! (there are currently about 200 mods!)
- Support for 3-player modes like Sanma, and 2-player modes like Minefield!
- Multiplayer lobby system with public/private rooms! Invite your friends, or play against AI!
- Infinitely customizable ruleset! Beyond mods, you can change the rules by writing [MahjongScript](documentation/mahjongscript.md) to make minute changes to a game!
- Localization support! 中文支持！ 日本語対応！

Join the [Discord](https://discord.gg/5QQHmZQavP) for development updates and bug reporting! (There are a lot of funny bugs, don't miss out!)

If interested in contributing, check out the [contributing doc](CONTRIBUTING.md)!

## Table of contents

- [Changelog](#changelog)
- [Supported rulesets](#supported-rulesets)
- [Custom rulesets](#custom-rulesets)
- [How can I contribute?](#how-can-i-contribute)
- [Repository breakdown](#repository-breakdown)
- [Running the server locally](#running-the-server-locally)
- [Acknowledgments](#acknowledgments)

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

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
- [__American (NMJL)__](documentation/american.md): American Mah-Jongg. Assemble hands with jokers, and declare other players' hands dead.
- [__Vietnamese__](documentation/vietnamese.md): Mahjong with eight differently powerful joker tiles.
- __Malaysian__: Three-player mahjong with 16 flowers, a unique joker tile, and instant payouts.
- __Singaporean__: Mahjong with various instant payouts and various unique ways to get penalized by pao.
- __Custom__: Create and play your own custom ruleset.

Each ruleset has optional mods like chombo and aotenjo, you'll have to check out each one to discover its variants!

## Custom rulesets

Once you enter the lobby or room for a ruleset you can scroll down to view the JSON object defining the ruleset.

If you're looking to make a custom ruleset using the game's MahjongScript ruleset language, that documentation is available [here](documentation/documentation.md). To play a custom ruleset, simply select Custom on the main page, click Room Settings, and paste and edit your ruleset in the box provided.

Otherwise, click Room Settings and the Config tab to reveal an [MahjongScript](documentation/mahjongscript.md) editor, where any MahjongScript you write will be applied to the game.

## How can I contribute?

Mostly we need people to play and [report bugs](https://github.com/EpicOrange/riichi_advanced/issues), of which there are likely many. We also accept pull requests so if you see an [issue](https://github.com/EpicOrange/riichi_advanced/issues) you'd like to tackle, feel free to do so!

Also if you know of any English-based mahjong rulesets available online, do tell us in Discord and we'll add it to the list!

Monetary contributions are not accepted at this time.

## Repository breakdown

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
    │   │   ├── majs (everything related to the MahjongScript interpreter)
    │   │   ├── messages (everything related to the messages panel)
    │   │   ├── room (everything related to the room screen)
    │   │   ├── admin.ex (server administration functions meant to be used in the REPL)
    │   │   ├── application.ex (main thing! OTP root application/supervisor)
    │   │   ├── cache.ex (Nebulex cache for function caching)
    │   │   ├── ets_cache.ex (general-purpose ETS cache)
    │   │   ├── exit_monitor.ex (general-purpose disconnection monitor process)
    │   │   ├── mailer.ex (unused)
    │   │   ├── repo.ex (unused)
    │   │   └── session_supervisor.ex (DynamicSupervisor instance)
    │   └── riichi_advanced_web
    │       ├── components (stock Phoenix except for components/layouts/root.html.heex)
    │       ├── controllers (stock Phoenix)
    │       ├── views (all LiveViews and live components)
    │       ├── endpoint.ex (main thing! serves all the other files as plugs)
    │       ├── gettext.ex (stock Phoenix)
    │       ├── gettext_hints.ex (explicitly sets some strings to be used in gettext translations)
    │       ├── router.ex (LiveView routes)
    │       ├── telemetry.ex (unused)
    │       └── translations.ex (helper functions to mark strings for gettext translations)
    ├── priv
    │   ├── cert (this is generated when you run `mix phx.gen.cert`)
    │   ├── gettext (stores all gettext translation .po files)
    │   ├── repo (unused)
    │   └── static
    │       ├── audio (all audio)
    │       ├── images (all spritesheets and svgs)
    │       ├── logs (save location for all logs)
    │       ├── mods (all mods)
    │       ├── rulesets (all rulesets)
    │       ├── oldl_rulesets (stores the original .json versions of rulesets rewritten in .majs)
    │       ├── favicon.ico
    │       └── robots.txt
    └── test
        ├── riichi_advanced
        │   ├── parsing (tests related to reading files)
        │   ├── yaku_test (all yaku tests)
        │   └── a bunch of other tests that end with _test.exs
        ├── support
        │   └── test_utils.exs (util functions called by tests)
        └── test_helper.exs (boilerplate)

## Running the server locally (MacOS, Linux)

First, install Elixir (≥ 1.14), `npm`, `z3`, and `jq`.

Then run:

    git clone "https://github.com/EpicOrange/riichi_advanced.git"
    cd riichi_advanced

    # Get Elixir dependencies
    mix deps.get

    # Generate self-signed certs for local https
    mix phx.gen.cert

    # Get Node dependencies (there aren't many)
    (cd assets; npm i)

    # Start the server
    HTTPS_PORT=4000 iex -S mix phx.server

This should start the server up at `https://localhost:4000`. (Make sure to use `https`! `http` doesn't work locally for some reason.) Phoenix should live-reload all your changes to Elixir/JS/CSS files while the server is running.

If it complains about a daemon not running, open a separate terminal and run `epmd` (Erlang Port Mapper Daemon), and try again.

## Running the server locally

If you want to run your own instance of Riichi Advanced, see [INSTALL.md](/INSTALL.md) for instructions and troubleshooting.

## Acknowledgments

The basic [tileset](documentation/tiles.md) used in this game is taken [from this repository](https://github.com/FluffyStuff/riichi-mahjong-tiles). Thank you to @FluffyStuff!

Many of the more unique tiles in the game (read: joker tiles) were created using the [Hanyi Senty Tang](https://sentyfont.com/sentytang.htm) font.

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
