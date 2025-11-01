# Umaxica App (CLIENT)
（ ＾ν＾） Hello, World!

Simple Rust client prototype that prints a greeting. You can run it either with the local toolchain or inside a container image.

## Local development

```sh
cargo run
```

## Building the container imageCLIENT

```sh
docker build -t umaxica-app-client .
```

This uses the multi-stage `Dockerfile` in the repository. The first stage builds the release binary, and the second ships a slim runtime image containing only the executable and the certificates needed for outbound TLS connections.

## Running the container

```sh
docker run --rm umaxica-app-client
```

You should see the `Hello, Client!` message printed to the container logs.

## Known Issues & Limitations
- This is a work in progress.
- The public availability of this repository is not guaranteed permanently.
- No warranty is provided, and the authors shall not be held liable for any damages arising from the use of this repository.