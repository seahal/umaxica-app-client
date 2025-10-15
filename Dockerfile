# Development container stage used by docker compose.
FROM rust:1.79 AS development
ARG USERNAME=client
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home "${USERNAME}"

ENV CARGO_HOME=/home/${USERNAME}/.cargo
ENV PATH=${CARGO_HOME}/bin:${PATH}

RUN mkdir -p "${CARGO_HOME}" /home/${USERNAME}/main \
    && chown -R "${USERNAME}:${USERNAME}" "${CARGO_HOME}" /home/${USERNAME} \
    && rustup component add clippy rustfmt

WORKDIR /home/${USERNAME}/main
USER ${USERNAME}

# Build stage that compiles the Rust binary.
FROM rust:1.79 AS build
WORKDIR /main

# Cache dependencies by building a dummy crate before copying the real sources.
COPY Cargo.toml Cargo.lock ./
RUN mkdir src \
    && echo "fn main() {}" > src/main.rs \
    && cargo build --release \
    && rm -rf src

COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /main
COPY --from=build /app/target/release/sample /usr/local/bin/sample

CMD ["sample"]
