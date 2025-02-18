# Contributing to Riichi Advanced

First of all, join the Discord! <https://discord.gg/5QQHmZQavP>

There isn't currently a structured way to contribute to this codebase, but if that ever happens I'll update this document with that.

Right now Riichi Advanced has a couple avenues for contribution:

## Issues

You could check out the [issues](https://github.com/EpicOrange/riichi_advanced/issues) and specifically look for issues labeled `tanyao level issue`. These are issues that should be relatively easy to complete. (Tanyao is the common name for the "All Simples" win condition in Riichi Mahjong.)

There's no requirement for pull requests. I guess you should probably at least mention what issue you're addressing, but since we don't have great test coverage or CI or anything at the moment, you can just go ahead and submit PRs as you like.

## Quality assurance

Riichi Advanced does not have good test coverage, and more importantly, we're not 100% sure about certain rules. If you know a mahjong variant quite well, definitely try it out on Riichi Advanced and see if it matches your expectations! If not, open an [issue](https://github.com/EpicOrange/riichi_advanced/issues) or drop us a message on the [Discord](https://discord.gg/5QQHmZQavP), preferably with a screenshot.

One way Riichi Advanced facilitates testing is letting you rig the wall in all variants: when in a room, hit Room Settings and then Config, and uncomment the lines in the textbox. You can also add `"debug_status": true` to show statuses, counters, and buttons for all players. Also, the Open Hands mod could be helpful.

## Ruleset tutorials

Riichi Advanced supports custom tutorials, and the documentation for that is available [here](documentation/tutorials.md). To start, navigate to the [main menu](https://riichiadvanced.com), select a variant, press Learn, press Create your own ruleset, and start writing! To share your tutorials, simply copy the URL when playing said tutorial.

Note that these shared tutorials are only stored temporarily. If you end up creating a custom tutorial that you want to add to the game, drop it in [Discord](https://discord.gg/5QQHmZQavP) or submit a pull request! All in-game tutorials are stored in the directory [`priv/static/tutorials/`](priv/static/tutorials/).

## Ruleset documentation

In order to implement mahjong variants we need a good source of rules (preferably in English). You can contribute by sending us rulesets for your favorite mahjong from any source, including yourself! Just drop it in [Discord](https://discord.gg/5QQHmZQavP) or post an issue or open a PR adding it to the toplevel `documentation/` directory.

## Ruleset JSONs and mods

We have a number of existing rulesets without an implementation in JSON. You can help contribute!

- First, familiarize yourself with the [JSON documentation](documentation/documentation.md) .
- Next, look at [`priv/static/rulesets/`](priv/static/rulesets/) to see a couple of examples of rulesets.
- Then feel free to copy one of the rulesets and modify it as you wish!

There's also [`priv/static/mods/`](priv/static/mods/) -- if you want to create a mod, here are the steps:

- All mods are written in [`jq`](https://jqlang.org/), a language for editing JSON. Therefore you'll need some knowledge of `jq`.
- Check out some existing mods in [`priv/static/mods/`](priv/static/mods/).
- Look at the top of [`priv/static/rulesets/riichi.json`](priv/static/rulesets/riichi.json) to see how to make mods available for a given ruleset.

Currently some rulesets are actually modpacks, modded derivatives of existing rulesets (mostly Riichi), and those can be found [here](lib/riichi_advanced/game/mod_loader.ex#L48). The location of these modpack definitions may change in the future.

## Tests

Although writing tests requires some knowledge of Elixir, we still need ideas for what scenarios to test, and that's where you could come in!

## Marketing

Spread the word!
