# Installing your own instance of Riichi Advanced

First: if you run into any issues with installation, feel free to open an [issue](https://github.com/EpicOrange/riichi_advanced/issues) or drop us a message on the [Discord](https://discord.gg/5QQHmZQavP)!

## Table of contents

- [Developer information](#developer-information)
- [Installing on Mac/Linux](#installing-on-mac-linux)
- [Installing on Windows](#installing-on-windows)
- [Troubleshooting](#troubleshooting)

## Installing on Mac/Linux

First, install Erlang/Elixir. Although the code was originally written for Elixir 1.14, you should probably install the newest version since we're slowly migrating to newer versions. As of writing, that's Elixir 1.19.

Highly recommend using [`asdf`](https://asdf-vm.com/guide/getting-started.html) to install Erlang/Elixir since it can manage different versions for you (similar to `pyenv` for `python`). This should also smooth over any OS-specific nonsense that comes with installations.

Otherwise, to install elixir (instructions taken from [here](https://elixir-lang.org/install.html)):

- (Mac) `brew install elixir`
- (Debian/Ubuntu)
  ```
  sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang
  sudo apt update
  sudo apt install git elixir erlang
  ```
- (Arch/Manjaro) `sudo pacman -S elixir`
- (Red Hat/Fedora) `sudo dnf --repo=rawhide install elixir elixir-doc erlang erlang-doc`
- (Nix) You (a nix user) probably have a preferred way to do this, but here are some options.
  + Put `elixir` in your `configuration.nix` package list
  + Or run `nix-shell -p elixir` to drop into a dev shell
  + Or run `nix-env -iA nixpkgs.elixir` (global, permanent)
  + You can also check out the nix flake solution in #150.

---

Besides Elixir, you'll also need `z3`, `jq`, and `npm`.

- `z3` is used to solve for jokers in games with joker tiles.
- `jq` is used for constructing all rulesets and applying mods.
- `npm` is used only for a few Javascript packages (notably, a library used to let players swap tiles around in hand). However, it's a huge dependency for little benefit, so the plan is to Eventually™ replace it with something else, in order to remove `npm` as a dependency.

To install:

- (Mac) `brew install z3 jq npm`
- (Debian/Ubuntu) `sudo apt install z3 jq npm`
- (Arch/Manjaro) `sudo pacman -S z3 jq npm`
- (Red Hat/Fedora) `sudo dnf install z3 jq npm`
- (Nix) Same as above with `elixir`, but with `z3 jq npm`

Then run:

    git clone "https://github.com/EpicOrange/riichi_advanced.git"
    cd riichi_advanced

    # Get Elixir dependencies
    mix deps.get

    # Generate self-signed certs for local https
    mix phx.gen.cert

    # Get Node dependencies (there aren't many)
    (cd assets; npm i)

    # Run epmd (Erlang Port Mapper Daemon) in the background 
    epmd -daemon

This should set it up so that the following command starts the server on <https://localhost:4000>.

    HTTPS_PORT=4000 iex -S mix phx.server

If it asks if it can install Mix or rebar3, say yes. (These are build managers for Elixir.)

This should start the server while dropping you into an `iex` (Interactive Elixir) shell. The server should now be available at <https://localhost:4000>.

To exit the shell and stop the server, press `ctrl-c` twice in the `iex` shell. If you're messing with the code, there should be no need to stop the server, it should be able to live-reload all changes (except changes to `config/` files).

## Installing on Windows

There's two ways to install on Windows. One way is to use [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) and then follow the Linux instructions above. The other way is to install [Chocolatey](https://chocolatey.org/install), which we'll discuss below.

So first install [Chocolatey](https://chocolatey.org/install). The installation wizard will prompt you to install `npm`. Do so since that is the easiest known way to install `npm`, which you'll need for Riichi Advanced.

You will need to restart your system after every step, because this is how Windows updates `%PATH%` globally. If you know of a way to update `%PATH%` without restarting, that'd be great to know! (join our [Discord](https://discord.gg/5QQHmZQavP))

Afterwards, open up Powershell and use Chocolatey to install all the dependencies. If it fails, you might need to run the terminal as administrator.

    choco install git elixir z3 jq npm

Then clone this repository, if you haven't already:

    git clone "https://github.com/EpicOrange/riichi_advanced.git"
    cd riichi_advanced

The following files should be manually patched to deal with Windows line endings. 

- In `\lib\ex_jq\jq.ex`, lines 19 to 35 (`# postprocess the result ... raise(UnknownException, error) ↵ end`) should be replaced with `result`.
- Near the end of `\lib\riichi_advanced\game\mod_loader.ex`, the regex `Regex.replace(~r{^//.*|\s//.*|/\*[.\n]*?\*/}, json, "")` should be replaced with `Regex.replace(~r{^//.*|\s//.*|/\*[.\r\n]*?\*/}, Regex.replace(~r{\r\n}, json, "\n"), "")`.
 
Then set everything up

    # Get Elixir dependencies
    mix deps.get

    # Generate self-signed certs for local https
    mix phx.gen.cert

    # Get Node dependencies (there aren't many)
    cd assets
    npm i
    cd ..

    # Start the server
    $env:HTTPS_PORT=4000; & iex.bat -S mix phx.server

### Troubleshooting

**The compilation fails with some `get_in/1` error**

```
(CompileError) lib/riichi_advanced/game/game_state/rules.ex:24: undefined function get_in/1 (expected RiichiAdvanced.GameState.Rules to define such a function or for it to be imported, but none are available)
```

This seems like an old Elixir version problem (check with `elixir --version`).

---

**Could not start Hex**

```
Could not start Hex. Try fetching a new version with "mix local.hex" or uninstalling it with "mix archive.uninstall hex.ez"
```

Most likely due to build artifacts if you switched Elixir versions, or mismatched build tooling. Like it says, reinstall Hex with `mix local.hex`, then clean build artifacts with `mix clean`, then try running the server again (`HTTPS_PORT=4000 iex -S mix phx.server`)

---

**I'm getting some other compile error**

That shouldn't happen, please open an [issue](https://github.com/EpicOrange/riichi_advanced/issues)!

---

**The server compiles but fails to run, I get an error that says `:eacces`**

```
** (EXIT) shutdown: failed to start child: {RiichiAdvancedWeb.Endpoint, :http}
** (EXIT) shutdown: failed to start child: :listener
** (EXIT) :eacces
```

EACCES is Linux speak for 'you lack permissions'. Here, most likely it is due to the server trying to open port 80 (HTTP port) and failing since only permissioned programs can open port 80. Fix this by first finding where `beam.smp` is, and then running something like:

    sudo setcap 'cap_net_bind_service=+ep' ~/.asdf/installs/erlang/27.2.4/erts-15.2.2/bin/beam.smp

If that doesn't work, you can make 4001 the HTTP port instead:

    HTTP_PORT=4001 HTTPS_PORT=4000 iex -S mix phx.server

Alternatively, simply don't serve HTTP, by going to `config/dev.exs` and commenting out these lines like so:

```elixir
    # http: [
    #   ip: {0, 0, 0, 0},
    #   port: System.get_env("HTTP_PORT") || 80,
    #   thousand_island_options: [transport_options: [reuseport: true]],
    # ],
```

---

**My browser just displays a white background with some garbled text**

<img width="367" height="212" alt="http_error" src="https://github.com/user-attachments/assets/c0c5b0f5-8c6f-4410-b767-491ed96cd72d" />

**and the console prints:**

```
[notice] TLS :server: In state :hello at tls_record.erl:532 generated SERVER ALERT: Fatal - Unexpected Message
 - {:unsupported_record_type, 71}
```

This happens when trying to connect to the HTTPS endpoint (port 4000) with `http` instead of `https`. Use `https://`. If you're already using `https://localhost:4000` to connect with HTTPS, then unfortunately it's not clear why this is happening?, but hopefully this information helps?

Bottom line is that HTTPS requests start with a TLS handshake byte (`0x16`), and instead the server is getting `71` (the letter 'G') which is the first byte of every HTTP GET request.
