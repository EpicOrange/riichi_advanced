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

https://github.com/user-attachments/assets/523253a2-ca78-40f0-b677-f4ad54530aa8

Because every player has drawn 13 tiles, that leaves 56 tiles in the wall. Note that there is no drawing from the wall quite yet.

Unless otherwise stated, every key like `wall` and `starting_tiles` are top-level keys. These define the main moving parts of Riichi Advanced rulesets. A full documentation of the keys is below this concepts guide.

## Events, contexts, and actions

To make players draw from the wall, we will introduce our first **action**: `draw`, which draws a tile.

Add the following to the ruleset:

    "after_turn_change": {
      "actions": [["draw"]]
    }

This results in the following game:

https://github.com/user-attachments/assets/d765d382-9d6a-4579-84e0-938ebe3efb03

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

https://github.com/user-attachments/assets/392652bc-1baf-413b-a616-16617211ff94

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
- `play_effects`: This is not actually an event like the others. Instead it is a list of action lists triggered on discards, where each action list is conditioned on the identity of the tile being discarded. Context: `seat` is the seat who played a tile, and `tile` is the played tile.

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
- `persistent_statuses`: Names of statuses that should persist between rounds.
- `persistent_counters`: Names of counters that should persist between rounds.
- `play_restrictions`: List of two-element arrays detailing a **play restriction**. The first element is an array of tiles that the restriction applies to. The second element is a condition -- if the condition is true, the player cannot play that tile.
- `reserved_tiles`: List of tiles reserved from the end of the wall
- `revealed_tiles`: List of reserved tiles revealed at the start of the game
- `set_definitions`: List of definitions for sets used in match definitions, described above
- `shown_statuses`: List of statuses to show (private to the player)
- `starting_tiles`: Number of tiles every player starts with every round
- `wall`: The list of tiles used in the game

Yaku and scoring:

- `extra_yaku`: List of yaku that doesn't count towards having yaku, like dora
- `limit_point_name`: Name for limit points, like ★
- `meta_yaku`: List of yaku whose conditions depend on existing yaku.
- `minipoint_name`: Name for minipoints, like Fu
- `point_name`: Name for points, like Han
- `score_calculation`: Scoring method. See the scoring method section.
- `yaku`: List of yaku.
- `yaku_alt_names`: Does nothing, but I might make it do something in the future.
- `yaku_precedence`: An object specifying which yaku gets overridden by other yaku.
- `yakuman`: List of yakuman.

Saki:

- `saki_deck`: Deck of saki cards.
- `saki_ver`: The saki card spritesheet to use, either "v12" or "v13".

Other:

- `tile_images`: Mapping of tiles to replacement image urls.

# Actions

- `["noop"]`: does nothing, but you can put it in `interruptible_actions` to make it an interrupt.
- `["push_message", message]`: Sends a message to all players using the current player as a label. Example: `["push_message", "declared riichi"]`
- `["draw", num, tile]`: Draw `num` tiles. If `tile` is specified, it draws that tile instead of from the wall.
- `["call"]`: For call buttons only, like pon. Triggers the call.
- `["self_call"]`: For self call buttons only, like ankan. Triggers the self call.
- `["upgrade_call"]`: For upgrade call buttons only, like kakan. Triggers the upgrade call.
- `["flower", flower1, flower2, ...]`: Declare a flower, with `flower1`, etc as the choices.
- `["draft_saki_card", num]`: Draw a saki card out of `num` choices.
- `["reverse_turn_order"]`: Reverses the turn order.
- `["advance_turn"]`: Goes forward in turn order.
- `["change_turn", seat]`: Change turn to the specified seat. Allowed values of `seat` are: `"east"`, `"south"`, `"west"`, `"north"`, `"shimocha"`, `"toimen"`, `"kamicha"`, `"self"`
- `["win_by_discard"]`: Declares a win using the last discard as the winning tile.
- `["win_by_call"]`: Declares a win using the last called tile as the winning tile.
- `["win_by_draw"]`: Declares a win using the first drawn tile as the winning tile.
- `["ryuukyoku"]`: Declares an exhaustive draw.
- `["abortive_draw", name]`: Declares an abortive draw by the given `name`.
- `["set_status", status1, status2, ...]`: Add to the set of statuses for the current player.
- `["unset_status", status1, status2, ...]`: Remove from the set of statuses for the current player.
- `["set_status_all", status1, status2, ...]`: Add to the set of statuses for all players.
- `["unset_status_all", status1, status2, ...]`: Remove from the set of statuses for all players.
- `["set_callee_status", status1, status2, ...]`: Only usable in the `after_call` event. Set statuses for the player called from.
- `["unset_callee_status", status1, status2, ...]`: Only usable in the `after_call` event. Unset statuses for the player called from.
- `["set_caller_status", status1, status2, ...]`: Only usable in the `after_call` event. Set statuses for the player doing the call.
- `["unset_caller_status", status1, status2, ...]`: Only usable in the `after_call` event. Unset statuses for the player doing the call.
- `["big_text", text, seat]`: Popup big text for the current player, or the given seat if `seat` is specified. Allowed values of `seat` are: `"shimocha"`, `"toimen"`, `"kamicha"`, `"self"`, `"last_discarder"`
- `["pause", ms]`: Pause for `ms` milliseconds. Useful after a `big_text` to make actions happen only after players see the big text.
- `["sort_hand"]`: Sort the current player's hand.
- `["reveal_tile", tile]`: Show a given tile above the game for the remainder of the round.
- `["add_score", amount, recipients]`: Add to the score for the current player, or for the `recipients` if specified. Allowed values for `recipients` are: `"shimocha"`, `"toimen"`, `"kamicha"`, `"self"`, `"last_discarder"`, `"all"`, `"others"`
- `["put_down_riichi_stick", num]`: Makes the current player put down a riichi stick, or `num` riichi sticks if specified. Does not change their score.
- `["add_honba", num]`: Adds the given number of honba. (default 1)
- `["reveal_hand"]`: Shows the current player's hand to everyone for the remainder of the round.
- `["discard_draw"]`: Discards the current player's draw. Useful as an auto button.
- `["press_button", button_id]`: Press a given button by id, does nothing if the button doesn't exist. Useful as an auto button.
- `["random", [action1, action2, ...]]`: Run one of the given actions at random.
- `["when", cond, actions]`: If `cond` evaluates to true, run the given actions.
- `["ite", cond, actions1, actions2]`: If `cond` evaluates to true, run `actions1`, otherwise run `actions2`.
- `["when_anyone", cond, actions]`: For each player, if `cond` evaluates to true for that player, run the given actions for that player.
- `["when_everyone", cond, actions]`: If `cond` evaluates to true for every player, run the given actions for the current player.
- Hardcoded actions that involve selecting tiles (used in sakicards):
  + `["swap_hand_tile_with_same_suit_discard"]`
  + `["swap_hand_tile_with_last_discard"]`
  + `["place_4_tiles_at_end_of_live_wall"]`
  + `["set_aside_discard_matching_called_tile"]`
  + `["set_aside_own_discard"]`
  + `["pon_discarded_red_dragon"]`
  + `["draw_and_place_2_tiles_at_end_of_dead_wall"]`
  + `["about_to_draw"]`: no-op
  + `["about_to_ron"]`: no-op
- `["set_tile_alias", from, to]`: Assigns all tiles in `from` to tiles in `to` for the current player. Basically if `from` is a single tile, then that tile becomes a joker whose possible values are the tiles in `to`, and this only applies to the current player.
- `["set_tile_alias_all", from, to]`: Same, but applies this assignment to all players.
- `["set_tile_ordering", [tile1, tile2, ...]]`: Asserts that `tile1` comes after `tile2` and so on. Applies only to the current player.
- `["set_tile_ordering_all", [tile1, tile2, ...]]`: Same, but applies this assertion to all players.
- `["tag_drawn_tile", tag_name]`: Globally tag the current player's drawn tile with the given tag name.
- `["untag", tag_name]`: Untag all tiles tagged with the given tag name.
- `["convert_last_discard", tile]`: Turn the last discard into the given tile.
- `["set_aside_draw"]`: Set aside the drawn tile.
- `["draw_from_aside"]`: Draw a tile from the tiles set aside.
- `["swap_tile_with_aside"]`: Swap a selected tile with the first tile set aside.
- `["charleston_left"]`: Select and pass three tiles left.
- `["charleston_across"]`: Select and pass three tiles across.
- `["charleston_right"]`: Select and pass three tiles right.
- `["shift_dead_wall_index", num]`: Add `num` tiles to the dead wall from the live wall. (The haitei tile becomes a dead wall tile.)
- `["add_counter", counter_name, amount or spec, ...opts]`: Add `amount` to the current player's counter `counter_name`. In place of `amount` you can also put one of the following strings followed by some options:
  + `"count_matches", to_match, [match_spec1, match_spec2, ...]` Counts the number of times the given match specs matches `to_match`, and adds that to the counter. The syntax for these options is the same as the options for the `match` condition, which is described in the match condition section.
- `["add_attr_last_discard", attr1, attr2, ...]`: Add the given attributes to the last discard
- `["add_attr_drawn_tile", attr1, attr2, ...]`: Add the given attributes to all drawn tiles for the current player.
- `["remove_attr_all", attr1, attr2, ...]`: Remove the given attributes from all tiles owned by the current player (hand, draw, aside, but not calls)

# Conditions

Prepend `"not_"` to any of the condition names to negate it.

- `"true"`: Always true.
- `"false"`: Always false.
- `"our_turn"`: The current turn is ours.
- `"our_turn_is_next"`: The next turn is ours.
- `"our_turn_is_prev"`: The previous turn is ours.
- `"game_start"`: No actions have been performed.
- `"no_discards_yet"`: No discard actions have been performed.
- `"no_calls_yet"`: No call actions have been performed.
- `{"name": "last_call_is", "opts": [call_button_id]}`: The last call, if any, was performed by the given call button id.
- `"kamicha_discarded"`: The last action, if any, was kamicha discarding.
- `"someone_else_just_discarded"`: The last action, if any, was someone else discarding.
- `"just_discarded"`: The last action, if any, was us discarding.
- `"just_called"`: The last action, if any, was us calling.
- `"call_available"`: For call buttons only. The specified call is available.
- `"self_call_available"`: For self call buttons only. The specified self call is available.
- `"can_upgrade_call"`: For upgrade call buttons only. The specified upgrade call is available.
- `"has_draw"`: The current player has drawn a tile.
- `"has_aside"`: The current player has set aside a tile.
- `"has_calls"`: The current player has called tiles.
- `{"name": "has_call_named", "opts": [call1, call2, ...]}`: The current player has one of the specified calls. Example: `{"name": "has_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]}`
- `{"name": "has_no_call_named", "opts": [call1, call2, ...]}`: The current player has none of the specified calls. Example: `{"name": "has_no_call_named", "opts": ["chii", "pon", "daiminkan", "kakan"]}`
- `"won_by_call"`: The winner won by stealing a called tile.
- `"won_by_draw"`: The winner won by drawing the winning tile.
- `"won_by_discard"`: The winner won by stealing the discard tile.
- `{"name": "fu_equals", "opts": [fu]}`: The winning player has the given amount of fu. Valid values of fu are multiples of 10.
- `{"name": "has_yaku_with_hand", "opts": [han, yaku_keys]}`: Using the current player's draw as the winning tile, the current player's hand scores at least `han` points using the yaku in the specified toplevel keys. Example: `{"name": "has_yaku_with_hand", "opts": [1, ["yaku", "yakuman"]]}`
- `{"name": "has_yaku_with_discard", "opts": [han, yaku_keys]}`: Using the last discard as the winning tile, the current player's hand scores at least `han` points using the yaku in the specified toplevel keys. Example: `{"name": "has_yaku_with_discard", "opts": [1, ["yaku", "yakuman"]]}`
- `{"name": "has_yaku_with_call", "opts": [han, yaku_keys]}`: Using the last called tile as the winning tile, the current player's hand scores at least `han` points using the yaku in the specified toplevel keys. Example: `{"name": "has_yaku_with_call", "opts": [1, ["yaku", "yakuman"]]}`
- `{"name": "last_discard_matches", "opts": [tile_spec1, tile_spec2, ...]}`: The last discard matches one of the given tile specs. See the tile specs section for details.
- `{"name": "last_called_tile_matches", "opts": [tile_spec1, tile_spec2, ...]}`: The last called tile matches one of the given tile specs. See the tile specs section for details.
- `{"name": "unneeded_for_hand", "opts": [match_spec1, match_spec2, ...]}`: Only used when a tile is in context, e.g. in `play_restrictions`. The context's tile is not needed for the current player's hand to match one of the given match specifications.
- `"is_drawn_tile`: Only used when a tile is in context, e.g. in `play_restrictions`. The context's tile is a drawn tile.
- `{"name": "status", "opts": [status1, status2, ...]}`: The current player has all of the specified statuses.
- `{"name": "status_missing", "opts": [status1, status2, ...]}`: The current player is missing all of the specified statuses.
- `{"name": "discarder_status", "opts": [status1, status2, ...]}`: The last discarder has all of the specified statuses.
- `{"name": "shimocha_status", "opts": [status1, status2, ...]}`: Shimocha has all of the specified statuses.
- `{"name": "toimen_status", "opts": [status1, status2, ...]}`: Toimen has all of the specified statuses.
- `{"name": "kamicha_status", "opts": [status1, status2, ...]}`: Kamicha has all of the specified statuses.
- `{"name": "others_status", "opts": [status1, status2, ...]}`: Someone else has all of the specified statuses.
- `{"name": "anyone_status", "opts": [status1, status2, ...]}`: Anyone has all of the specified statuses.
- `{"name": "everyone_status", "opts": [status1, status2, ...]}`: Everyone has all of the specified statuses.
- `{"name": "buttons_include", "opts": [button1, button2, ...]}`: All of the specified buttons are showing for the current player.
- `{"name": "buttons_exclude", "opts": [button1, button2, ...]}`: None of the specified buttons are showing for the current player.
- `{"name": "tile_drawn", "opts": [tile1, tile2, ...]}`: All of the given reserved tiles have been drawn.
- `{"name": "tile_not_drawn", "opts": [tile1, tile2, ...]}`: None of the given reserved tiles have been drawn.
- `{"name": "tile_revealed", "opts": [tile1, tile2, ...]}`: All of the given reserved tiles have been revealed above.
- `{"name": "tile_not_revealed", "opts": [tile1, tile2, ...]}`: None of the given reserved tiles have been revealed above.
- `"no_tiles_remaining"`: No tiles remain in the wall.
- `{"name": "tiles_remaining", "opts": [num]}`: At least `num` tiles remain in the wall.
- `"next_draw_possible"`: The player whose turn it is has at least one draw remaining (after their current draw).
- `{"name": "has_score", "opts": [score]}`: The current player has at least `score` score.
- `{"name": "round_wind_is", "opts": [direction]}`: The current round wind is the specified direction, one of `"east"`, `"south"`, `"west"`, `"north"`.
- `{"name": "seat_wind_is", "opts": [direction]}`: The current player's seat wind is the specified direction, one of `"east"`, `"south"`, `"west"`, `"north"`.
- `{"name": "winning_dora_count", "opts": [dora_indicator, num]}`: The current player has `num` dora tiles of the given dora indicator.
- `{"name": "match", "opts": [to_match, [match_spec1, match_spec2, ...]]}`: See the section on match specifications to see how this condition works.
- `{"name": "winning_hand_consists_of", "opts": [tile1, tile2, ...]}`: The winning hand (excluding winning tile) contains only the given tiles (jokers allowed).
- `{"name": "winning_hand_and_tile_consists_of", "opts": [tile1, tile2, ...]}`: The winning hand (including winning tile) contains only the given tiles (jokers allowed).
- `"all_saki_cards_drafted"`: Everyone has at least one saki card.
- `{"name": "has_existing_yaku", "opts": [yaku1, yaku2, ...]}`: Used in `meta_yaku` only. The winner has scored all of the given yaku.
- `"has_no_yaku"`: Used in `meta_yaku` only. The winner has scored no yaku.
- `"placement"`: The current player has the given placement (1-4).
- `"last_discard_matches_existing"`: The last discarded tile matches one of the current player's existing discards (includes called discards) (uses jokers).
- `"called_tile_matches_any_discard"`: The last called tile matches one of anybody's existing discards (excludes called discards) (uses jokers).
- `"last_discard_exists"`: The last discarded tile was not taken by another player.
- `"first_time_finished_second_row_discards"`: Someone's last discard just finished off their second row of discards.
- `{"name": "call_would_change_waits", "opts": [match_spec1, match_spec2, ...]}`: For call buttons' `show_when` key only. The given call would change the waits of the current player, where a winning hand is defined by the given match definitions.
- `{"name": "call_changes_waits", "opts": [match_spec1, match_spec2, ...]}`: For call buttons' `call_conditions` key only. The given call changes the waits of the current player, where a winning hand is defined by the given match definitions.
- `{"name": "wait_count_at_least", "opts": [num, [match_spec1, match_spec2, ...]]}`: The number of tiles the current player is waiting on is at least `num`, where a winning hand is defined by the given match definitions.
- `{"name": "wait_count_at_most", "opts": [num, [match_spec1, match_spec2, ...]]}`: The number of tiles the current player is waiting on is at most `num`, where a winning hand is defined by the given match definitions.
- `{"name": "call_contains", "opts": [[tile1, tile2, ...], num]}`: For call buttons only. The call contains at least `num` of any of the given tiles.
- `{"name": "called_tile_contains", "opts": [[tile1, tile2, ...], num]}`: For call buttons only. The called tile contains at least `num` of any of the given tiles. (only num=1 is valid)
- `{"name": "call_choice_contains", "opts": [[tile1, tile2, ...], num]}`: For call buttons only. The tiles used to call contains at least `num` of any of the given tiles.
- `{"name": "tagged", "opts": [tile, tag_name]}`: The given tile is tagged with the given `tag_name`. Valid values for `tile` are: `"last_discard"`, `"tile"`, where the last one uses the tile in context (and therefore is only valid in places like `play_restrictions`)
- `{"name": "has_hell_wait", "opts": [match_spec1, match_spec2, ...]}`: The current player is waiting on a single out, where a winning hand is defined by the given match definitions.
- `"third_row_discard"`: The current player has at least 12 tiles in their pond.
- `{"name": "tiles_in_hand", "opts": [num]}`: The current player has `num` tiles in hand.
- `{"name": "anyone", "opts": [cond1, cond2, ...]}`: Anyone satisfies the given conditions.
- `{"name": "counter_equals", "opts": [counter_name, amount]}`: The counter `counter_name` equals `amount`.
- `{"name": "counter_at_least", "opts": [counter_name, amount]}`: The counter `counter_name` is at least `amount`.
- `{"name": "counter_at_most", "opts": [counter_name, amount]}`: The counter `counter_name` is at most `amount`.
- `{"name": "has_attr", "opts": [tile, attr1, attr2]}`: The given tile is has the given attributes `attr1`, `attr2`, etc. Valid values for `tile` are: `"last_discard"`, `"tile"`, where the last one uses the tile in context (and therefore is only valid in places like `play_restrictions`)

# Tile specs

- `"any"`: Matches any tile.
- `"1z"`, `"3m"`, etc: Matches that exact tile.
- `"same"`: Matches the same tile. Only used in `play_restrictions` for the `last_discard_matches` or `last_called_tile_matches` conditions.
- `"not_same"`: Matches a different tile. Only used in `play_restrictions` for the `last_discard_matches` or `last_called_tile_matches` conditions.
- `"manzu"`: Matches a manzu tile (hardcoded).
- `"pinzu"`: Matches a pinzu tile (hardcoded).
- `"souzu"`: Matches a souzu tile (hardcoded).
- `"jihai"`: Matches a honor tile (hardcoded).
- `"terminal"`: Matches a terminal tile (hardcoded).
- `"yaochuuhai"`: Matches a terminal/honor tile (hardcoded).
- `"flower"`: Matches a flower tile (hardcoded).
- `"joker"`: Matches a joker tile (hardcoded).
- `"1"` to `"9"`: Matches that number tile (hardcoded).
- `"not_kuikae"`: Matches a tile that is not kuikae to the last call. Only used in `play_restrictions`.

# Scoring methods

Scoring refers to the exchange of points after a win or a draw. To enable scoring, the `"score_calculation"` key must exist and be associated with an object with a `"method"` key. Scoring will be performed based on this `"method"` key. Here are the currently supported options for `"method"`:

## `"method": "riichi"`

Once a win action is triggered (`"win_by_discard"`, `"win_by_call"`, or `"win_by_draw"`) the game generates a win for each player that triggered a win action.

This method enables fu calculations for a winning hand. Fu calculation is currently hardcoded and cannot be customized, but this is subject to change.

In the event of an exhaustive draw, this method looks for the status `"tenpai"` among all existing players. (This means you will have to set and unset tenpai status through the course of the game.) All `"tenpai"` players will pay the non-`"tenpai"` players according to the rules of riichi. That is, unless any player has the status `"nagashi"`, in which case they get nagashi payments.

## `"method": "hk"`

Once a win action is triggered (`"win_by_discard"`, `"win_by_call"`, or `"win_by_draw"`) the game generates a win for each player that triggered a win action.

All players pay for a win -- the discarder pays double.

## `"method": "sichuan"`

Currently does the same as `hk` except only the discarder pays in case of a win by discard.

## `"method": "vietnamese"`

This is the same as `"method": "riichi"` but it does not calculate fu. Instead it uses the `"yaku"` key to calculate Phán and the `"yakuman" key to calculate Mủn. Also, there are no tenpai payments.

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
