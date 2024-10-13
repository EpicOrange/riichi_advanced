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

This project is written in Elixir with the Phoenix framework.

If you're looking to make a custom ruleset using the game's JSON-based ruleset format, that documentation is available [here](documentation/documentation.md).

## Running the server

Since I have obviously not uploaded the database keys in `/config`, and secrets stuff in `/priv/cert` you will have to substitute your own by generating a new Phoenix project, and copying over the files in those two directories.

After that's done, you can run the server via `iex -S mix phx.server` at the project root just like any other Phoenix project.
