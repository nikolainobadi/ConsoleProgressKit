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

**Text styling** (`Sources/ConsoleProgressKit/Styling/`)
- `TextStyle` describes how text looks; `TextStyler` applies it through `AnsiTextStyler` or `PlainTextStyler`
- `TerminalCapabilities.supportsColor(on:)` decides whether a `TerminalStream` gets styling, and `textStyler(for:)` picks the matching styler
- Numeric escape codes live only in `TerminalStyle` and `TerminalColor`
- `TaggingTextStyler` (`ConsoleProgressTesting`) tags text with style names for tests

**MockProgressDisplay** (`Sources/ConsoleProgressTesting/MockProgressDisplay.swift`)
- Ships in the separate `ConsoleProgressTesting` product, which re-exports `ConsoleProgressKit`
- Writes nothing; records activities (title, `RecordedUpdate`s, `RecordedOutcome`), notes, written output, suspensions, and terminal restoration
- Runs tracked operations and passes through their values and errors; recording continues after `restoreTerminal()`
- Creates working handles through `ActivityHandle`'s `package` initializer, so the handle stays without a public initializer

### Key Design Patterns

1. **Terminal Output Management**: Callers choose the live or plain display; `TerminalCapabilities.standardErrorIsTerminal` exposes stderr terminal detection. Progress and notes use stderr, while `writeOutput(_:)` writes results to stdout without disrupting the live region.

2. **Stateful Rendering**: Live activity updates change state and are drawn on the next timer tick. Finished activities and notes appear above the running region. `suspended(_:)` clears the region for synchronous prompts and redraws it afterward.

3. **Public API Surface**:
   - `LiveProgressDisplay()` / `PlainProgressDisplay()` - Create a display
   - `LiveProgressDisplay(theme:)` - Create a live display with a `ProgressTheme` of `TerminalColor` values for its spinner, progress bar, and ✓/✗/`!` symbols
   - `track(_:operation:)` - Run an async operation with an `ActivityHandle`, report its outcome and elapsed time, return its value, and rethrow its errors
   - `note(_:style:)` - Print a note
   - `restoreTerminal()` - Permanently stop live/plain display output; subsequent tracked operations still execute. The mock records the call without stopping recording
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

## Releasing

The `nn-swift-skills` entry for this skill is pinned to a release tag (`ref`), not to a branch. **Skill changes reach users when a release is tagged, not when they merge.** A doc fix merged to `main` is invisible until the next tag.

Release with `nnex ship package` and choose this skill when asked; `.nnex/nnex.json` doesn't name one. Shipping with the skill pins the marketplace `ref` to the new tag and refreshes installed copies. Choosing no skill or passing `--no-skill` skips the pin, which fails silently: the marketplace keeps serving the previous release's docs, with nothing erroring and nothing warning.
