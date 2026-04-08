# MahjongScript tutorial

Originally, writing a ruleset required knowing the JSON specification for rulesets, and involved a lot of balancing brackets and not forgetting commas. Writing mods requires jq on top of that. MahjongScript was created for the purpose of unifying these tasks in some composable manner, while also avoiding these errors. Based on Elixir syntax, MahjongScript (.majs) is essentially a list of commands which compile down to jq. This jq is then applied to the empty object in order to create a JSON ruleset, or it can be applied to an existing JSON ruleset to mod it.

There are four types of data in MahjongScript:

- [**JSON**](#json): numbers, strings, arrays, and objects
- [**Conditions**](#conditions): conditions with `and`, `or`, `not`
- [**Actions**](#actions): function calls or `do`-blocks containing actions
- [**Sigils**](#sigils): set specifications, match specifications

The entirety of a MahjongScript file is a list of top-level commands that use these data in some way. [A list of commands is provided at the bottom](#all-commands).

## JSON

The following values are JSON:

- Numbers: `42`, `1.5`
- Strings: `"example"`
- Arrays: `["points", 1000]`
- Objects: `%{points: 1000}`

Note that objects differ from typical JSON syntax `{"points": 1000}`. This is a consequence of this language being based on Elixir's map syntax. However, this also means you can declare multiline strings:

```
%{str: """
  This is my multiline string
  The indents before these lines are removed
  since the ending quotes below are indented too
  """}
```

In addition, there is a concept of a numeric "amount". An **amount** is either a number or one of the following strings which translate into some amount:

- the name of a counter
- `"tiles_in_wall"`
- `"num_discards"`
- `"num_aside"`
- `"num_facedown_tiles"`
- `"num_facedown_tiles_others"`
- `"half_score"`
- `"dice"`
- `"pot"`
- `"honba"`
- `"riichi_value"`
- `"honba_value"`
- `"points"`
- `"points2"`
- `"score"`
- `"minipoints"`

## Conditions

Any condition in the [supported list of conditions](./documentation.md#conditions-1) can be written like

```elixir
(our_turn and has_score(1000)) or has_score(0, as: "shimocha")
```

This compiles down to the equivalent bracket-ridden JSON

```json
[[["our_turn", {"name": "has_score", "opts": [1000]}], {"name": "has_score", "as": "shimocha", "opts": [0]}]]
```

You can also write comparisons where the left side is a counter name and the right side is an amount. For example:

```
"my_score" >= 100
```

compiles to `{"name": "counter_at_least", "opts": ["my_score", 100]}`.

Supported comparisons are `==`, `!=`, `<`, `>`, `<=`, `>=`.

### `at_least` and `at_most` conditions

There are special forms `at_least` and `at_most` which can be used like this:

    at_least(2, has_existing_yaku("Riichi"), has_existing_yaku("Tanyao"), has_existing_yaku("Pinfu"))

This is true when at least 2 of the given conditions are true. In general, `at_least(n, cond1, cond2, ...)` is true when at least `n` of the given conditions are true.

There is also `at_most(n, cond1, cond2, ...)` which is similar: it is true when no more than `n` of the given conditions are true, AND at least one of the conditions is true. You can bypass the second check by specifying `true` as one of the conditions, since then one of the conditions is trivially true.

## Actions

Actions are always seen in `do`-blocks. For example you can define a function with a `do`-block:

```elixir
def myfun do
  put_down_riichi_stick
  add_score(-1000)
end
```

This compiles to the JQ

```jq
.functions.myfun = [
  ["put_down_riichi_stick"]
  ["add_score", -1000]
]
```

You can also write the above as a one-liner using semicolons to separate lines:

```elixir
def myfun do put_down_riichi_stick; add_score(-1000) end
```

This works for all `do`-blocks.

You may use any action in the [supported list of actions](./documentation.md#actions). In addition, there is shorthand for some often-used actions:

```elixir
def myfun2 do
  # if-blocks compile down to "when" actions
  if true do
    push_message("Hello world!")
  end

  # if-else-blocks compile down to "ite" actions
  if no_tiles_remaining do
    ryuukyoku
  else
    draw
  end

  # unless-blocks compile down to "unless" actions
  unless no_tiles_remaining do
    draw(1, "opposite_end")
  end

  # cond-blocks compile down to a string of "ite" actions
  cond do
    "x" == 1 -> push_message("case 1, checked first")
    "x" == 2 -> push_message("case 2, checked second")
    "x" == 3 ->
      push_message("case 3")
      push_message("still case 3")
    true     -> push_message("fallback case")
  end

  # as-blocks compile to "as" actions
  as everyone do
    push_message("says hi")
  end
  # you can also use as: (like in conditions)
  push_message("says hi", as: "everyone")

  # this becomes ["set_counter", "counter_name", "score"]
  counter_name = "score"

  # this becomes ["add_counter", "counter_name", 1]
  counter_name += 1
end
```

In addition, you may call any user-defined function:

```elixir
def myfun3 do
  myfun
  myfun2(val: 1)
end
```

This compiles to `[["run", "myfun"], ["run", "myfun2", {"val": 1}]]`

To make a function take parameters like this, simply use the parameter e.g. `"$myparam"` somewhere in the function. Then if a parameter `myparam: 100` is provided, it will replace all instances of `"$myparam"` with `100` before running the function.

```elixir
def myfun3 do
  push_message("has a score of $score!", %{"score": "$myscore"})
end
# elsewhere:
def myfun4 do
  my_score = "score"
  myfun3(score: "my_score")
end
```

## Sigils

Sigils look like `~s"mysigil"`. They're just specially marked strings that expect some special syntax.

### Set sigils

In particular, `~s` specifies a **set** to be used, for example, in the `define_set` command.

```elixir
define_set myset, ~s"0 1 2"
```

This compiles to

```jq
.set_definitions["myset"] = [[0, 1, 2]]
```

A more complex set using all aspects of the set grammar is the following:

```elixir
define_set myset, ~s"0 1 2@myattr&myattr2 | 1z 2z 3z"
```

This compiles to

```jq
.set_definitions["myset"] = [[0, 1, {"offset": 2, "attrs": ["myattr", "myattr2"]}], ["1z", "2z", "3z"]]
```

Sets are mostly used in match definitions, but they are also extensively used in fu calculations.

### Match sigils

`~m` specifies a **match definition**. The most common use for these is in use in the `match` condition:

```elixir
match(["hand", "calls", "winning_tile"], ~m"exhaustive, iipeikou:1, mentsu:2, pair:1")
```

This compiles to

```json
{"name": "match", "opts": [
  ["hand", "calls", "winning_tile"],
  [["exhaustive", [["iipeikou"], 1], [["mentsu"], 2], [["pair"], 2]]]
]}
```

Another example:

```elixir
match(["hand", "calls", "winning_tile"], ~m"(haku hatsu chun):2, (haku_pair hatsu_pair chun_pair):1 | (haku hatsu chun):3")
```

This compiles to

```json
{"name": "match", "opts": [
  ["hand", "calls", "winning_tile"],
  [
    [[["haku", "hatsu", "chun"], 2], [["haku_pair", "hatsu_pair", "chun_pair"], 1]],
    [[["haku", "hatsu", "chun"], 3]]
  ]
]}
```

### Tile sigils

`~t"111m222p333s@attribute"` and `~T"11m 12m 13m@attribute"` are both ways to specify tiles. The lowercase `~t` lets you specify an array of tiles using the standard mahjong compact format. The uppercase `~t` lets you specify any of Riichi Advanced's extended tiles (see [tiles.md](./tiles.md)).

```elixir
~t"111m222p333s@attribute"
# compiles to [
#   "1m","1m","1m","2p","2p","2p",
#   {tile: "3s", attrs: ["attribute"]},
#   {tile: "3s", attrs: ["attribute"]},
#   {tile: "3s", attrs: ["attribute"]}
# ]

~T"11m 12m 13m@attr1&attr2"
# compiles to [
#   "11m", "12m",
#   {tile: "13m", attrs: ["attr1", "attr2"]}
# ]
```

Tile sigils are basically only used for interpolation into rules text and for rigging the hand/wall. In the future it will also be used to interpolate into messages.

```elixir
on after_initialization do
  add_rule("2 Han", "Honitsu", "%{example_hand}", %{example_hand: ~t"123345888p11z22z 2z"})
end
set starting_hand, %{east: ~t"19m19p19s1234567z"}
set starting_draws, ~T"45m@_rainbow&_anim&_dora"
```

## Constants

Consider the following snippet from the Sichuan Bloody ruleset (`sichuan.majs`):

```elixir
define_button pon,
  ...
  call_conditions:
       (status("void_manzu") and not_call_contains(["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m"], 1))
    or (status("void_pinzu") and not_call_contains(["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p"], 1))
    or (status("void_souzu") and not_call_contains(["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"], 1)),
  ...

define_button daiminkan,
  ...
  call_conditions:
       (status("void_manzu") and not_call_contains(["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m"], 1))
    or (status("void_pinzu") and not_call_contains(["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p"], 1))
    or (status("void_souzu") and not_call_contains(["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"], 1)),
  ...
  
define_button ankan,
  ...
  call_conditions:
       (status("void_manzu") and not_call_contains(["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m"], 1))
    or (status("void_pinzu") and not_call_contains(["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p"], 1))
    or (status("void_souzu") and not_call_contains(["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"], 1)),
  ...
  
define_button kakan,
  ...
  call_conditions:
       (status("void_manzu") and not_call_contains(["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m"], 1))
    or (status("void_pinzu") and not_call_contains(["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p"], 1))
    or (status("void_souzu") and not_call_contains(["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"], 1)),
  ...
```

To avoid repeating code, the command `define_const` can be used to define constants. Constants can hold any MahjongScript data type, including do-blocks of actions! So the above becomes:

```elixir
define_const no_voided_calls,
     (status("void_manzu") and not_call_contains(["1m", "2m", "3m", "4m", "5m", "6m", "7m", "8m", "9m"], 1))
  or (status("void_pinzu") and not_call_contains(["1p", "2p", "3p", "4p", "5p", "6p", "7p", "8p", "9p"], 1))
  or (status("void_souzu") and not_call_contains(["1s", "2s", "3s", "4s", "5s", "6s", "7s", "8s", "9s"], 1))

define_button pon,
  ...
  call_conditions: @no_voided_calls,
  ...

define_button daiminkan,
  ...
  call_conditions: @no_voided_calls,
  ...
  
define_button ankan,
  ...
  call_conditions: @no_voided_calls,
  ...
  
define_button kakan,
  ...
  call_conditions: @no_voided_calls,
  ...
```

Constants are referenced with the `@` symbol. The underlying mechanism is that each reference to a constant is replaced by the string `"@my_constant"`, and the engine walks through the entire JSON, replacing instances of `"@my_constant"` with its corresponding value.

When writing mods, you can extend the item at the path `"constants.my_constant"` using the `apply` command, for example:

```elixir
# from the ruleset
define_const always_yakuhai, ["5z", "6z", "7z"]

# from the mod
apply append, "constants.always_yakuhai", "4z"
```

Since constants are expanded at runtime, one way to configure behavior is to put your configurable condition or action into a constant, and have mods modify or replace the constant. For instance:

```elixir
define_const closed_hand, has_no_call_named("chii", "pon", "daiminkan", "kakan")
# but in cosmic riichi:
define_const closed_hand, has_no_call_named("ton", "chii", "chon", "chon_honors", "daiminfuun", "pon", "daiminkan", "kapon", "kakakan", "kafuun", "kakan")
# all instances of @closed_hand will now use the latest definition
```

For security reasons, constant names cannot contain uppercase letters.

## Advanced: Splatted constants

Consider the following:

```elixir
define_const can_chankan, status("can_chankan", as: "caller")
define_button chankan,
  display_name: "Ron",
  show_when: not_our_turn
    and someone_else_just_called
    and status_missing("furiten", "just_reached")
    and +@can_chankan
    and match(["hand", "calls"], ["tenpai"])
    and match(["hand", "calls", "last_called_tile"], ["win"]),
  ...
```

The idea is that one of the conditions in `show_when` has been factored out as a constant, so that the Kokushi Ankan Chankan mod can just modify that constant, instead of modifying every button. Since conditions are internally represented by a list `[cond1, cond2, ...]`, the constant `@can_chankan` is actually internally an array `[{"name": "status", "as": "caller", "opts": ["can_chankan"]}]`. Replacing it directly would result in something like `[cond1, cond2, [{"name": "status", "as": "caller", "opts": ["can_chankan"]}], ...]` -- turning it into an OR condition, which may be undesirable.

The prefix `+@` solves this by "splatting" the constant. That is, whenever the splatted constant reference appears inside an array, it injects its contents directly into the surrounding array.

You can splat conditions and even do-blocks, since both are represented internally as arrays.

## Variables

The user of a .majs mod (e.g. a ruleset) can pass variables into it. For instance, the Tobi mod accepts a `below` variable specifying the minimum score a player can have.

Variables are referenced by prepending with `!`. Here's the Tobi mod:

```elixir
apply set, "score_calculation.tobi", !below
```

For security reasons, variables cannot contain uppercase letters.

## Toplevel `if` (Conditional compilation)

You can also write conditionals at the top-level, for example:

```elixir
if !min == "Mangan" do
  ...
end
```

This runs the commands inside the if the variable `min` is set to `"Mangan"`. You can also do `if`-`else`-`end` and `unless`-`end`, but not `cond`. The allowable operators within the condition itself are as follows:

- Any variable `!variable`
- `l == r` or `equals(l, r)`: Check equality
- `l in r`: Check if `l` is an element of array `r`
- `not cond`: Logical NOT (negates `cond`)
- `l and r`: Logical AND (true if `l`,`r` are both true)
- `l or r`: Logical OR (true if one of `l`,`r` is true)
- `true`: Always true
- `false`: Always false
- `defined("foo")`: See below

## `define` (C `#ifdef`-like functionality)

This is meant to be used when multiple mods define the same things, but you only want it to be defined once. Here's the basic example:

```elixir
unless defined("pao") do
  define "pao"

  on before_win do
    ...
  end
  ...

end
```

Essentially this means that only the first mod that hits this top-level conditional will evaluate the commands inside of it, since `"pao"` will be set thereafter.

These `define`s only work for MahjongScript mods, so if you put `define`s in a `majs` ruleset, they will not transfer to mods. If you want to condition mod evaluation based on stuff in a ruleset, you will probably want to define a variable instead.

# Command Reference

A reference cheatsheet for all of the following commands appears at the [bottom of this page.](#all-commands)

### `def`: Function definition

```elixir
def my_function_name do
  action1
  action2
  if condition do
    action3
  else
    action4
  end

  unless condition2 do
    action5
  end

  as everyone do
    action6
  end
end
```

The above showcases all the special forms: `if/do/end` and `if/do/else/end` is are typical conditionals, `unless` is like `if` but inverts its condition, and `as` lets you switch the current player (and sort of serves as a loop, if multiple players are specified).

### `set`: Set any toplevel parameter

```elixir
set initial_points, 25000
```

To set (or otherwise modify) arbitrary paths, see `apply` below.

### `on`: Add a new handler for an event

```elixir
# append to list of existing handlers
on before_win do
  actions
end

# prepend to list of existing handlers
on before_win, prepend: true do
  actions
end
```

`on` can be used to append or prepend to the list of existing handlers. In the above example, the second handler will run before the first handler.

### `define_set`: Define a set for reference in matches

```elixir
define_set pair ~s"0 0"
```

This command can only take set sigils (see above).

Defined sets are used in match sigils.

### `define_match`: Define a match for reference in the `match` condition

```elixir
define_match mymatch1, ~m"pair:7"
define_match mymatch2, ~a"FF XXXX0a NEWS XXXX0b"
define_match mymatch3, "existing_match_1", "existing_match_2"
```

This command can only take match sigils (see above). You may specify multiple match sigils, separated by commas -- it will act as an OR of the given matches.

```elixir
define_match mymatch1, ~m"pair:7", ~a"FF XXXX0a NEWS XXXX0b"
```

After defining them, you may use these match definitions by referencing them in the `match` condition:

```elixir
# mymatch1 OR mymatch2
match(["hand", "calls", "winning_tile"], ["mymatch1", "mymatch2"])
```

Note that you can directly pass in a match sigil to `match`, so `define_match` is simply a convenience command.

```elixir
match(["hand", "calls", "winning_tile"], ~m"pair:7")
```

### `extend_match`: Extend an existing match

Same syntax and function as `define_match`, but if the match exists, it will extend the match with the given match definitions.

```elixir
define_match mymatch, ~m"mentsu:4, pair:1"
extend_match mymatch, ~m"pair:7"
```

is the same as

```elixir
define_match mymatch, ~m"mentsu:4, pair:1", ~m"pair:7"
```

### `define_const`: Define a constant JSON value that can be referenced later in actions

```elixir
# arbitrary json
define_const foo, "asdf"
def bar do
  print(@foo) # prints "asdf"
end

# sigils
define_const bar, ~m"pair:7"

# conditions
define_const bar, match(["hand", "calls", "winning_tile"], ~m"pair:7")

# do-blocks
define_const baz do # note the lack of comma before do
  action1
  action2
end
```

See the [explanation of constants above](#constants).

### `define_yaku`: Add a new yaku

```elixir
define_yaku list_name, display_name, value, condition
```

If you define a yaku with the same `display_name` of an existing yaku, then obtaining both yaku adds the value of both yakus.

After the condition you may optionally specify a list of yaku names as shorthand for the below:

```elixir
define_yaku list_name, display_name, value, condition, supercedes_list
# is the same as
define_yaku list_name, display_name, value, condition
define_yaku_precedence display_name, supercedes_list
```

### `define_yaku_precedence`: Define precedence for a given yaku

```elixir
define_yaku_precedence "Daisangen", ["Shousangen", "Haku", "Hatsu", "Chun"]
define_yaku_precedence "Renhou", [1,2,3,4]
```

You may specify a list of yaku `display_name`s that the given yaku overrides. This means whenever the given yaku on the left is awarded, it erases all of the overridden yaku on the right. You can also have it override itself, effectively making it so the yaku only exists to override other yaku.

You can also specify a list of numbers -- this specifies all yaku of a given value. You can also mix `display_name`s and numbers.

### `remove_yaku`: Remove all instances of a given yaku by name

```elixir
remove_yaku yaku_list, name
remove_yaku yaku_list, [name1, name2]
```

### `replace_yaku`: Replace all instances of a yaku with a new definition

```elixir
replace_yaku list_name, display_name, value, condition, optional_supercedes_list
```

This is essentially the same as `remove_yaku display_name` followed by `define_yaku`, except it will do nothing if the yaku doesn't exist in the first place.

### `define_button`: Add a new button

```elixir
define_button id,
  display_name: display_name,
  show_when: condition,
  precedence_over: list_of_ids,
  unskippable: false,
  cancellable: false
  do
    actions
  end
```

Note that any existing button of the same `id` will be overwritten. See the button documentation in the [main documentation](./documentation.md#the-define-button-command).

### `define_auto_button`: Add a new auto button

```elixir
define_auto_button id,
  display_name: display_name,
  desc: string,
  enabled_at_start: false
  do
    actions
  end
```

Note that any existing auto button of the same `id` will be overwritten. See the auto buttons documentation in the [main documentation](./documentation.md#the-define-auto-button-command).

### `define_mod_category`: Add a mod category

```elixir
# append a mod category to the list
define_mod_category "Other"

# prepend a mod category to the list
define_mod_category "Rules", prepend: true
```

You can have multiple instances of a category, but this is largely useless since `define_mod` below only adds to the first instance.

See [mods.md](./mods.md) to see how this all works.

### `define_mod`: Add a new mod

```elixir
define_mod id,
  name: string,
  desc: string,
  default: false,
  order: 0,
  deps: list of ids,
  conflicts: list of ids
  category: name
```

Note that if `category` is not specified, the mod is simply appended to the end of the mod list.

See [mods.md](./mods.md) to see how this all works.

### `config_mod`: Add a new config option to a given mod

```elixir
config_mod id,
  name: config name,
  values: ["Mangan", "Yakuman"],
  default: "Yakuman"
```

See [mods.md](./mods.md) to see how this all works.

### `remove_mod`: Delete mods by id

```elixir
remove_mod id
remove_mod id1, id2, id2
```

### `define_play_restriction`: Add a restriction on playing tiles

Here's how it's used for kuikae:

```elixir
define_play_restriction "any", just_called and last_called_tile_matches("kuikae")
```

After just declaring riichi, this prevents playing any tile that gets you out of tenpai:

```elixir
define_play_restriction "any", status("riichi") and status_missing("just_reached") and not_is_drawn_tile
define_play_restriction "any", status("riichi", "just_reached") and needed_for_hand("tenpai")
```

This example forbids discarding flowers when you have the status `"cannot_discard_flowers"`:

```elixir
define_play_restriction "flower", status("cannot_discard_flowers")
```

### `define_play_effect`: Run actions after a tile is played

`define_play_effect` works similarly to an event handler. It looks like

```
define_play_effect flower do
  push_message("played a flower")
end
```

The argument `flower` is a tile spec that restricts which kinds of tiles to run on, in this case flower tiles. If you want this to run on every tile, specify `any`. See [the documentation on tile specs](./documentation.md#tile-specs) for all other options.

### (advanced) `apply`: Modify any path

```elixir
# add to an existing path
apply add, "initial_points", 5000

# set values at arbitrary paths
apply set, "score_calculation.tenpairenchan", true

# append to a function
apply append, "functions.myfunc" do
  as everyone do
    add_score(1000)
  end
end
```

The allowed methods for `apply <method>` are:

- `"set"`: set the value at the given path.
- `"initialize"`: set the value at the given path, but only if it doesn't exist
- `"add"`: add a numeric value.
- `"prepend"`: prepend an element or an array to an array.
- `"append"`: append an element or an array to an array, or create the array if it doesn't exist.
- `"merge"`: merge an object to an existing object.
- `"subtract"`: subtract a numeric value.
- `"delete"`: remove an element or an array of elements from an array.
- `"multiply"`: multiply a numeric value.
- `"deep_merge"`: merge an object to an existing object, and merge shared keys recursively.
- `"divide"`: divide a numeric value.
- `"modulo"`: modulo a numeric value.
- `"delete_key"`: remove a key or an array of keys from an object. (specify keys as strings)
- any of the following C binary numeric operations theoretically work too: `"atan2", "copysign", "drem", "fdim", "fmax", "fmin", "fmod", "frexp", "hypot", "jn", "ldexp", "modf", "nextafter", "nexttoward", "pow", "remainder", "scalb", "scalbln", "yn"`

If the parent node for the given path doesn't exist, the command does nothing (with the exception of `apply initialize` or `apply set`, in which case the path is created). You can also make an exception for this by prepending `set_` to the method, such as `apply set_append` -- this will `append` but default to `set` if the path doesn't exist.

The path syntax is simple: it's `.key` to access a key and `[0]` to access the first element of an array. e.g. `toplevel_key.some_key[1]`.

### (advanced) `replace all`: Replace all nodes under a path

```elixir
replace all, "", ["pon"], ["pon", "daiminkan", "kakan"]

replace all, "available_mods",
  %{type: "dropdown", name: "below", values: [0, 1, 1000, 1001]},
  %{type: "dropdown", name: "below", values: [0, 1, 1000, 1001], default: 1}
```

Essentially: given a path and two values `from` and `to`, look at all subnodes of the given `path` and replace all instances of `from` with `to`.

### (advanced) `define_preset`: Add a new mod preset

```elixir
define_preset "Mahjong Soul", [
  "riichi_kan",
  %{name: "honba", config: %{value: 100}},
  %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
  %{name: "nagashi", config: %{is: "Mangan"}},
  %{name: "tobi", config: %{below: 0}},
  %{name: "uma", config: %{_1st: 10, _2nd: 5, _3rd: -5, _4th: -10}},
  "agarirenchan",
  ...
]
```

# All commands

Here is a cheatsheet for all the commands that exist.

**Defining actions**

- `def fn_name do <actions> end`: Defines a new callable function `fn_name` with actions `<actions>`, or overwrites an existing one. You may then use `fn_name` as an action to call it. Later mods can extend this function via `apply append, "functions.fn_name" do <actions> end`.
- `on before_win do <actions> end`: Defines a new handler for the event `before_win`. This means `<actions>` will run after all existing event handlers.
  + `on before_win, prepend: true do <actions> end`: Same, but `<actions>` run _before_ all existing event handlers.
- `define_play_effect <tile_spec> do <actions> end`: Defines `<actions>` to run immediately after playing a tile matching the tile spec `<tile_spec`>. [List of all tile specs.](./documentation.md#tile-specs)

**Setting variables**

- `set win_timer, 30`: Sets the top-level JSON key `win_timer` to a specific value (`30`).
- `define_set shuntsu, ~s"0 1 2"`: Defines `shuntsu` to refer to the set `0 1 2`. This allows any match specification to mention `shuntsu`, e.g. `~m"shuntsu:4"`
- `define_match win, ~m"(shuntsu koutsu):4 pair:1"`: Defines `win` as the match specification given by `<match>`. Note that AI bots will use the match definition named `win` when making decisions.
- `define_const always_yakuhai, ["5z", "6z", "7z"]`: Define the constant `@always_yakuhai`. At load time, all instances of `@always_yakuhai` will be replaced with `["5z", "6z", "7z"]`, and all instances of `+@always_yakuhai` in an array will insert the elements `"5z", "6z", "7z"` at that spot in the containing array. Later mods can change the final value of a constant via `apply append, "constants.always_yakuhai", "4z"`.
- `replace all, ".wall", "5z", "0z"`: Replace all instances of `"5z"` with `"0z"` under the given path `"wall"`.

**Yaku**

- `define_yaku_precedence "Honroutou", ["Chanta", "Junchan"]`: Makes it so having the yaku `"Honroutou"` makes you ineligible for `"Chanta"` and `"Junchan"`. You can also supply point values in the array (e.g. `1` to invalidate all 1-point yaku) or a yaku list like `"yaku"` (to invalidate all yaku in the yaku list `yaku`).
- `define_yaku yaku, "Houtei", [1, "Han"], no_tiles_remaining, ["Haitei"]`: Define a yaku named `"Houtei"` to be inserted into the yaku list named `yaku`. This awards value `[1, "Han"]` if the winning hand fulfills the condition `no_tiles_remaining`. Other allowed values include `1` and `[1, "Han", 1, "⛁"]`. The final argument `["Haitei"]` is optional and defines a list of yaku this yaku supercedes. It is basically shorthand for `define_yaku_precedence "Houtei", ["Haitei"]`. You may `define_yaku` multiple instances of a given yaku name: if more than one yaku of the same name are awarded, their values are added together. On the winning screen, yaku are displayed in the order they are defined.
- `remove_yaku "yaku", ["Chanta", "Junchan"]`: Remove the yaku `"Chanta"` and `"Junchan"` from the yaku list named `yaku`. You can also supply a single string to remove one yaku.
- `replace_yaku yaku, "Haitei", [1, "Han"], no_tiles_remaining and won_by_draw, ["Houtei"]`: This replaces every existing instance of the yaku `"Haitei"` in the yaku list `yaku` with a single new definition. The syntax is identical to `define_yaku`.

**Buttons**

- ```elixir
  define_button chii,
    display_name: "Chii",
    show_when: not_our_turn and not_no_tiles_remaining and kamicha_discarded and call_available,
    precedence_over: ["chii"],
    call: [[-2, -1], [-1, 1], [1, 2]],
    call_style: %{
      kamicha: ["call_sideways", 0, 1],
      toimen: [0, "call_sideways", 1],
      shimocha: [0, 1, "call_sideways"]
    }
    do
      big_text("Chii")
      call
      change_turn("self")
    end
  ```
  This defines a new button with id `chii` and display name `"Chii"`. The only necessary fields are `display_name` and `show_when` as well as the final `do`-block of actions. See the [relevant documentation](./documentation.md#the-define-button-command) for more information about the other fields.

- ```elixir
  define_auto_button _1_auto_sort,
  display_name: "A",
  desc: "Automatically sort your hand.",
  enabled_at_start: true
  do
    sort_hand
  end
  ```
  This defines a new auto button (bottom left toggles). See the [relevant documentation](./documentation.md#the-define-auto-button-command) for more information.

**Mod management**

- ```elixir
define_mod shiro_pocchi,
  name: "Shiro Pocchi",
  desc: "One of the white dragons is shiro pocchi. Shiro pocchi acts a joker tile when drawn while in riichi."
  default: false,
  order: 2,
  deps: ["yaku/riichi"],
  conflicts: ["no_honors", "chinitsu"],
  category: "Other"
  ```
  Mods are contained in the directory `priv/static/mods`, and the id you supply (here `shiro_pocchi`) should be one of those. The only required fields are `name` and `desc`. See [mods.md](./mods.md) for more info.
- `define_mod_category "Other"`: This simply adds a new header to the mods list. If any mods defined thereafter don't define a `category` field, it will default to the last-added category.
- `config_mod honba, name: "value", values: [100, 500, 1000]`: This adds a dropdown to the `honba` mod when enabled, with name `value` and allowable dropdown options `100`, `500`, and `1000`. The resulting value is accessible in the mod itself (a MahjongScript file) as the variable `!value`.
- `remove_mod honba`: Removes the `honba` mod from the mod list.
- ```elixir
  define_preset "Mahjong Soul", [
    %{name: "honba", config: %{value: 100}},
    %{name: "yaku/riichi", config: %{bet: 1000, drawless: false}},
    ...
    "first_gets_riichi_sticks"
  ]
  ```
  This defines a set of mods (a modpack) which can be seen in the game settings menu. See the Riichi ruleset for examples. A mod is either just its id, or the structure `%{name: id, config: %{config_value: "value"}}` if the mod has config values.

**Other**

For these two, please see the relevant section.

- `define_play_restriction`: Prevent certain tiles from being played depending on conditions. Example: `define_play_restriction "flower", !unskippable`
- `apply`: Directly modify the underlying JSON in some way. Example: `apply append, "constants.always_yakuhai", "4z"`
