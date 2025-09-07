# Repository Guidelines

## Project Structure & Module Organization
- `src/`: Rust sources. Entry point in `src/main.rs`.
- `Cargo.toml`: Package metadata and dependencies.
- `target/`: Build artifacts (ignored by Git).
- `.github/workflows/rust.yml`: CI for build and tests.
- `README.md`, `SECURITY.md`, `LICENSE`: Top‑level docs.

## Build, Test, and Development Commands
- `cargo build`: Compile in debug mode.
- `cargo run`: Build and run the client.
- `cargo check`: Type/check without producing binaries (fast feedback).
- `cargo test` / `cargo test --verbose`: Run unit/integration tests.
- `cargo fmt` / `cargo fmt -- --check`: Format / verify formatting.
- `cargo clippy --all-targets --all-features -D warnings`: Lint as errors.

## Coding Style & Naming Conventions
- Formatting: Use `rustfmt` (run `cargo fmt` before commits).
- Linting: Keep a clean `clippy` run; avoid `allow` unless justified.
- Naming: `snake_case` for functions/files, `CamelCase` for types/traits, `SCREAMING_SNAKE_CASE` for consts.
- Imports: Prefer explicit `use` paths; avoid wildcard imports.
- Errors: Return `Result<_, _>` where appropriate; avoid panics in library‑like code.

## Testing Guidelines
- Framework: Standard Rust tests with `#[test]`.
- Layout: Unit tests co‑located in `#[cfg(test)] mod tests` blocks; integration tests in `tests/`.
- Naming: Test function names describe behavior (e.g., `prints_greeting_on_start`).
- Coverage: Aim for critical path coverage; add regression tests for bugs.

## Commit & Pull Request Guidelines
- Commits: Imperative mood, concise subject. Existing history uses tags like `[UPDATE]`, `[CHECK POINT]`; keep tags consistent if used.
- Scope: One logical change per commit; include rationale in the body when non‑obvious.
- PRs: Link related issues, describe changes and impact, include run/usage notes and logs/screenshots when behavior changes.
- CI: Ensure `cargo build`, `cargo test`, `cargo fmt -- --check`, and `cargo clippy -D warnings` pass before requesting review.

## Security & Configuration Tips
- Do not commit secrets. Use env vars or local config.
- See `SECURITY.md` for reporting guidelines.
