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
- [Developer information](#developer-information)
- [Running the server locally (MacOS, Linux)](#running-the-server-locally-macos-linux)
- [Running the server locally (Windows 11)](#running-the-server-locally-windows-11)
- [Running with Docker](#running-with-docker)
- [Acknowledgments](#acknowledgments)

## Changelog

- __10 Feb 2026__: v1.3.3:
  + Added a 白 variant of the white dragon, used in Galaxy Mahjong (thanks Sophie)
  + Added an 'abort pass' button to American Mahjong (thanks Sophie)
  + Added an experimental .majs to .json translator at /majstest
  + Added documentation for how mods work: `documentation/mods.md`
  + Added instructions for running Riichi Advanced on Windows (thanks Sophie)
  + Added methods for running Riichi Advanced as a Nix flake on Docker (thanks Will)
  + Added numerous Cards for American Mah-jongg (thanks Sophie)
  + Fixed 20 copies of the same message playing when calculating scores in Malaysian
  + Fixed a crash bug involving the joker solver
  + Fixed all sequences yaku not being awarded sometimes (thanks Sophie)
  + Fixed auto-discard button not working in Riichi (thanks Sophie)
  + Fixed auto-flower button not working in Kansai (thanks Sophie)
  + Fixed flowers not being scored correctly in MCR (thanks Sophie)
  + Fixed fly jokers not being replaceable in Malaysian (thanks Sophie)
  + Fixed many American tests (thanks Sophie)
  + Fixed many bugs with winning hands in American (thanks Sophie)
  + Fixed many chinese localizations (thanks Sophie)
  + Fixed rules text for Sanshoku Doujun showing a Doukou hand as an example
  + Fixed some documentation errors about `any_discard`
  + Fixed some sources of HKOS/Classical crashes (thanks Sophie)
  + Fixed the white text on white (thanks Sophie)
  + Fixed tile sides visually flickering in some browsers (thanks Will)
  + Fixed documentation for tile sprites (thanks Sophie)
- __8 Apr 2025__: v1.3.2:
  + Added `~t`, and `~T` sigils in MahjongScript for specifying lists of tiles
  + Added 5th tile tenpai mod to riichi
  + Added 12 tile pao mod to HKOS
  + Added aka 1,3,7,9 mods (thanks jake)
  + Added animated rainbow tiles
  + Added as-conditions to MahjongScript
  + Added `replace n` command to MahjongScript
  + Added better graphics for mobile zoom
  + Added Card-Free, NMJL 2025, and PIE rules to american mahjong (thanks Sophie)
  + Added dora shine animation
  + Added `make_responsible_for` action for deciding pao
  + Added MahjongScript tutorial to `documentation/`
  + Added WIP localization support for Chinese and Japanese
  + Added unsuited numbers and dragons to american match grammar
  + Added randomize mods button
  + Added `set_scoring_header` action
  + Added some symmetry/combinatorics nonsense to joker solver making it 2x faster
  + Added test coverage for sichuan bloody
  + Changed fu calculations to be based on tile attributes rather than hardcoded tile identities
  + Changed nagashi and tenpai payments to be action-based rather than hardcoded
  + Fixed AI crashing randomly due to slow server response
  + Fixed log viewer somewhat
  + Fixed minefield not really working
  + Fixed sichuan bloody not really following the ruleset
  + Fixed some joker bugs related to having tile attributes on both the joker and the target tile
  + Fixed some UI issues, especially in Safari
- __20 Mar 2025__: v1.3.1:
  + Added ability to unselect marked tiles in hand
  + Added `counter_more_than`, `counter_less_than` conditions
  + Added `dragon` and `wind` and `not_*` tile specs
  + Added mobile tooltips
  + Added `not` for conditions in mahjongscript
  + Added or-patterns to American match specifications
  + Added or-patterns to set definitions
  + Added "responsibility" logic to Zung Jung
  + Added reset honba on exhaustive draw mod to Fuzhou
  + Added test coverage for space mahjong, cosmic riichi, galaxy mahjong, and zan sanma -- we're at 419 tests now
  + Added top-level JSON constants that get substituted on load
  + Added Zan Sanma preset for kansai sanma
  + Fixed AI going too fast and discarding invalid tiles when cancellable riichi mod is on
  + Fixed button clicks not registering if you click the top of a button
  + Fixed Concealed Hand being scored for Seven Pairs and Thirteen Terminals hands in Zung Jung
  + Fixed cosmic riichi awarding both kontsu and triplet yaku for the same hand
  + Fixed facedown tiles identity being visible if you just look at the HTML
  + Fixed head bump actually being a race of who clicks the ron button first
  + Fixed joker solver not being able to solve for tiles with attributes
  + Fixed robbing the gold not working for nondealers in Fuzhou mahjong
  + Fixed some more crashes
  + Fixed transparent Washizu tiles not being replaced with aka/ao/kindora
  + Fixed variables not being substituted in certain locations in functions
- __14 Mar 2025__: v1.3.0:
  + Added `dismantle_calls` match spec keyword that will only remove the matching part from a call
  + Added `modify_winner` and `modify_payout` actions for custom scoring
  + Added `payout` amount and `winners` seat spec
  + Added a "tile on top of wall" visual for Fuzhou
  + Added a couple mods for Fuzhou (mostly replacing flowers revealed as gold vs allowing flowers to be used as gold)
  + Added ability to roll multiple dice
  + Added ability to use MahjongScript (.majs) in place of JSON for both rulesets and config (i.e. custom mods)
  + Added tab system for rules text
  + Added test coverage for Hefei, Fuzhou, Ningbo, Tianjin, and Zung Jung -- we're at 318 tests now
  + Added Zung Jung ruleset and mods (thanks Sophie!)
  + Changed main documentation to be for MahjongScript instead of JSON (JSON docs are still available)
  + Changed win screen to display multiple flowers more compactly
  + Fixed `before_call`, `after_call`, `*_discarded`, `seat_is`, and some tile attrs
  + Fixed auto discard autobutton skipping tsumo and ankan in all variants
  + Fixed chanta/junchan never recognizing 11123 as 11 123
  + Fixed Cosmic Riichi crashes
  + Fixed declaring a flower allowing you to draw a replacement tile from an exhausted wall
  + Fixed double clicking on tiles discarding your draw instead
  + Fixed drawing from the dead wall removing the bottom tile before the tile above it
  + Fixed index numbers revealing what number tile a hidden tile is
  + Fixed joker flowers being able to form triplets/quads in Fuzhou
  + Fixed riichi sticks being put on the wrong player
  + Fixed skip calls button skipping chankan in all variants
  + Fixed the 1223 wait on 2 counting as both a single wait and a closed wait in Ningbo
  + Fixed Tianjin Baida Reuse not counting as part of the minimum score of 4
  + Fixed Tianjin multipliers not counting as part of the minimum score of 4
  + Fixed winning hand arrangement function taking forever to run
- __1 Mar 2025__: v1.2.0:
  + Added ability for mods to add rules text
  + Added ability to configure fu calculations
  + Added ability to configure individual mods with parameters (aka, riichi, tobi, etc)
  + Added cancellable riichi mod
  + Added Chinese Classical ruleset
  + Added custom styles (custom tile numbering, tile back color, and tablecloth color)
  + Added displaying numbers on the corner of tiles (off by default)
  + Added full documentation for match keywords, match targets, interrupt levels, and scoring
  + Added Fuzhou, Tianjin, Ningbo, Hefei rulesets (thanks Sophie)
  + Added more tile colors (lightblue, brown, pink, rainbow)
  + Added preset mod packs for Riichi
  + Added string interpolation for `push_message` and `big_text` actions
  + Added uma mod
  + Added various tests
  + Added zombie blanks mod to american mahjong (thanks Sophie)
  + Changed discards to be double click, not single click
  + Changed riichi to automatically enable auto-discard
  + Fixed AI dealing into open riichi
  + Fixed allowing calls that softlock you due to kuikae
  + Fixed american mahjong buttons
  + Fixed ao and kin not counting
  + Fixed chankan in sanma
  + Fixed dead hand check for american (again)
  + Fixed ippatsu not working (again)
  + Fixed kansai sanma having 4x dora
  + Fixed minefield dora and other bugs
  + Fixed safari viewport issues
  + Fixed seat shuffling not working
  + Fixed several crashes
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

> **Tip:** For a more contained setup, see [Running with Docker](#running-with-docker).

First, install Erlang (≥ 27), Elixir (≥ 1.18), Node.js, `z3`, and `jq`.

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

## Running the server locally (Windows 11)

> **Tip:** For a more contained setup, see [Running with Docker](#running-with-docker).

Steps are mostly identical to the above. However, you will run into trouble as follows:

* Windows does not like to install `npm`. It is recommended to install all necessary packages by first installing [Chocolatey](https://chocolatey.org/install) (which has the option to install `npm` for you immediately after). Be sure to restart your computer.

* Node dependencies are acquired with these three commands instead:

      cd assets
      npm i
      cd ..

* The following files should be manually patched: 
  * In `\lib\ex_jq\jq.ex`, lines 19 to 35 (`# postprocess the result ... raise(UnknownException, error) ↵ end`) should be replaced with `result`.
  * Near the end of `\lib\riichi_advanced\game\mod_loader.ex`, the regex `Regex.replace(~r{^//.*|\s//.*|/\*[.\n]*?\*/}, json, "")` should be replaced with `Regex.replace(~r{^//.*|\s//.*|/\*[.\r\n]*?\*/}, Regex.replace(~r{\r\n}, json, "\n"), "")`.
 
* The server should be started with:

      iex.bat -S mix phx.server

  * Note that this starts up the server at `http://localhost`. (If you find a way to specify an HTTPS port, let us know!)

## Running with Docker

Docker provides a consistent environment across all platforms. Both development and production Dockerfiles use a Nix flake for reproducible builds.

### Development (Linux, MacOS, Windows)

    docker build -f Dockerfile.dev -t riichi-dev .
    docker run -it --rm -v $(pwd):/app -p 80:80 -p 4000:4000 riichi-dev

This mounts your source code into the container for live reloading. Access at `https://localhost:4000`.

On Windows (PowerShell), use `${PWD}` instead of `$(pwd)`:

    docker run -it --rm -v ${PWD}:/app -p 80:80 -p 4000:4000 riichi-dev

### Production

    docker build -t riichi-advanced .
    docker run -p 80:80 -p 4000:4000 -e SECRET_KEY_BASE=$(mix phx.gen.secret) riichi-advanced

### Using Nix directly (Linux, MacOS)

If you have Nix installed with flakes enabled:

    nix develop
    mix deps.get
    mix phx.gen.cert
    (cd assets && npm i)
    HTTPS_PORT=4000 iex -S mix phx.server

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
