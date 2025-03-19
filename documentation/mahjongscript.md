# MahjongScript reference

## Commands

### `def`: Function definition

    def my_function_name do
      action1
      action2
      if condition do
        action3
      else
        action4
      end
    end

    # you can call it later as an action

### `set`: Set any parameter

    set initial_points, 25000

### (advanced) `apply`: Modify any path

    apply add, "initial_points", 5000

### `on`: Add a new handler for an event

    on before_win do
      actions
    end

Note that this handler will run after any existing handlers for that event.

### `define_set`: Define a set for reference in matches

    define_set pair ~s"0 0"

### `define_match`: Define a match for reference in conditions

    define_match mymatch1, ~m"pair:7"
    define_match mymatch2, ~a"FF XXXX0a NEWS XXXX0b"
    define_match mymatch3, "existing_match_1", "existing_match_2"

### `define_const`: Define a constant JSON value that can be referenced later in actions

    define_const foo, "asdf"
    def bar do
      print(@foo) # prints "asdf"
    end

### `define_yaku`: Add a new yaku

    define_yaku list_name display_name value condition supercedes_list

Note that this new yaku combines with any yaku of the same name, i.e. if you get the same yaku twice then you get that yaku whose value is the sum.

### `remove_yaku`: Remove all instances of a given yaku by name

    remove_yaku yaku_list, name
    remove_yaku yaku_list, [name1, name2]

### `replace_yaku`: Replace all instances of a yaku with a new definition

    replace_yaku list_name display_name value condition supercedes_list

This is essentially the same as `remove_yaku display_name` followed by `define_yaku`, except it will do nothing if the yaku doesn't exist in the first place.

### `define_yaku_precedence`: Define precedence for a given yaku

    define_yaku display_name supercedes_list

### `define_button`: Add a new button

    define_button id,
      display_name: display_name,
      show_when: condition,
      precedence_over: list_of_ids,
      unskippable: false,
      cancellable: false
      do
        actions
      end

Note that any existing button of the same `id` will be overwritten.

### `define_auto_button`: Add a new auto button

    define_auto_button id,
      display_name: display_name,
      desc: string,
      enabled_at_start: false
      do
        actions
      end

Note that any existing auto button of the same `id` will be overwritten.

### `define_mod_category`: Add a mod category

    define_mod_category name
    define_mod_category name, prepend: true

Note that you can have multiple instances of a category, however only the first one will be added to when adding mods to a category.

### `define_mod`: Add a new mod to a given category

    define_mod id,
      name: string,
      desc: string,
      default: false,
      order: 0,
      deps: list of ids,
      conflicts: list of ids
      category: name

Note that if `category` is not specified the mod is simply appended to the end of the list.

### `config_mod`: Add a new config option to a given mod

    config_mod id,
      name: config name,
      values: ["Mangan", "Yakuman"],
      default: "Yakuman"

### (advanced) `define_preset`: Add a new mod preset

    define_preset name, list of mods
