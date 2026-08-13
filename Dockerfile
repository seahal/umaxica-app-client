ARG RUST_VERSION=1.90
ARG DEBIAN_VERSION=bookworm-slim
# .github/workflows/cross-build.yml の LLVM_MINGW_VERSION と揃えること。
ARG LLVM_MINGW_VERSION=20260616

# Base stage shared by development and build targets.
FROM rust:${RUST_VERSION} AS base
RUN apt-get update \
    && apt-get install -y --no-install-recommends pkg-config libssl-dev ca-certificates git curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Windows (gnullvm) 向けクロスコンパイル用ツールチェーン。
ARG LLVM_MINGW_VERSION
RUN set -eux; \
    arch="$(uname -m)"; \
    url="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-${arch}.tar.xz"; \
    curl -fsSL "$url" -o /tmp/llvm-mingw.tar.xz; \
    mkdir -p /opt/llvm-mingw; \
    tar -xJf /tmp/llvm-mingw.tar.xz -C /opt/llvm-mingw --strip-components=1; \
    rm /tmp/llvm-mingw.tar.xz
ENV PATH=/opt/llvm-mingw/bin:${PATH}

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

RUN mkdir -p "${CARGO_HOME}" /home/${USERNAME}/workspace \
    && chown -R "${USERNAME}:${USERNAME}" "${CARGO_HOME}" /home/${USERNAME} \
    && runuser -u "${USERNAME}" -- rustup component add clippy rustfmt \
    && runuser -u "${USERNAME}" -- rustup target add x86_64-pc-windows-gnullvm aarch64-pc-windows-gnullvm

WORKDIR /home/${USERNAME}/workspace
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

COPY --from=build /app/target/release/umaxica-apps-cli /usr/local/bin/umaxica-apps-cli

CMD ["umaxica-apps-cli"]
