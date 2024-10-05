# Riichi Advanced

This project is a multipurpose extensible four-player mahjong client, written in Elixir with the Phoenix framework.

## Documentation

Documentation is available [here](documentation/documentation.md).

## Running the server

Since I have not uploaded the database keys in `/config` and secrets stuff in `/priv/cert` you will have to substitute your own by generating a new Phoenix project and copying over the files in those two directories.

Then you run `iex -S mix phx.server` at the project root.
