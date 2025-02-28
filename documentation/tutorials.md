# How to write a tutorial sequence for Riichi Advanced

When a player selects a tutorial sequence for a given ruleset, they are taken to a tutorial whose contents are wholly determined by a given JSON file.

Like for rulesets, the JSON file defining a tutorial sequence consists of a single object. Unlike rulesets, there are only three keys you must define:

- `"mods"`: An array of mods applied to the base ruleset (these are applied in order).
- `"config"`: An object to be merged with the ruleset after applying all the mods. (Same effect as the config tab when changing game settings.)
- `"scenes"`: An object whose keys are scene names and whose values are arrays of tutorial actions. The `"start"` key is required for this object. We'll go over this.

The first two keys are actually optional, and default to empty list and empty object respectively.

For technical reasons, the base ruleset and the player's starting seat are determined outside of this JSON.

## Starting with an example tutorial

Let's say we're writing a riichi tutorial for the base riichi ruleset. The tutorial is to show how to declare riichi and win with double riichi ippatsu tsumo. Here's how we could start:

    {
      "mods": [{"name": "yaku/riichi", "config": {"bet": 1000, "drawless": false}}, "yaku/ippatsu", "show_waits"],
      "config": {
        "starting_hand": {
          "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "7s", "8s", "8s", "1z"],
          "south": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "west": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "north": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"]
        },
        "starting_draws": ["6s", "1z", "2z", "3z", "5s"],
        "tsumogiri_bots": true
      },
      "scenes": {
        "start": []
      }
    }

For riichi and ippatsu, we add the `yaku/riichi` and `yaku/ippatsu` mods, as well as the `show_waits` mod to let the player see their waits. You can get the names of these mods by looking at the `"available_mods"` section of a ruleset. These mods will be applied in order -- here we care that `yaku/riichi` is applied before `yaku/ippatsu`, since there is a dependency there.

The `"config"` object is rather important because this is how you set up the conditions for the tutorial. You can see that our hero (`"east"`) starts with a iishanten hand, they just need to draw any of `56789s1z` to achieve tenpai. Using `"starting_draws"`, we make sure their first draw is `"6s"`, and then they will win on `"5s"`.

The other players all have the same random looking hand (also iishanten). They will be manned by bots whose behavior is exactly the same as in a game. Currently the only way to control their behavior is to turn them into tsumogiri bots via the `"tsumogiri_bots"` key, which is sufficient for pretty much every tutorial. Note that tsumogiri bots will still riichi (and discard tedashi if required) if possible. If more control is needed, please [open an issue](https://github.com/EpicOrange/riichi_advanced/issues)!

Finally, the `"scenes"` key starts us off with the required `"start"` scene. No actions have been assigned to it, so in this tutorial precisely nothing can happen, because tutorial mode blocks every user (and bot) action by default. Let's change that.

## Forcing events

The `"start"` scene supplies a list of _tutorial actions_ to be run at the start of the tutorial. Right now we just want our hero to press the Riichi button, and then discard their east wind. Let's figure out how to do that with the `"force_event"` action.

    {
      ...
      "scenes": {
        "start": [
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", ["play_tile", "east", 12]]
        ]
      }
    }

Here we've declared two forced events in sequence: a `"press_button"` event and then a `"play_tile"` event. There are only three possible events you can specify:

- `["play_tile", seat, index]`
- `["press_button", seat, button_name]`
- `["press_call_button", seat, call_choice, called_tile]`: explained later

The game will pause on the first `"force_event"` action until our hero presses Riichi (you must specify the internal name of the button as defined by the ruleset, which for Riichi is `"riichi"`). Then it will do the same until our hero discards their 12th tile from the left (the leftmost tile is the 0th tile). It will block any other player or AI action in the meantime, which is great,

## Awaiting events

until you realize that this is how you must proceed to get to our hero's next turn:

    {
      ...
      "scenes": {
        "start": [
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", ["play_tile", "east", 12]],
          ["force_event", ["play_tile", "south", 13]], // tsumogiri
          ["force_event", ["play_tile", "west", 13]], // tsumogiri
          ["force_event", ["play_tile", "north", 13]] // tsumogiri
        ]
      }
    }

Forcing every action requires you to micromanage the AI's events, which are predetermined anyway since they are tsumogiri bots. If buttons pop up for the AI ("Chii" for example) you will have to force them to press "Skip", too, by forcing `"press_button"` events for the button `"skip"`. Instead of forcing every event, what we really want is to stop blocking events until after the north player plays a tile. For this, we use `"await_event"`:

    {
      ...
      "scenes": {
        "start": [
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", ["play_tile", "east", 12]],
          ["await_event", ["play_tile", "north", 13]] // tsumogiri
        ]
      }
    }

This does exactly that: the tutorial will stop at the `"await_event"` action, allow through any events (from user or AI), until it sees a `["play_tile", "north", 13]` event, at which point it starts blocking events again and resumes after the `"await_event"` action.

Here's our tutorial so far:

    {
      ...
      "scenes": {
        "start": [
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", ["play_tile", "east", 12]],
          ["await_event", ["play_tile", "north", 13]],
          ["force_event", ["press_button", "east", "tsumo"]]
        ]
      }
    }

All this does is force the user to do the actions specified. What about adding actual tutorial elements, like floating text?

## Adding objects

Here's how you might add text to the existing tutorial sequence:

    {
      ...
      "scenes": {
        "start": [
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Let's declare Riichi!"
          }],
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", ["play_tile", "east", 12]],
          ["clear_objects"],
          ["await_event", ["play_tile", "north", 13]],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Win by pressing Tsumo!"
          }],
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"]
        ]
      }
    }

All tutorial objects are added using the following syntax: `["add_object", type, params]`. All tutorial objects are cleared with `["clear_objects"]`. The parameters for the `"text"` object are as follows:

- `"size"`: Font size.
- `"width"`: Width of the text box. The height is determined by the contents.
- `"x"`: The x-position of the upper-left of the text box. 0 = left edge. 17 = right edge.
- `"y"`: The y-position of the upper-left of the text box. 0 = top edge. 17 = bottom edge.

You can provide decimal values for all of these values. Negative values also work, but they're probably not very useful.

Besides text, the only other object type is `"focus"`, which shines a spotlight centered on a given position. For example, maybe we want to highlight the Riichi button, and then the east wind that is to be discarded:

    {
      ...
      "scenes": {
        "start": [
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Let's declare Riichi!"
          }],
          ["add_object", "focus", {"width": 1, "x": 12, "y": "buttons"}],
          ["force_event", ["press_button", "east", "riichi"]],
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Now discard the east wind!"
          }],
          ["add_object", "focus", {"width": 0.75, "hand_index": 12}],
          ["force_event", ["play_tile", "east", 12]],
          ["clear_objects"],
          ["await_event", ["play_tile", "north", 13]],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Win by pressing Tsumo!"
          }],
          ["add_object", "focus", {"width": 1.5, "x": 11.75, "y": "buttons"}],
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"]
        ]
      }
    }

The parameters for `"focus"` are a little more involved than `"text"`. There are three ways to specify where to focus on. First, you can focus on an arbitrary position:

- `["add_object", "focus", {"width": 0.75, "x": 7.5, "y": 10}]`

or you can focus on a specific tile in hand:

- `["add_object", "focus", {"width": 0.75, "hand_index": 12}]`

or set `y` to the level of where the buttons are:

- `["add_object", "focus", {"width": 1.5, "x": 12, "y": "buttons"}]`

Although the first option seems the most flexible, the latter two options are not only simpler but are responsive to mobile positioning, which is behavior that can't be replicated by the first option.

That's all there is to objects: for now, you can only add `"text"` and `"focus"`.

## Exiting

To conclude the tutorial and go back to the tutorial screen, you simply add an `["exit"]` action:

    {
      ...
      "scenes": {
        "start": [
          ...
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Win by pressing Tsumo!"
          }],
          ["exit"]
        ]
      }
    }

Unfortunately, this will kick you out of the tutorial as soon as you press Tsumo. Instead we might want to add a delay.

## Sleeping and awaiting clicks

We can add a `["sleep", milliseconds]` action:

    {
      ...
      "scenes": {
        "start": [
          ...
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"],
          ["sleep", 3000],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "See you!"
          }],
          ["exit"]
        ]
      }
    }

This will wait 3 seconds before displaying "See you!" and kicking you out. Unfortunately, these happen simultaneously, and so the hero will never see "See you!". Perhaps we should wait for them to click before exiting? Here's how that's done with the simple `["await_click"]` action:

    {
      ...
      "scenes": {
        "start": [
          ...
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"],
          ["sleep", 3000],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "See you!\n(Click to exit.)"
          }],
          ["await_click"],
          ["exit"]
        ]
      }
    }

The `["await_click"]` action simply waits to capture a click before continuing. Now it will wait 3 seconds, display "See you! (Click to exit.)", and exit immediately upon a click.

Our tutorial is basically done. Here's the whole thing:

    {
      "mods": [{"name": "yaku/riichi", "config": {"bet": 1000, "drawless": false}}, "yaku/ippatsu", "show_waits"],
      "config": {
        "starting_hand": {
          "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "7s", "8s", "8s", "1z"],
          "south": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "west": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "north": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"]
        },
        "starting_draws": ["6s", "1z", "2z", "3z", "5s"],
        "tsumogiri_bots": true
      },
      "scenes": {
        "start": [
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Let's declare Riichi!"
          }],
          ["add_object", "focus", {"width": 1, "x": 12, "y": "buttons"}],
          ["force_event", ["press_button", "east", "riichi"]],
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Now discard the east wind!"
          }],
          ["add_object", "focus", {"width": 0.75, "hand_index": 12}],
          ["force_event", ["play_tile", "east", 12]],
          ["clear_objects"],
          ["await_event", ["play_tile", "north", 13]],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Win by pressing Tsumo!"
          }],
          ["add_object", "focus", {"width": 1.5, "x": 11.75, "y": "buttons"}],
          ["force_event", ["press_button", "east", "tsumo"]],
          ["clear_objects"],
          ["sleep", 3000],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "See you!\n(Click to exit.)"
          }],
          ["await_click"],
          ["exit"]
        ]
      }
    }

## Call buttons

Earlier we described the kinds of events you can force and await:

- `["play_tile", seat, index]`
- `["press_button", seat, button_name]`
- `["press_call_button", seat, call_choice, called_tile]`: explained later

Now is the 'later' where we explain `"press_call_button"`.

Normally, pressing Chii immediately executes the call. But if you have choices, you get an additional set of buttons that describe your call choices. These are call buttons, and pressing them are events we often need to force via `"force_event"`.

Here are some usage examples:

- `["force_event", ["press_call_button", "east", ["1p", "3p"], "2p"]]`
- `["force_event", ["press_call_button", "north", ["4p", "5p"], "3p"]]`
- `["force_event", ["press_call_button", "west", "cancel"]]`

Basically the syntax is very similar to `"press_button"` but you must pass two additional arguments beyond the seat of the player pressing the call button. The first one is the call choice: which tiles are you using to call? The second one is the called tile, which is often obvious (the last discard) but we'll explain why this needs to be specified soon.

The third example shows you can also specify `"cancel"` to press the Cancel button instead, returning us to our original button menu. This is just like how with `"press_button"` we can specify `"skip"` to press the Skip button.

To summarize, you want one of these:

- `["force_event", ["press_call_button", seat, call choice, called tile]]`
- `["force_event", ["press_call_button", seat, "cancel"]]`

### Purpose of the called tile argument

Call buttons also pop up if you are calling flowers, and have multiple flowers in hand. It will ask you which flower you want to call (since that is important in some variants). In this case you would specify something like the following:

- `["force_event", ["press_call_button", "north", [], "1f"]]`

i.e. for flowers there is no call choice, there is just the called tile, and that is the purpose of the last argument. The reason for this distinction is internal and mostly because the called tile is what's checked for things like chankan.

Another example where you have multiple choices for called tile is when you draw the fourth ![](tiles/3s.svg) and you also have a bamboo joker in hand -- if you want to call an added kan, you would have to specify which of the two tiles you want to add using the called tile argument.

## Multiple scenes

You might have noticed that the entirety of our constructed tutorial takes place in the `"start"` scene. That's because our tutorial is linear, and so we have no need for other scenes. If you want to create a tutorial with branching outcomes, you will need multiple scenes. Here's a brief description how.

By default, the three "wait for something" actions look like this:

- `["await_click"]`
- `["await_event", event]`
- `["force_event", event]`

These actions will wait for the thing to happen before resuming the current scene

Each of these actually accept an additional argument: the name of the scene to jump to.

- `["await_click", scene_name]`
- `["await_event", event, scene_name]`
- `["force_event", event, scene_name]`

This will abort the current scene and jump to the specified scene. You can define scene names and their corresponding actions as additional entries in `"scenes"`.

Okay, but what about branching? To allow for multiple possible events, you can use the following syntax, which is the full syntax for these two actions:

- `["await_event", events, scene_names]`
- `["force_event", events, scene_names]`

In other words, you can pass an array of events to `"await_event"` or `"force_event"` to allow any of the given choices. This will jump to the corresponding scene. That's all there is to it

Note that you can omit `scene_names` here to get the original "resume scene" behavior, allowing the hero to select one of multiple events to continue.

Finally, `["play_scene", scene_name]` will unconditionally jump to the given scene.

Here's an example tutorial sequence making use of branching:

    {
      "mods": [{"name": "yaku/riichi", "config": {"bet": 1000, "drawless": false}}, "yaku/ippatsu", "show_waits"],
      "config": {
        "starting_hand": {
          "east": ["2p", "3p", "4p", "4p", "5p", "6p", "7p", "7p", "7p", "7s", "8s", "8s", "1z"],
          "south": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "west": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"],
          "north": ["1m", "2m", "3m", "2p", "3p", "8p", "8p", "1s", "2s", "3s", "7s", "8s", "8s"]
        },
        "starting_draws": ["6s", "1z", "2z", "3z", "5s"],
        "tsumogiri_bots": true
      },
      "scenes": {
        "start": [
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Okay, do you go for the wider wait by declaring riichi on the wind, or jump for the funny wind wait by discarding 8 of bamboo?"
          }],
          ["force_event", ["press_button", "east", "riichi"]],
          ["force_event", [["play_tile", "east", 10], ["play_tile", "east", 11], ["play_tile", "east", 12]], ["scene1", "scene1", "scene2"]]
        ],
        "scene1": [
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Yeah, that's what I thought."
          }],
          ["play_scene", "scene3"]
        ],
        "scene2": [
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "No one goes for the meme wait!"
          }],
          ["play_scene", "scene3"]
        ],
        "scene3": [
          ["sleep", 2000],
          ["clear_objects"],
          ["add_object", "text", {"size": 0.4, "width": 5, "x": 10, "y": 10,
            "text": "Click to exit."
          }],
          ["await_click"],
          ["exit"]
        ]
      }
    }
