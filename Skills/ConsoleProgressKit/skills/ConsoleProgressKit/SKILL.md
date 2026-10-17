---
name: ConsoleProgressKit
description: ConsoleProgressKit Swift API reference for showing progress in command-line tools — live spinners, progress bars, and plain log lines on stderr. USE WHEN using ConsoleProgressKit, ProgressDisplay, LiveProgressDisplay, PlainProgressDisplay, ActivityHandle, track(_:operation:), NoteStyle, TerminalCapabilities, OR adding spinners, progress bars, or progress output to a Swift CLI.
---

# ConsoleProgressKit

Shows what a long-running Swift command is doing: animated spinner lines on an interactive terminal, or plain one-line-per-event output for pipes and CI, always on stderr so stdout stays clean.

**Dependency:** `.package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "0.5.0")`
**Platforms:** macOS 15+ | **Swift:** 6.2+
<!-- package_path: /Users/nelixpro/Desktop/ConsoleProgressKit -->

## Context Files

Paths are relative to this skill's directory.

| File | Read when the task involves | Read before | Coverage | Governs |
|------|-----------------------------|-------------|----------|---------|
| `ApiReference.md` | `ProgressDisplay`, `LiveProgressDisplay`, `PlainProgressDisplay`, `ActivityHandle`, `NoteStyle`, `TerminalCapabilities`, `TerminalSize`, or `import ConsoleProgressKit` | writing or suggesting code that uses these types | whole file | signatures, display behavior, output formats, and usage rules |

If a listed file cannot be read, say so and do not guess signatures, parameter labels, or behavior for the types it covers; answer only from what is available.

## Quick Reference

- **Entry point:** construct `LiveProgressDisplay()` when `TerminalCapabilities.standardErrorIsTerminal` is true, otherwise `PlainProgressDisplay()`; pass it around as `any ProgressDisplay`.
- **Track work:** `try await display.track("Title") { activity in ... }` shows the activity, then `✓`/`✗` with elapsed time, and returns or rethrows the operation's result.
- **Report from inside:** `activity.update(detail:)`, `output(line:)`, `progress(completed:total:)`, `markWaiting()`, `markRunning()`.
- **Keep the screen intact:** results go through `writeOutput(_:)`, prompts go inside `suspended { }`, and `restoreTerminal()` runs on Ctrl-C.

## Examples

- "Add a spinner while my CLI uploads files" -> Loads `ApiReference.md` (`track(_:operation:)`, `progress(completed:total:)`)
- "Why does my prompt get drawn over by the progress output?" -> Loads `ApiReference.md` (`suspended(_:)`)
- "Show build log lines under the running step" -> Loads `ApiReference.md` (`output(line:)`)
