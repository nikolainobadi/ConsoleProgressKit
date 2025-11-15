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

- Swift 6.0+ required (see Package.swift)
- Platform: macOS (relies on terminal ANSI support)
- No test target currently exists in Package.swift
- Library product is the only build output
