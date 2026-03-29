@AGENTS.md

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`umaxica-apps-cli` (v0.1.0) — A cross-platform CLI/CDK tool written in Rust with `clap`.

### Target Platforms
- Linux x86_64 (musl, static binary)
- Linux aarch64 (musl, static binary)
- macOS aarch64 (Apple Silicon)
- Windows x86_64 (MSVC)
- Windows aarch64 (MSVC)

## Development Commands

### Build and Run
- `cargo build` - Build the project
- `cargo run` - Run the application
- `cargo check` - Check for compilation errors without building

### Testing
- `cargo test` - Run all tests
- `cargo test --verbose` - Run tests with verbose output

### Code Quality
- `cargo fmt` - Format code (standard Rust formatting)
- `cargo clippy --all-targets --all-features -- -D warnings` - Run Rust linter

## Architecture

- `src/main.rs` - Entry point, CLI argument parsing with clap
- `Cargo.toml` - Project configuration and dependencies
- Dependencies: `clap` (v4, with derive feature)

## CI/CD

- `.github/workflows/integration.yml` - Format check, clippy, build, test (on ubuntu-latest)
- `.github/workflows/cross-build.yml` - Cross-platform builds for all 5 target platforms using `cross` for Linux musl targets
- `.github/workflows/codeql.yml` - Code security analysis
