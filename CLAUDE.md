# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rust application client project named "sample" (version 0.1.0). It's a minimal Rust binary crate with a simple "Hello, Client!" application in `src/main.rs:2`.

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
- `cargo clippy` - Run Rust linter for code improvements

## Architecture

The project follows standard Rust binary crate structure:
- `src/main.rs` - Entry point with main function
- `Cargo.toml` - Project configuration and dependencies
- No external dependencies currently defined

## CI/CD

GitHub Actions workflow (`.github/workflows/rust.yml:1`) runs on push/PR to main branch:
- Builds with `cargo build --verbose` 
- Runs tests with `cargo test --verbose`