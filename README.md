# hellbun

[![CircleCI](https://dl.circleci.com/status-badge/img/circleci/PROJECT_ID/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/circleci/PROJECT_ID/tree/main)

A simple "Hello, Bun!" application built with Bun.

## Installation

### Homebrew (macOS/Linux)

```bash
brew tap z00b/tap
brew install hellbun
```

### Nix/NixOS

```bash
nix-env -iA nur.repos.z00b.hellbun
```

### Direct Download

Download the latest release from the [releases page](https://github.com/z00b/hello-bun/releases).

## Usage

```bash
hellbun
```

## Development

### Prerequisites

- [Bun](https://bun.sh/) installed
- [GoReleaser](https://goreleaser.com/) for building releases

### Run locally

```bash
bun run src/index.ts
```

### Build releases

Test the release configuration locally:

```bash
goreleaser release --snapshot --clean
```

Create a release using the helper script:

```bash
source release.sh
release 1.0.0 "First stable release"
```

Or manually create a release:

```bash
git tag -a v1.0.0 -m "First release"
git push origin main --tags
```

## License

See [LICENSE](LICENSE) file.
