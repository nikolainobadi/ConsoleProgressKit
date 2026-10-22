# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ConsoleProgressKit** is a lightweight Swift Package Manager (SPM) library providing activity tracking, live spinners and progress bars, and plain log output for Swift CLI applications. Progress goes to stderr; command results go to stdout. The library has zero external dependencies.

## Build & Test Commands

### Building the package
```bash
swift build
```

### Running tests
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

**ProgressDisplay** (`Sources/ConsoleProgressKit/Shared/ProgressDisplay.swift`)
- Shared public interface for tracking async operations, notes, prompt suspension, result output, and terminal restoration
- `ActivityHandle` reports detail, waiting/running state, output lines, and numeric progress

**LiveProgressDisplay** (`Sources/ConsoleProgressKit/Live/LiveProgressDisplay.swift`)
- Animates running activities in a shared terminal region on stderr using a private timer queue
- Stores `LiveDisplayState` transitions and writes their output under a `Mutex`
- `RegionLayout` fits running activities to terminal dimensions; `TerminalScreen` handles erasing, redrawing, and cursor visibility

**PlainProgressDisplay** (`Sources/ConsoleProgressKit/Plain/PlainProgressDisplay.swift`)
- Writes activity starts, updates, and outcomes without animation or escape codes
- Suitable for pipes, logs, and non-interactive callers

**MockProgressDisplay** (`Sources/ConsoleProgressTesting/MockProgressDisplay.swift`)
- Ships in the separate `ConsoleProgressTesting` product, which re-exports `ConsoleProgressKit`
- Writes nothing; records activities (title, `RecordedUpdate`s, `RecordedOutcome`), notes, written output, suspensions, and terminal restoration
- Creates working handles through `ActivityHandle`'s `package` initializer, so the handle stays without a public initializer

### Key Design Patterns

1. **Terminal Output Management**: Callers choose the live or plain display; `TerminalCapabilities.standardErrorIsTerminal` exposes stderr terminal detection. Progress and notes use stderr, while `writeOutput(_:)` writes results to stdout without disrupting the live region.

2. **Stateful Rendering**: Live activity updates change state and are drawn on the next timer tick. Finished activities and notes appear above the running region. `suspended(_:)` clears the region for synchronous prompts and redraws it afterward.

3. **Public API Surface**:
   - `LiveProgressDisplay()` / `PlainProgressDisplay()` - Create a display
   - `track(_:operation:)` - Run an async operation with an `ActivityHandle`, report its outcome and elapsed time, return its value, and rethrow its errors
   - `note(_:style:)` - Print a note
   - `restoreTerminal()` - Permanently stop display output; subsequent tracked operations still execute
   - `MockProgressDisplay()` (`ConsoleProgressTesting`) - Record what code reports, for tests

## Development Notes

- Swift 6.2+ required (see Package.swift)
- Platform: macOS 15+ (see Package.swift)
- `ConsoleProgressKitTests` uses Swift Testing in `Tests/ConsoleProgressKitTests/`, with coverage for live state transitions and shared formatting helpers
- `ConsoleProgressTestingTests` covers `MockProgressDisplay` in `Tests/ConsoleProgressTestingTests/`
- `ConsoleProgressTesting` depends on `package` access (`ActivityHandle.init(send:)`, `ActivityUpdate`); keep those `package`, not `public`
- Both library targets enable `NonisolatedNonsendingByDefault` to preserve caller isolation for async operations
- The root package exports the library; `Demo/` is a separate package with the `progress-demo` executable and its own external dependencies

## Claude Code Skill

The API reference skill for this package lives here, in `Skills/ConsoleProgressKit/`, and is served by the public `nn-swift-skills` marketplace as `ConsoleProgressKit@nn-swift-skills`. It was moved out of `NobadiScripts` so the API and its documentation change together: **any PR that changes the public API must update `Skills/ConsoleProgressKit/` in the same PR.**

- `Skills/` is not a SwiftPM target; it ships only through the marketplace.
- `Skills/ConsoleProgressKit/.claude-plugin/plugin.json` deliberately has **no `version` field**. The marketplace pins the skill to a git tag, and the plugin cache is keyed by commit sha. Do not reintroduce a version; a hand-typed number nothing verifies is the staleness this arrangement removes.
- `manifest.json` records the commit, source hashes, and type anchors the docs were generated from; regenerate it when the docs are regenerated.

## Releasing

The `nn-swift-skills` entry for this skill is pinned to a release tag (`ref`), not to a branch. **Skill changes reach users when a release is tagged, not when they merge.** A doc fix merged to `main` is invisible until the next tag.

`.github/workflows/skill-ref-bump.yml` keeps the pin current: on every tag push it rewrites the entry's `ref` in `nikolainobadi/nn-swift-skills` and opens a PR there. If that workflow is ever removed, the bump becomes manual. Forgetting it fails silently — the marketplace keeps serving the previous release's docs forever, with nothing erroring and nothing warning.

The workflow authenticates with the repo secret **`MARKETPLACE_TOKEN`**: a fine-grained PAT named `nn-swift-skills-ref-bump`, scoped to `nn-swift-skills` only (Contents and Pull requests, read and write), **expiring 2027-08-15**. It is shared with every other package repo publishing to that marketplace, so rotating it means re-setting the secret in each of them. When it expires, the workflow fails on tag push; treat that as "rotate the shared token", not "this repo's workflow is broken."
