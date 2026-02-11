{
  description = "Riichi Advanced - Mahjong web client development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        erlang = pkgs.beam.packages.erlang_27;
        elixir = erlang.elixir_1_18;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            erlang.erlang
            elixir
            pkgs.nodejs
            pkgs.z3
            pkgs.jq
            pkgs.python3
            pkgs.git
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            pkgs.inotify-tools
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.fswatch
          ];

          shellHook = ''
            # Set up Mix to install deps locally
            export MIX_HOME="$PWD/.nix-mix"
            export HEX_HOME="$PWD/.nix-hex"
            export PATH="$MIX_HOME/bin:$HEX_HOME/bin:$PATH"

            # Ensure hex and rebar are installed
            if [ ! -d "$HEX_HOME" ]; then
              echo "Installing Hex..."
              mix local.hex --force
            fi
            if [ ! -f "$MIX_HOME/bin/rebar3" ]; then
              echo "Installing Rebar3..."
              mix local.rebar --force
            fi

            # Set ERL_AFLAGS for better shell experience
            export ERL_AFLAGS="-kernel shell_history enabled"

            echo ""
            echo "Riichi Advanced development environment"
            echo "========================================"
            echo "Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null | tr -d '"')"
            echo "Elixir: $(elixir --version | grep Elixir)"
            echo "Node.js: $(node --version)"
            echo "z3: $(z3 --version 2>/dev/null || echo 'installed')"
            echo "jq: $(jq --version)"
            echo ""
            echo "Quick start:"
            echo "  mix deps.get          # Get Elixir dependencies"
            echo "  mix phx.gen.cert      # Generate self-signed certs"
            echo "  (cd assets && npm i)  # Get Node dependencies"
            echo "  HTTPS_PORT=4000 iex -S mix phx.server  # Start server"
            echo ""
          '';
        };
      }
    );
}
