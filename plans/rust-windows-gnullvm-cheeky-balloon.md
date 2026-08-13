# Windows ターゲットを MSVC から gnullvm へ移行

## Context

現状の Windows 対応は `x86_64-pc-windows-msvc` / `aarch64-pc-windows-msvc` で、
ビルドには windows-latest ランナーが必須。Linux の devcontainer からは
Windows 版バイナリを一切作れない（`x86_64-w64-mingw32-gcc` も未インストール）。

調査結果（この環境で確認済み）:

- rustc 1.97.1 / rustup には `x86_64-pc-windows-gnullvm`, `aarch64-pc-windows-gnullvm`,
  `i686-pc-windows-gnullvm` が **登録済み**（tier 2, std 配布あり）。`rustup target add` で入る。
- ただしリンク用ツールチェーンが無い: `lld` / `ld.lld` / `*-w64-mingw32-clang` / `x86_64-w64-mingw32-gcc`
  すべて MISSING。`clang` と `llvm-ar` のみ存在。→ **llvm-mingw の導入が必須**。
- `.cargo/config.toml` には windows-gnu / windows-msvc のリンカ設定はあるが gnullvm は無い。
- `Dockerfile` の runtime ステージが `target/release/sample` を参照しており、実バイナリ名
  `umaxica-apps-cli` と不一致（既存バグ、ついでに直す）。

決定事項: **MSVC ターゲットは廃止し gnullvm に置換**。CI の Windows ビルドは
**ubuntu-latest 上でクロスビルド**（ローカル devcontainer と同一手順）。

## 変更内容

### 1. llvm-mingw の導入（`Dockerfile` の base ステージ）

`mstorsjo/llvm-mingw` の UCRT リリース（例 `20250910` の
`llvm-mingw-<ver>-ucrt-ubuntu-22.04-x86_64.tar.xz`）を `/opt/llvm-mingw` に展開し
`ENV PATH=/opt/llvm-mingw/bin:${PATH}`。バージョンは `ARG LLVM_MINGW_VERSION` で固定。
これで `x86_64-w64-mingw32-clang` と `aarch64-w64-mingw32-clang`（および ld.lld）が入る。

同ステージで rustup ターゲットも追加:

```
rustup target add x86_64-pc-windows-gnullvm aarch64-pc-windows-gnullvm
```

development ステージは `client` ユーザーで `runuser -u client -- rustup target add ...`
を既存の `rustup component add` の行に合わせて追記する。

あわせて runtime ステージの `sample` → `umaxica-apps-cli` を修正。

### 2. `.cargo/config.toml`

windows-msvc / windows-gnu のエントリを削除し、gnullvm を追加:

```toml
# Windows (x86_64, LLVM/MinGW)
[target.x86_64-pc-windows-gnullvm]
linker = "x86_64-w64-mingw32-clang"
ar = "llvm-ar"

# Windows (aarch64, LLVM/MinGW)
[target.aarch64-pc-windows-gnullvm]
linker = "aarch64-w64-mingw32-clang"
ar = "llvm-ar"
```

ホストに llvm-mingw が無い環境（素の macOS 等）では上記 linker が解決できないが、
Windows ターゲットを指定した時のみ評価されるので通常ビルドには影響しない。

### 3. `.github/workflows/cross-build.yml`

- matrix の 2 つの `*-pc-windows-msvc` エントリを `x86_64-pc-windows-gnullvm` /
  `aarch64-pc-windows-gnullvm` に置換し、`os: windows-latest` → `ubuntu-latest`、
  `cross: false` のまま（cross は使わず素の cargo + llvm-mingw）。
  `asset_name` は既存の `...-windows-x86_64.exe` / `...-windows-aarch64.exe` を維持。
- 新規ステップ `Install llvm-mingw`（`if: contains(matrix.target, 'gnullvm')`）:
  リリース tarball を取得 → `/opt` に展開 → `$GITHUB_PATH` に bin を追記。
  Dockerfile と同じ `LLVM_MINGW_VERSION` を使う（両方に同じ値をハードコードし、コメントで相互参照）。
- `Run tests` ステップの条件を「gnullvm でない」に変更（Linux 上では .exe を実行できないため）。
  Windows のテスト実行は失われる旨を build-summary に反映。
- build-summary の Supported Platforms の Windows 行に `(gnullvm)` を付記。

### 4. ドキュメント

`CLAUDE.md` の Target Platforms の "Windows x86_64 (MSVC)" / "Windows aarch64 (MSVC)" を
`(gnullvm)` に更新。`README.md` に Windows ターゲットの記載があれば同様に更新。

## 検証

devcontainer をリビルドしたうえで:

```bash
x86_64-w64-mingw32-clang --version           # llvm-mingw が PATH にある
rustup target list --installed               # 2 つの gnullvm ターゲットが出る
cargo build --release --target x86_64-pc-windows-gnullvm
cargo build --release --target aarch64-pc-windows-gnullvm
file target/x86_64-pc-windows-gnullvm/release/umaxica-apps-cli.exe   # PE32+ x86-64
file target/aarch64-pc-windows-gnullvm/release/umaxica-apps-cli.exe  # PE32+ Aarch64
cargo fmt -- --check && cargo clippy --all-targets --all-features -- -D warnings && cargo test
```

CI 側は push 後に cross-build ワークフローの 2 つの Windows ジョブが green で、
`umaxica-apps-cli-windows-x86_64.exe` / `-aarch64.exe` の artifact が生成されることを確認。
可能なら x86_64 の .exe を実 Windows 機か wine で起動して `--help` が出ることを確認する。
