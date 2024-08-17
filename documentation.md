# `rules.json` documentation

The entire file should be an object with at least the following required keys:

- ""

The following keys are optional:

- ""

Each section of this guide will detail the function of each key mentioned above.

## TODO





















# Game loop

Here's how the game loop functions:

At the very start, `["change_turn", "east"]` is run. This triggers turn change actions (e.g. drawing a tile) which essentially sets up the game.

Then we wait for a player to make a choice. A choice is defined as the following:

- Clicking a tile -> if it's your turn, your choice is `"play_tile"`.
- Clicking a button -> if you have that button, your choice is that button's name.
- Skipping a button -> your choice is "skip".

Every choice has a list of actions associated with it.

- Clicking a tile -> "play_tile" action with the index of the tile played, followed by "advance_turn"
- Clicking a button -> listed in the "actions" key of the button.
- Skipping a button -> Empty list.

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
Any action (except those in the "uninterruptible_actions" key of the rules) can be interrupted given the right conditions.
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

Because of this interrupt system, it is useful to add certain actions to the "uninterruptible_actions" array.
For example, "big_text" merely shows big text, and thus there is no need to react to it even if buttons can be shown afterwards.








## Auto buttons

Auto buttons are triggered on the following:

- Upon toggling them on,
- After running any set of actions (e.g. `"advance_turn"`)

Note that auto buttons might click buttons or play tiles, forcing a choice to be made.





