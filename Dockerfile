ARG RUST_VERSION=1.90
ARG DEBIAN_VERSION=bookworm-slim

# Base stage shared by development and build targets.
FROM rust:${RUST_VERSION} AS base
RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Development container stage used by docker compose.
FROM base AS development
ARG USERNAME=client
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home "${USERNAME}"

ENV CARGO_HOME=/home/${USERNAME}/.cargo
ENV PATH=${CARGO_HOME}/bin:${PATH}

RUN mkdir -p "${CARGO_HOME}" /home/${USERNAME}/main \
    && chown -R "${USERNAME}:${USERNAME}" "${CARGO_HOME}" /home/${USERNAME} \
    && rustup component add clippy rustfmt

WORKDIR /home/${USERNAME}/main
USER ${USERNAME}

# Build stage that compiles the Rust binary with Cargo.
FROM base AS build

# Cache dependencies by compiling a placeholder crate before copying sources.
COPY Cargo.toml Cargo.lock ./
RUN mkdir src \
    && echo "fn main() {}" > src/main.rs \
    && cargo build --release \
    && rm -rf src

COPY src ./src
RUN cargo build --release

# Minimal runtime image containing only the compiled binary.
FROM debian:${DEBIAN_VERSION} AS runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=build /app/target/release/sample /usr/local/bin/sample

CMD ["sample"]
