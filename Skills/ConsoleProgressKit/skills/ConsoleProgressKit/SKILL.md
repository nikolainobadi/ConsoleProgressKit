---
name: ConsoleProgressKit
description: ConsoleProgressKit Swift API reference for showing progress in command-line tools — live spinners, progress bars, and plain log lines on stderr. USE WHEN using ConsoleProgressKit, ProgressDisplay, LiveProgressDisplay, PlainProgressDisplay, ActivityHandle, track(_:operation:), NoteStyle, ProgressTheme, TerminalColor, TerminalCapabilities, TerminalStream, TextStyle, TextStyler, AnsiTextStyler, PlainTextStyler, ConsoleProgressTesting, MockProgressDisplay, RecordedActivity, TaggingTextStyler, OR adding spinners, progress bars, or progress output to a Swift CLI, OR choosing spinner, progress bar, or status symbol colors, OR coloring or styling a Swift CLI's final output, OR honoring NO_COLOR, OR testing code that reports progress through a ProgressDisplay.
---

# ConsoleProgressKit

Shows what a long-running Swift command is doing: animated spinner lines on an interactive terminal, or plain one-line-per-event output for pipes and CI, always on stderr so stdout stays clean.

**Dependency:** `.package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "0.8.0")`
**Products:** `ConsoleProgressKit` (production), `ConsoleProgressTesting` (test helpers, 0.6.0+)
**Platforms:** macOS 15+ | **Swift:** 6.2+
<!-- package_path: /Users/nelixpro/Desktop/ConsoleProgressKit -->

## Context Files

Paths are relative to this skill's directory.

| File | Read when the task involves | Read before | Coverage | Governs |
|------|-----------------------------|-------------|----------|---------|
| `ApiReference.md` | `ProgressDisplay`, `LiveProgressDisplay`, `PlainProgressDisplay`, `ActivityHandle`, `NoteStyle`, `ProgressTheme`, `TerminalColor`, `TerminalCapabilities`, `TerminalStream`, `TerminalSize`, `TextStyle`, `TextStyler`, `AnsiTextStyler`, `PlainTextStyler`, or `import ConsoleProgressKit` | writing or suggesting code that uses these types | whole file | signatures, display behavior, output formats, and usage rules |
| `TestingReference.md` | writing or editing tests for code that takes `any ProgressDisplay`, `MockProgressDisplay`, `RecordedActivity`, `RecordedUpdate`, `RecordedOutcome`, `RecordedNote`, `TaggingTextStyler`, or `import ConsoleProgressTesting` | writing test code or asserting on recorded progress | whole file | mock behavior, recorded state, and test usage |

If a listed file cannot be read, say so and do not guess signatures, parameter labels, or behavior for the types it covers; answer only from what is available.

## Quick Reference

### Production
- **Entry point:** construct `LiveProgressDisplay()` when `TerminalCapabilities.standardErrorIsTerminal` is true, otherwise `PlainProgressDisplay()`; pass it around as `any ProgressDisplay`.
- **Colors (0.7.0+):** use `LiveProgressDisplay(theme:)` with a `ProgressTheme` to choose the spinner, progress bar, and ✓/✗/`!` colors from the 16 `TerminalColor` values.
- **Color settings (0.8.0+):** the live display drops colors and dimming under `NO_COLOR`, `TERM=dumb`, or a redirected stderr, even with an explicit theme.
- **Style final output (0.8.0+):** get a styler from `TerminalCapabilities.textStyler(for: .standardOutput)` and call `styled(_:as:)`; styles don't nest.
- **Track work:** `try await display.track("Title") { activity in ... }` shows the activity, then `✓`/`✗` with elapsed time, and returns or rethrows the operation's result.
- **Report from inside:** `activity.update(detail:)`, `output(line:)`, `progress(completed:total:)`, `markWaiting()`, `markRunning()`.
- **Keep the screen intact:** results go through `writeOutput(_:)`, prompts go inside `suspended { }`, and `restoreTerminal()` runs on Ctrl-C.

### Testing
- **Mock:** pass `MockProgressDisplay()` wherever code takes `any ProgressDisplay`; it writes nothing and runs operations with a working handle.
- **Assert:** compare `activities` (title, updates, outcome), `notes`, `writtenOutput`, `suspensionCount`, and `terminalWasRestored` against expected values.
- **Styled text (0.8.0+):** inject `TaggingTextStyler()` and compare the full `<name>text</name>` message.

## Examples

- "Add a spinner while my CLI uploads files" -> Loads `ApiReference.md` (`track(_:operation:)`, `progress(completed:total:)`)
- "Why does my prompt get drawn over by the progress output?" -> Loads `ApiReference.md` (`suspended(_:)`)
- "Show build log lines under the running step" -> Loads `ApiReference.md` (`output(line:)`)
- "Make my CLI's spinner cyan" -> Loads `ApiReference.md` (`ProgressTheme`, `LiveProgressDisplay(theme:)`)
- "Color my CLI's final report" -> Loads `ApiReference.md` (`TextStyle`, `TextStyler`, `TerminalCapabilities.textStyler(for:)`)
- "How do I test that my command reports upload progress?" -> Loads `TestingReference.md` (`MockProgressDisplay`, `RecordedActivity`)
