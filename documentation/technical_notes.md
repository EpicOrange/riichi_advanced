
# Technical notes on Riichi Advanced

Since the project has grown a lot since its inception in August 2024, this is mostly an summary for myself to help recall all the systems underlying Riichi Advanced... for example, if I take a long hiatus and forget everything. If you're curious about the engineering, you're probably in the right place.

## Summary

This project is written in Elixir with the Phoenix framework, making heavy use of Phoenix's LiveView library. Like all Phoenix projects, it has two moving parts:

- `lib/riichi_advanced`: Model
- `lib/riichi_advanced_web`: Combined View/Controller

Here is a partial breakdown of all the directories:

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
    │   │   └── session_supervisor.ex (DynamicSupervisor instance)
    │   └── riichi_advanced_web
    │       ├── components (stock Phoenix except for components/layouts/root.html.heex)
    │       ├── controllers (stock Phoenix)
    │       ├── views (all LiveViews and live components)
    │       ├── endpoint.ex (main thing! serves all the other files as plugs)
    │       ├── gettext.ex (stock Phoenix)
    │       ├── gettext_hints.ex (explicitly sets some strings to be used in gettext translations)
    │       ├── router.ex (LiveView routes)
    │       └── translations.ex (helper functions to mark strings for gettext translations)
    ├── log (this populates with an error.log upon running Riichi Advanced)
    ├── native
    │   └── riichiadvanced_match (fast Rust implementation of lib/riichi_advanced/game/match.ex)
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

## Overview of each system in play

### Phoenix

Phoenix is essentially _the_ web framework for Elixir. You use it to build websites, so it by default includes a database component, form submission components, a mailer, and so on. However, Riichi Advanced uses none of these, and instead relies heavily on Phoenix's LiveView framework, which uses server-side rendering over websockets to display webpages.

### Elixir/OTP

Like all Elixir projects, Riichi Advanced is built on Elixir/OTP's model of fault tolerance, which involves the entire program consisting of an 'application' which is the root of a single supervision tree. A supervision tree is composed of supervisor processes that restart any child component that crashes. For example, if a `GameState` process crashes, its parent `GameSupervisor` will restart the process, and if _that_ crashes, then `GameSessionSupervisor` restarts _it_, and so on.

The important moving parts of Riichi Advanced's supervision tree roughly looks like this. This tree went through a few redesigns before settling on the current design, which hasn't been touched since early 2025. (because it works.)

    Application
    ├── GameSessionSupervisor
    │   └── GameSupervisor
    │       ├── GameState (one per running game)
    │       ├── GameState
    │       └── GameState
    ├── LobbySessionSupervisor
    │   └── LobbySupervisor
    │       ├── LobbyState (one per ruleset lobby)
    │       ├── LobbyState
    │       └── LobbyState
    ├── RoomSessionSupervisor
    │   └── RoomSupervisor
    │       ├── RoomState (one per game room)
    │       ├── RoomState
    │       └── RoomState
    ├── MessagesSessionSupervisor
    │   └── MessagesSupervisor
    │       ├── MessagesState (one per connected client)
    │       ├── MessagesState
    │       └── MessagesState
    ├── Cache (defines one cache for cached data, and a shorter-lived one for function memoization)
    ├── Phoenix.PubSub (used by state processes above to communicate with LiveViews)
    ├── PlugAttack.Storage.Ets (used by PlugAttack to implement rate limiting)
    └── RiichiAdvancedWeb.Endpoint (used to serve the webpage hosting the game)

This tree omits a lot, mostly because they don't matter much in the course of working on this project. I didn't know any Elixir prior to working on Riichi Advanced, so forgive me and do say something if you see a better way of doing things that I am not doing.

### Actions, conditions, events, and interrupts

The game is modelled using a Lisp-like language in JSON. A ruleset consists of a JSON file whose toplevel keys are mostly event names, whose values are lists of actions to undertake. There is also a `buttons` toplevel key which houses buttons that are available to everyone to press, but they are only shown when a given condition is true. Conditions are also Lisp-like expression trees represented by nested arrays. The first layer of the condition array is in CNF (take AND of every clause, and take OR of every condition inside each clause). Technically it's not normal form, the next layer is another conjunction of terms and so it just alternates between AND/OR at every level, but this is rarely used.

There are only two actions a player may take to alter the state of the game. First, they could discard a tile by clicking on it twice. Second, they can press buttons, if they appear. These are called 'choices' in the code, andtThere are also some other ad-hoc choices for other game modes (like selecting a Saki card) but they're kind of old, the last time I touched that stuff was like early 2025. If I were to rework this system it would be for adding activatable function tiles: basically tiles that act as spell cards, but I digress.

Choosing a choice doesn't immediately execute it; all players must submit a choice before the game updates state. This is because some choices can have precedence over others (e.g. pon overrides chii) so we need all choices in before we continue. Players who don't have choices (not their turn and they have no buttons) automatically submit a 'skip' for their choice. Once all players have a choice submitted, only then does the engine start moving, adjudicating each action in order to update the game state. The resulting state is broadcast to all clients.

This process can be interrupted; instead of an external process issuing an interrupt, the way it works is that some actions are interruptible, and every time an interruptible action is done executing, the game stops and recalculates buttons. If any buttons for any player are available, the game halts and defers all later computation until all players submit a choice again. This is how calls are able to work; after playing a tile (an interruptible action) everyone who can call gets a call button generated for them that they can press to take the discard. This naturally extends to interrupting interrupts, e.g. calling chankan (a button choice) after someone executes an added kan (also a button chioce).

Branching conditionals, function calls, and `pause` all act a little differently. Branching conditionals add all of the actions to a stack (the same stack used for deferring computation). Function calls merely save some context along with the function body, and puts it on the same stack. `pause` is completely different; it is a no op, but its existence forces the game to halt and stop processing anything for a certain amount of time. This is achieved by setting `game_active` (basically a game global) to `false`, and issuing a future message to itself to flip it back to `true` after the duration has passed.

### AI players

Every time state is broadcast, AI players are also notified. AI players, despite having different names in-game, all act the same way, and their behavior is entirely described in `ai_player.ex`. Essentially they are efficiency maximizers in the sense that they calculate waits-towards-next-shanten and also counting ukeire. They will not make any calls since idk what good call strategy looks like, so (in riichi) they will just find the most efficient path to riichi. "Decreasing shanten" applies to pretty much every variant so the AI does the same thing for every mahjong variant.

### Tile representation

Internally, tiles are represented as Elixir atoms, so `:"1m"` is the 1 of characters.
A tile may also have a set of string attributes, so `{:"1m", ["dora"]}` is the 1 of characters with the `"dora"` attribute.
A hand is simply a list of tiles.

In the match engine ([/lib/riichiadvanced/game/match.ex](/lib/riichiadvanced/game/match.ex)), the representation is different since list operations are slow and bit operations are fast.
A tile is represented by a prime number. You can find the tile-to-prime mapping in [/lib/riichiadvanced/constants.ex](/lib/riichiadvanced/constants.ex). Tile attributes are given as a bitset. Basically, when game rules are loaded, every attribute mentioned is collected into a list of size `n` and attributes are simply a bitset of length `n` where having an attribute means setting the corresponding bit to 1.
A hand (or any other set of tiles) is represented by a list of tiles together with the product of their primes, which we call the hash of the hand. Because prime numbers are prime, their product uniquely represents a multiset of tiles. The reason for this encoding is so that subset removals become simple division.

Joker tiles are not represented any differently from other tiles. The reason they act like jokers is because each player has a `tile_behavior` map that contains another map called `aliases`. `aliases` is just a nested map `tile => attributes =>` set of joker tiles that can be used as that tile/attrs combo. When performing checks, the given player's `aliases` is passed in, and this allows the specified joker tiles to be used as the tiles it maps to.

There is a special tile `:any` that is considered always equal to any tile. `:any` tiles are not ever instantiated (into a player's hand, say) but a joker aliased to `:any` gives it universal joker power, as that means the joker can be treated as `:any`. `:any` with attributes is also used to specify "any tile with this attribute" which is occasionally useful.

### Rust

The main calculation in mahjong games turns out to be matching tiles to a certain shape (sequence, triplet, etc.) This matching code was originally done in pure Elixir, but profiling revealed that it was the main hot loop slowing everything down. Because of this, it has since moved to a Rust implementation, with the boundary bridged by the (incredible) `rustler` package.

The Elixir version of match did a form of breadth-first-search (BFS) which was great for debug messages and correctness but pretty bad for speed. The Rust implementation of match uses the same specification and input as the Elixir version (which still exists as a fallback). However, the Rust side boasts several algorithmic improvements that make it way faster. In particular it looks at the specification and runs one of the following handlers (checked in order):

- If the specification calls for an exact set of tiles (such as kokushi hands), then it's handled by `match_exact.rs` which implements the obvious method of just checking each tile that is called for, and removing them from hand.
- If the specification calls for pairs of tiles (length-2) that are offset by some amount (such as seven pairs hands, which are two tiles offset by 0), it is handled by `match_blossom.rs` which uses Edmonds' [blossom algorithm](https://en.wikipedia.org/wiki/Blossom_algorithm) to find a maximal matching.
- If the specification calls for sets of tiles (any length) that are each offset by some amount (such as standard hands, which need four sequences/triplets), it is handled by `match_bipartite.rs` which constructs a bipartite matching with hand tiles on one side and specification slots on the other. Since hand sizes are tiny and there usually aren't many of them, I opted to just use backtracking search for the matching instead of what I usually reach for ([Hopcroft-Karp](https://en.wikipedia.org/wiki/Hopcroft%E2%80%93Karp_algorithm)) but may change this in the future.
- Any other specification is handled by `match_dfs.rs` which does a backtracking depth-first-search that goes like 'let's see what happens if we say _this_ tile matches' at every step. Abstractly, this is also equivalent to constructing a bipartite matching, but some match specificatons require searching _every_ possible matching. To enumerate matchings, the bipartite graph is instead represented by a `n` by `m` chessboard with holes in it, such that each non-hole corresponds to a edge in the bipartite graph (in other words, there is no hole at `(i,j)` whenever tile `i` matches spec slot `j`). Enumerating all solutions for `n`-rooks results in all possible matchings.
- American Mahjong hands are handled slightly differently since they have some really strong constraints. Typically it uses `match_exact` or `match_bipartite`, but in some parts of the code we must check for partial matches, and that is done using [Hopcroft-Karp](https://en.wikipedia.org/wiki/Hopcroft%E2%80%93Karp_algorithm) (in Elixir) to find a maximal bipartite matching.

I also didn't know modern Rust prior to working on Riichi Advanced, so forgive me if you see some possibly evil Rust code.

### Z3

Matching tiles to shapes is good but it doesn't really help when there are joker tiles and you need to know all sets of valid joker identities. Luckily, finding all possible assignments is a problem built for constraint solvers, and that's where Z3 comes in.

All of this logic is done in [`lib/riichi_advanced/game/smt.ex`](lib/riichi_advanced/game/smt.ex) which is called by the joker solver in [`lib/riichi_advanced/game/joker_solver.ex`](lib/riichi_advanced/game/joker_solver.ex). It takes as input:

-  a hand (with jokers),
-  a specification for a winning hand,
-  the domain of every joker (what a joker can become),
-  plus a possible custom tile ordering to support weird tile/suit topologies such as suits wrapping from 9 to 1.

`smt.ex` encodes the problem into raw SMTLIB2 (no python intermediary!), sends it to a child Z3 process, and decodes the result back into joker assignments.

The encoding into SMT first uses the tile ordering to identify chains (i.e. suits that don't wrap) and loops (i.e. suits that wrap) and uses that information to derive an encoding of each tile as a 3-bit unsigned integer plus a flag bit. Then a hand is a length-(number of tiles times 4) bitvector, each 4 bits representing the count of a tile. The winning hand specification input is then turned into a kind of mask and a constraint is made to search for hands that match that mask. The existing non-joker tiles form a starting hand, and each joker in hand is a variable, and a winning hand is literally the sum (starting hand + sum of all jokers). By constraining the winning hand to match the mask, one solves for every possible set of joker identities using the standard SMT trick of generating a solution, adding "NOT that solution" as a constraint, and generating another solution until there are no more solutions.

There are a few optimizations, the most important one being [symmetry-breaking constraints](https://en.wikipedia.org/wiki/Symmetry-breaking_constraints). Basically if you have 2 identical jokers then you don't want solutions that are the same except for those 2 jokers swapping values. The current optimization does this for every pair of jokers whose domains overlap, and this does save a measurable amount of time (like 10%?)

Communications between Elixir and Z3 relies on the `ex_smt` package, which was kind of unmaintained, so a patched version exists at `lib/ex_smt`.

### `jq`

A main feature of Riichi Advanced is custom ruleset specifications (in JSON). Rulesets are essentially a Lisp-style DSL where actions look like `["draw", 1]`, and lists of actions are bound to events. The [full specification can be found here](/documentation/documentation_json.md) (warning: long and extensive).

Originally crafting a ruleset requires carefully crafting a JSON object that binds the right actions to the right events in some way. However, Elixir's main JSON parser (Jason) does not support comments and errors on trailing commas, so this process was tedious and error-prone. So `jq`, which is essentially a JSON modification language, was employed to make modifications on existing rulesets. Riichi Advanced calls these __mods__, because you can apply a number of `jq` files to a base ruleset to create a desired ruleset in much the same way as one would mod a game.

### MahjongScript

One problem with `jq` being used is that it puts a large demand on knowing both the `jq` language as well as the internals of how Riichi Advanced parses JSON rulesets. In addition, since rulesets come from user input, it was impossible to allow users to write and apply raw `jq` since `jq` can do things like read environment variables and I don't want that to be possible.

To solve both problems, a DSL dubbed MahjongScript was developed to 1) provide a more approachable method to writing mods and 2) be incredibly limiting, in direct contrast with `jq`'s Turing-completeness. MahjongScript compiles to a mahjong-specific limited subset of `jq`, and is hopefully safe in the sense that Riichi Advanced right now allows you to write and play games written in MahjongScript.

Since a JSON ruleset can be created by applying a `jq` query to the empty object `{}`, both rulesets and mods can be written with MahjongScript. There is an ongoing translation process to turn old JSON rulesets and old `jq` mods into MahjongScript.

[MahjongScript documentation can be found here.](/documentation/mahjongscript.md)
Communications between Elixir and `jq` relies on the `ex_jq` package, which was similarly patched and lives in `lib/ex_jq`.

### Collaborative editing

One of the challenges in the game room code was making it so that one can toggle options and everyone else can see that change. Since rooms now include a MahjongScript input box (`<textarea>`), the idea was to sync edits in the same way as Google Docs, that is, collaborative editing.

The implementation here relies on the `delta` package to describe and transform edits. I really don't remember how this was done, but it involved writing some protocol between Elixir and client JavaScript.

### Deployment

Currently automatic deployment is done via GitHub Actions. It just runs the tests, then `ssh`es into the server to make it pull the latest code and restart the server.

The last bit, restarting the server, is a problem because that would destroy everyone's running games, which are running in memory. (Riichi Advanced purposefully avoids storing any data, and has no database to fall back on.)

The solution to this was basically [blue-green deployment](https://en.wikipedia.org/wiki/Blue%E2%80%93green_deployment). Currently how it works is:

- the tests are run,
- the server is instructed to pull changes from GitHub,
- the server launches a second Riichi Advanced instance,
- the existing Riichi Advanced instance detects the new one, and
- it pushes all game state to the new instance before terminating.

This results in about a half second lag as the client soft-refreshes and reconnects. But they will come back to the same game state they were at, so problem solved I guess.

There is a single deficiency and that is the inability to push the GenServer 'mailbox' over, i.e. all inbound Elixir messages are dropped when this happens. I find that this is disruptive if the client happens to be on a winning-hand screen, since advancing that relies on a timer ticking down every second, which gets interrupted by this process. I don't really have a solution to this quite yet.
