# Riichi Advanced

![](title.png)

Multipurpose extensible four-player mahjong client featuring the following:

- Six base rulesets: Riichi, Hong Kong, Sichuan Bloody, Saki Powers, Vietnamese, Bloody 30-Faan Jokers
- Dozens of optional mods (for Riichi): Head Bump, Open Riichi, Space Mahjong, Shiro Pocchi, Tenth tile in each suit, and more
- Lobby system with public/private rooms
- Infinitely customizable ruleset (it's a JSON file)

This project is hosted at <https://riichiadvanced.com/>, and the Discord is here: <https://discord.gg/5QQHmZQavP>

It is currently in beta, please help us test for bugs!

## Documentation

If you're looking to make a custom ruleset using the game's JSON-based ruleset format, that documentation is available [here](documentation/documentation.md).

This project is written in Elixir with the Phoenix framework making heavy use of the LiveView library. Like all Phoenix projects it has two moving parts:

- `lib/riichi_advanced`: Model
- `lib/riichi_advanced_web`: Combined View/Controller

Here is a breakdown of all the directories:

    ├── assets (node modules, js, css)
    ├── lib
    │   ├── delta (operational transform library)
    │   ├── ex_jq (jq binding library)
    │   ├── ex_smt (z3 binding library)
    │   ├── riichi_advanced (all application logic)
    │   │   ├── game (everything related to the game screen)
    │   │   ├── lobby (everything related to the lobby screen)
    │   │   ├── messages (everything related to the messages panel)
    │   │   ├── room (everything related to the room screen)
    │   │   ├── application.ex (main thing! OTP root application/supervisor)
    │   │   ├── cache.ex (general-purpose ETS cache)
    │   │   ├── exit_monitor.ex (general-purpose disconnection monitor process)
    │   │   ├── mailer.ex (unused)
    │   │   ├── repo.ex (unused)
    │   │   └── session_supervisor.ex (DynamicSupervisor instance)
    │   └── riichi_advanced_web
    │       ├── components (stock Phoenix except for components/layouts/root.html.heex)
    │       ├── controllers (stock Phoenix)
    │       ├── views (all LiveViews and live components)
    │       ├── endpoint.ex (main thing! serves all the other files as plugs)
    │       ├── gettext.ex (unused)
    │       ├── router.ex (LiveView routes)
    │       └── telemetry.ex (unused)
    ├── priv
    │   ├── gettext (unused)
    │   ├── repo (unused)
    │   └── static
    │       ├── audio (all audio)
    │       ├── images (all spritesheets and svgs)
    │       ├── mods (all mods)
    │       ├── rulesets (all rulesets)
    │       ├── favicon.ico
    │       └── robots.txt
    └── test (unused)

## Running the server

Since I have obviously not uploaded the database keys in `/config`, and secrets stuff in `/priv/cert` you will have to substitute your own by generating a new Phoenix project, and copying over the files in those two directories.

After that's done, you can run the server via `iex -S mix phx.server` at the project root just like any other Phoenix project.
