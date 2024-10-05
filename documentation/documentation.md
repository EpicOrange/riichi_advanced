# `ruleset.json` basic concepts

A ruleset is a JSON file consisting of a single object. We'll introduce the possible keys of this object one by one.

Let's start with a bare object:

    {}

This creates the following game:

![](bare.png)

## Defining keys in the ruleset

To add a wall to the game, simply specify a `"wall"` key containing an array of tiles as strings. For example:

    {
      "wall": ["1m", "1m", "1m", "1m",
               "2m", "2m", "2m", "2m",
               "3m", "3m", "3m", "3m",
               "4m", "4m", "4m", "4m",
               "5m", "5m", "5m", "5m",
               "6m", "6m", "6m", "6m",
               "7m", "7m", "7m", "7m",
               "8m", "8m", "8m", "8m",
               "9m", "9m", "9m", "9m",
               "1p", "1p", "1p", "1p",
               "2p", "2p", "2p", "2p",
               "3p", "3p", "3p", "3p",
               "4p", "4p", "4p", "4p",
               "5p", "5p", "5p", "5p",
               "6p", "6p", "6p", "6p",
               "7p", "7p", "7p", "7p",
               "8p", "8p", "8p", "8p",
               "9p", "9p", "9p", "9p",
               "1s", "1s", "1s", "1s",
               "2s", "2s", "2s", "2s",
               "3s", "3s", "3s", "3s",
               "4s", "4s", "4s", "4s",
               "5s", "5s", "5s", "5s",
               "6s", "6s", "6s", "6s",
               "7s", "7s", "7s", "7s",
               "8s", "8s", "8s", "8s",
               "9s", "9s", "9s", "9s"]
    }

This results in this game:

![](wall.png)

You can see that the 108 in the center corresponds to the 108 tiles we have just specified.

Add `"starting_tiles"` to have each player start with that many tiles from the wall:

    {
      "wall": ["1m", "1m", "1m", "1m",
               "2m", "2m", "2m", "2m",
               "3m", "3m", "3m", "3m",
               "4m", "4m", "4m", "4m",
               "5m", "5m", "5m", "5m",
               "6m", "6m", "6m", "6m",
               "7m", "7m", "7m", "7m",
               "8m", "8m", "8m", "8m",
               "9m", "9m", "9m", "9m",
               "1p", "1p", "1p", "1p",
               "2p", "2p", "2p", "2p",
               "3p", "3p", "3p", "3p",
               "4p", "4p", "4p", "4p",
               "5p", "5p", "5p", "5p",
               "6p", "6p", "6p", "6p",
               "7p", "7p", "7p", "7p",
               "8p", "8p", "8p", "8p",
               "9p", "9p", "9p", "9p",
               "1s", "1s", "1s", "1s",
               "2s", "2s", "2s", "2s",
               "3s", "3s", "3s", "3s",
               "4s", "4s", "4s", "4s",
               "5s", "5s", "5s", "5s",
               "6s", "6s", "6s", "6s",
               "7s", "7s", "7s", "7s",
               "8s", "8s", "8s", "8s",
               "9s", "9s", "9s", "9s"],
      "starting_tiles": 13
    }

![](starting_tiles.mp4)

Because every player has drawn 13 tiles, that leaves 56 tiles in the wall. Note that there is no drawing from the wall quite yet.

Unless otherwise stated, every key like `wall` and `starting_tiles` are top-level keys. These define the main moving parts of Riichi Advanced rulesets. A full documentation of the keys is below this concepts guide.

## Events, contexts, and actions

To make players draw from the wall, we will introduce our first **action**: `draw`, which draws a tile.

Add the following to the ruleset:

    "after_turn_change": {
      "actions": [["draw"]]
    }

This results in the following game:

![](draw.mp4)

The `after_turn_change` **event** is triggered after every turn change, as well as at the start of the game. Every event handler (like this one) is defined by a top-level key.

In addition, every event has an invisible **context**. Contexts determine how actions are evaluated, and at minimum must define a `seat` (the seat of the player that the actions act on). In other words, the player who `draw`s is the `seat` player, which is defined by `after_turn_change`. It happens that `after_turn_change` sets `seat` to the player whose turn it is after the turn change, so that player is the one who gets to draw.

Note that `actions` is specified as a doubly nested array. This is because `actions` is a list of actions, and each action itself is an array, to accommodate parameters: `["draw"]` draws one tile, while `["draw", 2]` draws two.

## Conditions

Our ruleset above has one issue: once the draw gets to the end of the wall, the game will try to draw nonexistent tiles and crash. Instead we should check if there are draws left using the `no_tiles_remaining` **condition**, and end the game with an exhaustive draw via the `ryuukyoku` action.

The simplest conditional is the `when` action. `when` takes two parameters: a list of conditions, and a list of actions to fire when all those conditions are met.

We can prepend it to the `actions` list of `after_turn_change`:

    "after_turn_change": {
      "actions": [
        ["when", ["no_tiles_remaining"], [["ryuukyoku"]]],
        ["draw"]
      ]
    }

Now the game will end in an exhaustive draw when there are no more tiles. However, the second action will still fire, and crash the game. So we need to negatively condition `draw` on `no_tiles_remaining`. Any condition can be negated by prepending the string `"not_"` to it:

    "after_turn_change": {
      "actions": [
        ["when", ["no_tiles_remaining"], [["ryuukyoku"]]],
        ["when", ["not_no_tiles_remaining"], [["draw"]]]
      ]
    }

Instead of two checks for a condition and its negation, we can use the 3-argument `ite` action (**i**f-**t**hen-**e**lse) to combine these two `when` actions:

    "after_turn_change": {
      "actions": [
        ["ite", ["no_tiles_remaining"], [["ryuukyoku"]], [["draw"]]]
      ]
    }

## Auto buttons

You might have noticed that players' hands are in dire need of sorting. To remedy this, we could call the `sort_hand` action after every turn change just like how we `draw` after every turn change. But what if the player wants to turn it off?

This is the main purpose of **auto buttons**, which are essentially action lists that fire every turn change if enabled. With auto buttons, players can control whether certain actions trigger on every turn. Here's the solution for hand sorting:

    "auto_buttons": {
      "auto_sort": {
        "display_name": "A",
        "actions": [["sort_hand"]],
        "enabled_at_start": true
      }
    }

All auto buttons are defined in the toplevel `auto_buttons` key and have an identifier, here `auto_sort`. Each auto button has a display name `display_name`, an action list `actions`, and whether they are enabled by default `enabled_at_start`. Here's what that looks like:

![](auto_buttons.png)

That's really all there is to auto buttons.

## Call buttons and interruptible actions

Let's say you want the ability to call pairs -- if someone drops a tile and you have the same tile in hand, you get to interrupt the turn change and call it. To do so, you must define a **call button**. Just like how auto buttons are defined in the toplevel `auto_buttons` object, call buttons are defined in the toplevel `buttons` object.

We will spend this section breaking down the following implementation.

    {
      ...
      "buttons": {
        "pair": {
          "display_name": "Pair",
          "call": [[0]],
          "show_when": ["not_our_turn", "not_no_tiles_remaining", "someone_else_just_discarded", "call_available"],
          "actions": [["call"], ["change_turn", "self"]]
        }
      },
      "interruptible_actions": ["play_tile"]
    }

![](call.mp4)

This defines a button with button text "Pair" that shows when every condition in the `show_when` condition list is satisfied. Then it runs the action list: `call` calls tiles based on the `call` key in the button, and `change_turn` changes turn to ourselves.

`"call": [[0]]` is a **call specification**. This one is pretty simplistic so it is hard to explain, but let's start with more interesting call specifications as examples and work backwards:

- chii: `[[-2, -1], [-1, 1], [1, 2]]`. Either two tiles left of the discard, two tiles with one on either side of the discard, or two tiles right of the discard.
- pon: `[[0, 0]]`. Only one possibility, which is two tiles matching the discard.
- pair: `[[0]]`. Only one possibility, which is one tiles matching the discard.

Call buttons _must_ have `call_available` as one of the conditions in `show_when`. This condition checks whether the last discard matches the call specification. If you don't check that, and click the call button, the game will crash.

The final moving part is the top-level `interruptible_actions` key, which defines a list of actions that can be interrupted. Here the internal `play_tile` action is made interruptible, and so after every `play_tile` action, the game will check the `show_when` button condition to see if they should appear. Without this key, `show_when` will only be checked at the start of each game.

## Conditions with arguments and complex conditions

The buttons in the top-level `buttons` object do not need to be call buttons. Call buttons are simply buttons that have a call specification in the `call` key: buttons in general only need `display_name`, `show_when`, and `actions`.

Here's an example: the default riichi button in the riichi ruleset:

    "riichi": {
      "display_name": "Riichi",
      "show_when": [
        "our_turn",
        "has_draw",
        {"name": "status_missing", "opts": ["riichi"]},
        {"name": "has_score", "opts": [1000]},
        "next_draw_possible",
        {"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]},
        {"name": "match", "opts": [["hand", "calls", "draw"], ["tenpai_14", "kokushi_tenpai"]]}
      ],
      "actions": [
        ["big_text", "Riichi"],
        ["set_status", "riichi", "just_reached"],
        ["push_message", "declared riichi"],
        ["when", [{"name": "status", "opts": ["discards_empty"]}, "no_calls_yet"], [["set_status", "double_riichi"]]]
      ]
    }

Notice that some of the conditions in `show_when` are objects. Unlike actions, whose arguments are given as additional entries in the action array, conditions with arguments must be in the form `{"name": <name>, "opts": [<args>]}`. Indeed, every string condition like `"our_turn"` is shorthand for `{"name": "our_turn", "opts": []}`.

The reason for this is complex conditions. If you have conditions "a" "b" and "c", then to express ("a" AND "b" AND "c") you would write:

    ["a", "b", "c"]

This is what we've seen earlier above. I defined it as a condition list. But if you want (("a" OR "b") AND "c") you would write

    [["a", "b"], "c"]

and if you wanted ("a" OR ("b" AND "c")) you would write

    [["a", ["b", "c"]]]

So the first level of array joins all its elements with AND, the second level of array joins with OR, and the third level of array joins with AND, and so on. Because complex conditions are defined by the nesting level of arrays, conditions with arguments cannot be defined using arrays, which is why conditions with arguments look like `{"name": <name>, "opts": [<args>]}` instead.

This concludes the overview of basic concepts in Riichi Advanced rulesets. Note that the last condition in `show_when` is a `match` condition, and it is used extensively in Riichi Advanced to check for tenpai, to check for yaku, and to check for anything involving the hand. It is also the most complex condition by far, so it gets its own explainer section below. It is not a basic concept so feel free to skip it and proceed to the full documentation.

## The `match` condition and match specifications

    {"name": "match", "opts": [["hand", "calls", "draw"], ["tenpai_14", "kokushi_tenpai"]]}

`match` is a condition with two arguments. The first is an array of objects to match against, here `["hand", "calls", "draw"]`. The second is an array of **match specifications**, here `["tenpai_14", "kokushi_tenpai"]`. The idea is, if your hand, calls, and drawn tile matches `tenpai_14` or `kokushi_tenpai`, then you get to riichi.

`tenpai_14` or `kokushi_tenpai` are **named match specifications**. This is how they are specified in the default riichi ruleset:

    "tenpai_14_definition": [
      [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ],
      [ "exhaustive", [["shuntsu", "koutsu"], 4] ],
      [ [["koutsu"], -2], [["pair"], 6] ]
    ],
    "kokushi_tenpai_definition": [
      [ "unique",
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
      ]
    ]

Named match specifications are top-level keys ending in `"_definition"`. Each named match specification is an array of **match specifications** that it represents. So the array `["tenpai_14", "kokushi_tenpai"]` is equivalent to writing the following array of four match specifications:

    [
      [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ],
      [ "exhaustive", [["shuntsu", "koutsu"], 4] ],
      [ [["koutsu"], -2], [["pair"], 6] ],
      [ "unique",
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
      ]
    ]

Let's go over these one by one and see how `match` matches against your 14-tile hand as defined by `["hand", "calls", "draw"]`.

    [ "exhaustive", [["pair"], 1], [["ryanmen/penchan", "kanchan", "pair"], 1], [["shuntsu", "koutsu"], 3] ]

Skipping the `exhaustive` flag for now, the intuition of this one is that it takes a pair out of your 14-tile hand, leaving a 12-tile hand. Then it takes one of either `["ryanmen/penchan", "kanchan", "pair"]` out of the 12-tile hand, leaving a 10-tile hand. Finally, it takes out _three_ of either `shuntsu` or `koutsu` out of the remainder, leaving one tile, which is thrown away. The `exhaustive` flag at the beginning means this entire process exhaustively tries every single possibility of taking out these **groups**, instead of just taking the first one it sees in the given order. The match succeeds if it was able to find each group in your 14-tile hand. Intuitively it means 13 of the 14 tiles in your hand match a standard hand with a ryanmen/penchan/kanchan/pair wait, making you tenpai.

Things like `pair`, `ryanmen/penchan`, etc are **sets** defined in the top-level `set_definitions` which for riichi looks like this:

    "set_definitions": {
      "pair": [0, 0],
      "shuntsu": [0, 1, 2],
      "koutsu": [0, 0, 0],
      "quad": [0, 0, 0, 0],
      "ryanmen/penchan": [0, 1],
      "kanchan": [0, 2],
      "iipeikou": [0, 0, 1, 1, 2, 2],
      ...
    }

I think that is self-explanatory. Let's move onto the next match definition.

      [ "exhaustive", [["shuntsu", "koutsu"], 4] ],

This does the same thing as above, except it just takes four `shuntsu` or `koutsu` out of your hand immediately. If it's able to do that then you are clearly tenpai with a single tile wait, which can be either of the two remaining tiles of your 14-tile hand.

      [ [["koutsu"], -2], [["pair"], 6] ],

This is the seven pairs check. The negative **count** in this one specifies a negative match. If we're able to take out two `koutsu` from the hand at that point in the check, then the match fails. Otherwise, it proceeds to take six pairs out of the hand, and if it can, then the match succeeds and you are tenpai for seven pairs. (The negative koutsu check takes care of the case where you have 4 pairs and 2 triplets, which is not tenpai for seven pairs.)

      [ "unique",
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 12],
        [["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"], 1]
      ],

This is the kokushi check and introduces the `unique` flag. `unique` is useful when you want to ensure that each group specified in the group list `["1m","9m","1p","9p","1s","9s","1z","2z","3z","4z","5z","6z","7z"]` is taken _at most once_ over the course of taking out twelve of them. So this check takes out 12 unique terminal/honors plus one more, and if it can do that, the match succeeds and you are tenpai for kokushi.

That's about it for match specifications.

# `ruleset.json` full documentation

Here are all the toplevel keys. Every key is optional.

Events

- `after_call`: Triggers at the end of any call. Context: `seat` is the caller's seat, `caller` is the caller's seat, `callee` is the seat called from, and `call` contains call information.
- `after_saki_start`: Triggers after all players have drafted their saki cards in the sakicards gamemode. This is only here because I hardcoded this interaction and may remove it in the future. Context: `seat` is the current seat (so, east).
- `after_start`: Triggers at the start of each round. Context: `seat` is the current seat (so, east).
- `after_turn_change`: Triggers at the end of each turn change. Context: `seat` is the seat whose turn it is after the turn change.
- `before_abortive_draw`: Triggers before an abortive draw is called. Context: `seat` is the seat whose turn it is at the time of the abortive draw.
- `before_call`: Triggers at the start of any call. Context: `seat` is the caller's seat, `caller` is the caller's seat, `callee` is the seat called from, and `call` contains call information.
- `before_exhaustive_draw`: Triggers before an exhaustive draw is called. Context: `seat` is the seat whose turn it is at the time of the exhaustive draw.
- `before_turn_change`: Triggers at the start of each turn change. Context: `seat` is the seat whose turn it is before the turn change.
- `before_win`: Triggers before a win is called. Context: `seat` is the seat who called the win.
- `play_effects`: This is not actually an event like the others. Instead it is a list of action lists triggered on discards, where each action list is conditioned on the identity of the tile being discarded. TODO document this

Buttons:

- `auto_buttons`: List of auto buttons, described above
- `buttons`: List of buttons, described above

Mods:

- `available_mods`: List of available mods
- `default_mods`: List of mods enabled by default

Rules:

- `display_honba`: Whether to show number of honba in the middle
- `display_riichi_sticks`: Whether to show number of riichi sticks in the middle
- `dora_indicators`: Defines what tile dora indicators indicate
- `enable_saki_cards`: Set to `true` to enable saki power stuff (may remove this key in the future)
- `initial_score`: Starting score
- `interruptible_actions`: List of actions that can be interrupted by buttons
- `max_revealed_tiles`: Number of tiles to show at the top at all times
- `max_rounds`: Number of rounds before the game ends
- `play_restrictions`: TODO
- `reserved_tiles`: List of tiles reserved from the end of the wall
- `revealed_tiles`: List of reserved tiles revealed at the start of the game
- `set_definitions`: List of definitions for sets used in match definitions, described above
- `starting_tiles`: Number of tiles every player starts with every round
- `wall`: The list of tiles used in the game

Yaku and scoring:

- `extra_yaku`: List of yaku that doesn't count towards having yaku, like dora
- `limit_point_name`: Name for limit points, like ★
- `meta_yaku`: List of yaku whose conditions depend on existing yaku.
- `minipoint_name`: Name for minipoints, like Fu
- `point_name`: Name for points, like Han
- `score_calculation`: TODO
- `yaku`: List of yaku.
- `yaku_alt_names`: Does nothing, but I might make it do something in the future.
- `yaku_precedence`: An object specifying which yaku gets overridden by other yaku.
- `yakuman`: List of yakuman.

Saki:

- `saki_deck`: Deck of saki cards.
- `saki_ver`: The saki card spritesheet to use, either "v12" or "v13".

# Actions

TODO

# Conditions

TODO

# Scoring

Scoring refers to the exchange of points after a win or a draw. To enable scoring, the `"score_calculation"` key must exist and be associated with an object with the following keys:

- `"method"`

Scoring will be performed based on the `"method"` key in this object. Here are the currently supported options for `"method"`:

## `"method": "riichi"`

Once a win action is triggered (`"win_by_discard"`, `"win_by_call"`, or `"win_by_draw"`) the game generates a win for each player that triggered a win action.

This method enables fu calculations for a winning hand. Fu calculation is currently hardcoded and cannot be customized, but this is subject to change.

In the event of an exhaustive draw, this method looks for the status `"tenpai"` among all existing players. (This means you will have to set and unset tenpai status through the course of the game.) All `"tenpai"` players will pay the non-`"tenpai"` players according to the rules of riichi. That is, unless any player has the status `"nagashi"`, in which case they get nagashi payments.

TODO: other scoring methods

# Game loop in detail (might be outdated)

Here's how the game loop functions:

At the very start of the game, the action `["change_turn", "east"]` is run. This triggers turn change actions (e.g. drawing a tile) which essentially sets up the game.

Then we wait for a player to make a choice. A choice is defined as the following:

- Clicking a tile -> if it's your turn, your choice is `"play_tile"`.
- Clicking a button -> if you have that button, your choice is that button's name.
- Skipping a button -> your choice is "skip".

Every choice has a list of actions associated with it.

- Clicking a tile -> the internal `"play_tile"` action (using the index of the tile played), followed by the `"advance_turn"` action.
- Clicking a button -> listed in the `"actions"` key of said button.
- Skipping a button -> Empty list of actions.

After every choice made, a check is done to see if everyone has submitted their choices.
If it is not their turn and they have no buttons, their choice is automatically "skip".
If it is their turn and they have just discarded, their choice is automatically "skip".
Also, if it is not their turn and all their buttons are superceded by other choices, their choice is automatically "skip".
The canonical example is if someone chooses "ron" -- anyone who can only "pon" or "chii" is forced to skip.

As soon as everyone has a choice, their actions are adjudicated.
The order shouldn't matter in most cases, but it is east->south->west->north.
For instance, a double ron would display rons in that order.
Afterwards, everyone's choices are cleared.

That's the basic game loop, but there is some subtlety regarding running and interrupting actions.
Any action in the "interruptible_actions" key of the rules can be interrupted given the right conditions.
Specifically, after every action a check is made to every player for each button to see if it can appear.
If any button appears for any player, all future actions are deferred.
The result is that after action adjudication, every player has a possible list of deferred actions.
Choices must be made again in order to resolve these deferred actions.
Specifically, if every player chooses "skip", then all deferred actions are run, and everything proceeds as normal.
Otherwise, there must be some player who chooses a non-"skip" choice.
In that case, action adjudication happens as normal, with all previously deferred actions discarded.

An example of the above is "pon" after someone plays a tile.
Normally, playing a tile plays the tile and then advances the turn, which is two actions.
However, after playing the tile, the game detects that someone can pon the tile, and shows the pon button.
This defers the "advance_turn" action and players must make their choices again.
If the ponning player presses "pon" then they discard the deferred "advance_turn" action and runs the "pon" button actions.
("pon" includes a `["change_turn", "self"]` action, which allows game flow to continue.)
Otherwise if the ponning player presses "skip", then all players have chosen skip.
This means the deferred "advance_turn" is then run, as if the pon choice never happened.
