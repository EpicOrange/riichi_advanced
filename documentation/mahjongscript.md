# MahjongScript tutorial

Writing a ruleset requires knowing the JSON specification, which involves a lot of balancing brackets and not forgetting commas. MahjongScript was created for the purpose of avoiding these errors. Based on Elixir syntax, MahjongScript (.majs) is essentially a list of commands which compile down to jq. This jq is then applied to the empty object in order to create a JSON ruleset, or it can be applied to an existing JSON ruleset to mod it.

There are four types of data in MahjongScript:

- [**JSON**](#json): numbers, strings, arrays, and objects
- [**Conditions**](#conditions): conditions with `and`, `or`, `not`
- [**Actions**](#actions): function calls or `do`-blocks containing actions
- [**Sigils**](#sigils): set specifications, match specifications

The entirety of a MahjongScript file is a list of commands that use these data in some way. [A list of commands is provided at the bottom](#commands).

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

  # as-blocks compile to "as" actions
  as everyone do
    push_message("says hi")
  end

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

# Command Reference

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

### `config_mod`: Add a new config option to a given mod

```elixir
config_mod id,
  name: config name,
  values: ["Mangan", "Yakuman"],
  default: "Yakuman"
```

### `remove_mod`: Delete mods by id

```elixir
remove_mod id
remove_mod id1, id2, id2
```

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
}
```
