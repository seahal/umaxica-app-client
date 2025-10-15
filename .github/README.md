# umaxica-app-client

Simple Rust client prototype that prints a greeting. You can run it either with the local toolchain or inside a container image.

## Local development

```sh
cargo run
```

## Building the container image

```sh
docker build -t umaxica-app-client .
```

This uses the multi-stage `Dockerfile` in the repository. The first stage builds the release binary, and the second ships a slim runtime image containing only the executable and the certificates needed for outbound TLS connections.

## Running the container

```sh
docker run --rm umaxica-app-client
```

You should see the `Hello, Client!` message printed to the container logs.
