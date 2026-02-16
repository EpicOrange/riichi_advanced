# Production build using Nix flake
# Usage: docker build -t riichi-advanced .
#        docker run -p 80:80 -p 4000:4000 -e SECRET_KEY_BASE=... riichi-advanced
FROM nixos/nix:latest

# Enable flakes
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# UTF-8 support for Elixir
ENV ELIXIR_ERL_OPTIONS="+fnu"

WORKDIR /app

# Copy flake files first for better caching
COPY flake.nix flake.lock ./
RUN nix develop --command true

# Copy the rest of the application
COPY . .

# Build the app (no release - run with mix for compatibility with priv_dir config)
RUN nix develop --command sh -c '\
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    MIX_ENV=prod mix compile && \
    cd assets && npm install && cd ..'

EXPOSE 80 4000

ENV MIX_ENV=prod
ENV PHX_HOST=localhost
ENV PORT=4000

# Run with mix phx.server instead of release
ENTRYPOINT ["nix", "develop", "--command"]
CMD ["mix", "phx.server"]
