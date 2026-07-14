
# Changelog

- __15 Jul 2026__: v1.4.0:
  + Added `/scoringtest` for testing scoring for any ruleset/mods
  + Added `at_least` and `at_most` metaconditionals to MahjongScript (previously only in json)
  + Added `clear_responsibilities` to MahjongScript
  + Added `cond` clause to MahjongScript, for large numbers of cases
  + Added `define_play_restriction` to MahjongScript
  + Added a better UI for score transfers as well as ways to customize it
  + Added a feature where hovering over a tile in the rules tab will zoom in on it
  + Added a ledger-type way for specifying scoring in MahjongScript (see documentation)
  + Added beta Filipino and Visayan variants (thanks Sophie!)
  + Added Chii mod to Sanma (thanks Sophie!)
  + Added documentation for more modes including Zung Jung, MCR, and Fuzhou
  + Added documentation for Zung Jung (thanks Sophie!)
  + Added empty untracked folders for logs, to make local instances smoother to set up (thanks Sophie!)
  + Added English Yaku Names mod for Riichi
  + Added finalized v1.3 Sakicard art (thanks Sakicards community!)
  + Added INSTALL.md for all install instructions for setting up Riichi Advanced locally
  + Added left-side tabs to many modes including MCR, Fuzhou, Sichuan (thanks Sophie!)
  + Added MCR and Tianjin tutorial
  + Added Rust dependency (for performance)
  + Added ryuukyokurenchan mod for HKOS (thanks Sophie!)
  + Added ryuukyokurenchan scoring key (thanks Sophie!)
  + Added the WRC 2025 rules preset for Riichi
  + Added tile indices support for most tiles (thanks Sophie!)
  + Added Tiles tab to every pertinent Riichi mod, as well as to Malaysian and SBR (thanks Sophie!)
  + Added tips to the room screen
  + Added toggle for number of transparent tiles for Washizu mod (thanks Sophie!)
  + Added toplevel `if`/`define` in MahjongScript for conditional compilation-type needs
  + Added tsumo loss mods to Sanma (after removing it)
  + Changed "Skip" button in win screen to say "Waiting" when pressed
  + Changed all instances of "Fly" to "Fei" in Malaysian (thanks Sophie!)
  + Changed certain Malaysian features as mods (4 fei win, fei payments, and seven pairs)
  + Changed star suit coloring from red to pink
  + Fixed a bug involving fractional points (thanks Sophie!)
  + Fixed a bug where `remove_yaku` and `replace_yaku` would cause a crash, if the yaku didn't already exist
  + Fixed a bug where aka tiles were being counted multiple times (thanks Sophie!)
  + Fixed a bug where Custom would load your ruleset twice
  + Fixed a bug where dora would not be shiny after declaring kan
  + Fixed a bug where hidden calls would not be flipped face-up with `flip_all_calls_faceup` (thanks Sophie!)
  + Fixed a bug where mods wouldn't load via the majstest page
  + Fixed a bug where NFHT wasn't always awarded in Vietnamese (thanks Sophie!)
  + Fixed a bug where one of the "Back" buttons on the log menu didn't work (thanks Sophie!)
  + Fixed a bug where open riichi tsumo would award you yakuman (thanks Sophie!)
  + Fixed a bug where rooms would get stuck on the first loaded ruleset
  + Fixed a bug where some tiles would vanish from the winning hand when hovering over it in the win screen
  + Fixed a bug where Tanfonhou checked for an unsupported condition (thanks Sophie!)
  + Fixed a bug where the JC (ignore joker-only calls) button would skip valid calls involving flowers (thanks Sophie!)
  + Fixed a bug where uma wasn't applied to all players in Riichi (thanks Sophie!)
  + Fixed a bug where Washizu mod would end the game after one hand (thanks Sophie!)
  + Fixed a bug where wins by self-draw would be scored way higher than they should be (thanks Sophie!)
  + Fixed a crash when loading an empty ruleset into the custom ruleset page
  + Fixed a visual bug with corners of tiles on main menu
  + Fixed all Fei-based yaku in Malaysian
  + Fixed Amerijong nearest hands display not updating sometimes
  + Fixed Cancellable Riichi acting strangely (hopefully)
  + Fixed Chromium display issues (hopefully)
  + Fixed crash when entering lobby screen
  + Fixed crash when removing yaku that doesn't exist in MahjongScript
  + Fixed Fifth Tile mod interacting badly with other mods (thanks Sophie!)
  + Fixed flowers and tenhou in Malaysian (thanks Sophie!)
  + Fixed flowers not being counted correctly in Malaysian (thanks Sophie!)
  + Fixed Kansai Chiitoi yaku
  + Fixed many interactions between the Star Suit, Ten, Galaxy Mahjong, Blue Dragon mods (thanks Sophie!)
  + Fixed many many erroneous mod interactions (thanks Sophie!)
  + Fixed Milky Way yakuman not being scored in Galaxy Mahjong (thanks Sophie!)
  + Fixed more issues with MCR yaku interactions (thanks Sophie!)
  + Fixed most crashes in existing tutorials (thanks Sophie!)
  + Fixed nagashi for East (thanks Sophie!)
  + Fixed some bugs caused by Riichi being dependent on base.majs (thanks Sophie!)
  + Fixed some CSS bugs on various screens (thanks Sophie!)
  + Fixed some weird behaviours when multiple people are trying to leave a game
  + Fixed some yakuman not being scored properly in Cosmic Riichi (thanks Sophie!)
  + Fixed the Cancellable Riichi mod (thanks Sophie!)
  + Fixed the joker solver not running correctly on Windows
  + Fixed the spelling of "Ittsuu" across the entire repository (thanks Sophie!)
  + Fixed the white-on-white text in the language dropdown menu (thanks Sophie!)
  + Removed Python dependency
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
- _14 Mar 2025__: v1.3.0:
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
- +_1 Mar 2025__: v1.2.0:
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
