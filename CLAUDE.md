# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ConsoleProgressKit** is a lightweight Swift Package Manager (SPM) library providing colorized command-line progress bars for Swift CLI applications. It uses ANSI escape sequences for terminal manipulation and has zero external dependencies.

## Build & Test Commands

### Building the package
```bash
swift build
```

### Running tests (when added)
```bash
swift test
```

### Building in release mode
```bash
swift build -c release
```

### Opening in Xcode
```bash
open Package.swift
```

## Architecture

### Core Components

**ConsoleProgressBar** (`Sources/ConsoleProgressKit/ConsoleProgressBar.swift`)
- Main public API for progress tracking
- Manages terminal state (current position, first update flag)
- Renders progress using ANSI escape sequences for in-place updates
- Uses `\u{1B}[2K` to clear lines and `\u{1B}[nA` to move cursor up
- Tracks `firstUpdate` to determine whether to clear previous output
- Dynamically handles 2 or 3 line displays based on optional detail parameter

**ConsoleColor** (`Sources/ConsoleProgressKit/ConsoleColor.swift`)
- Simple enum wrapping ANSI color codes
- Provides color options: green, yellow, blue, magenta, cyan, reset
- Used for progress bar coloring and text emphasis

### Key Design Patterns

1. **Terminal Output Management**: Progress updates are rendered in-place by:
   - Moving cursor up to previous lines
   - Clearing each line before writing new content
   - Flushing stdout to ensure immediate display

2. **Stateful Rendering**: The bar tracks internal state (`current`, `firstUpdate`) to manage multi-line updates correctly across calls

3. **Public API Surface**:
   - `init(width:color:)` - Configure bar appearance
   - `updateProgress(current:total:message:detail:)` - Update display
   - `complete(message:)` - Final completion state

## Development Notes

- Swift 6.2+ required (see Package.swift)
- Platform: macOS (relies on terminal ANSI support)
- No test target currently exists in Package.swift
- Library product is the only build output

## Claude Code Skill

The API reference skill for this package lives here, in `Skills/ConsoleProgressKit/`, and is served by the public `nn-swift-skills` marketplace as `ConsoleProgressKit@nn-swift-skills`. It was moved out of `NobadiScripts` so the API and its documentation change together: **any PR that changes the public API must update `Skills/ConsoleProgressKit/` in the same PR.**

- `Skills/` is not a SwiftPM target; it ships only through the marketplace.
- `Skills/ConsoleProgressKit/.claude-plugin/plugin.json` deliberately has **no `version` field**. The marketplace pins the skill to a git tag, and the plugin cache is keyed by commit sha. Do not reintroduce a version; a hand-typed number nothing verifies is the staleness this arrangement removes.
- `manifest.json` records the commit, source hashes, and type anchors the docs were generated from; regenerate it when the docs are regenerated.

## Releasing

The `nn-swift-skills` entry for this skill is pinned to a release tag (`ref`), not to a branch. **Skill changes reach users when a release is tagged, not when they merge.** A doc fix merged to `main` is invisible until the next tag.

`.github/workflows/skill-ref-bump.yml` keeps the pin current: on every tag push it rewrites the entry's `ref` in `nikolainobadi/nn-swift-skills` and opens a PR there. If that workflow is ever removed, the bump becomes manual. Forgetting it fails silently — the marketplace keeps serving the previous release's docs forever, with nothing erroring and nothing warning.

The workflow authenticates with the repo secret **`MARKETPLACE_TOKEN`**: a fine-grained PAT named `nn-swift-skills-ref-bump`, scoped to `nn-swift-skills` only (Contents and Pull requests, read and write), **expiring 2027-08-15**. It is shared with every other package repo publishing to that marketplace, so rotating it means re-setting the secret in each of them. When it expires, the workflow fails on tag push; treat that as "rotate the shared token", not "this repo's workflow is broken."
