# Riichi Advanced

![](title.png)

Multipurpose extensible mahjong client featuring the following:

- Multiple base rulesets, including Riichi, Hong Kong Old Style, Sichuan Bloody, and Bloody 30-Faan Jokers. You can even play Riichi Mahjong with Saki powers!
- Optional mods for each ruleset, especially Riichi! Play with head bump, sequences wrapping from 9 to 1, a tenth tile in each suit, and more!
- Lobby system with public/private rooms! Invite your friends!
- Infinitely customizable ruleset! Copy-paste an existing ruleset and play your modified version directly in the client!

All of this is live at <https://riichiadvanced.com/>, and the Discord is here: <https://discord.gg/5QQHmZQavP>

This project is currently in beta, please help us test for bugs in the discord linked above!
The planned v1.0 release date is 2025 New Years, so stay posted!

## Documentation

If you're looking to make a custom ruleset using the game's JSON-based ruleset format, that documentation is available [here](documentation/documentation.md).

This project is written in Elixir with the Phoenix framework, making heavy use of the LiveView library. Like all Phoenix projects, it has two moving parts:

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
    │   │   ├── log (everything related to the log viewing screen)
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
    │       ├── logs (save location for all logs)
    │       ├── mods (all mods)
    │       ├── rulesets (all rulesets)
    │       ├── favicon.ico
    │       └── robots.txt
    └── test (unused)

## Running the server

This process requires installing Elixir (≥ 1.14) and `npm`.

Then run:

    git clone "https://github.com/EpicOrange/riichi_advanced.git"
    cd riichi_advanced

    # Get Elixir dependencies
    mix deps.get

    # Generate self-signed certs for local https
    mix phx.gen.cert

    # Get Node dependencies
    (cd assets; npm i)

    # Start the server
    iex -S mix phx.server

This should start the server up at `localhost:4000`. Phoenix should live-reload all your changes to Elixir/JS/CSS files while the server is running.
