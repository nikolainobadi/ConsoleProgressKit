# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Add `TerminalCapabilities.supportsColor(on:)` and `TerminalStream` to check whether stdout or stderr should receive styled text
- Add `TextStyle` with 11 standard styles, and `TextStyler` with `AnsiTextStyler` and `PlainTextStyler`, to style a command's final output; get the right styler from `TerminalCapabilities.textStyler(for:)`
- Add `successLine(_:)`, `warningLine(_:)`, and `failureLine(_:)` on `TextStyler`
- Add `TaggingTextStyler` to `ConsoleProgressTesting` for asserting on styled text

### Changed
- `LiveProgressDisplay` no longer draws colors or dimming when `NO_COLOR` is set to a non-empty value, `TERM` is `dumb`, or stderr isn't a terminal, even with an explicit `ProgressTheme`

## [0.7.0] - 2026-11-03

### Added
- Add `LiveProgressDisplay(theme:)` and `ProgressTheme` to choose the colors of the live display's spinner, progress bar fill, and `✓`, `✗`, and `!` symbols; `LiveProgressDisplay()` keeps its current colors
- Add `TerminalColor` with the 16 named ANSI colors

### Fixed
- Fix a crash in the live display's progress bar when `progress(completed:total:)` reports extremely large counts

## [0.6.0] - 2026-10-21

### Added
- Add the `ConsoleProgressTesting` library product with `MockProgressDisplay` for testing code that uses `ProgressDisplay` without terminal output; add the product to your test target's dependencies
- Record activity titles, ordered handle updates, success or failure outcomes, notes, output text, prompt suspension counts, and terminal restoration calls for assertions, while preserving tracked operations' return values and thrown errors

## [0.5.0] - 2026-10-17

### Added
- Add `ProgressDisplay` with `track(_:operation:)` to report an asynchronous operation's success or failure and elapsed time while preserving its return value or thrown error
- Add `LiveProgressDisplay` with concurrent activity spinners, terminal-sized layouts, recent output tails, and retained output on failure
- Add `PlainProgressDisplay` for line-oriented progress without animation or generated ANSI escape codes in pipes and logs
- Add `ActivityHandle` updates for detail text, waiting/running states, output lines, and step-count progress
- Add informational and warning notes, `suspended(_:)` for prompts, `writeOutput(_:)` for stdout results, and `restoreTerminal()` to stop display output and restore the live terminal
- Add `TerminalCapabilities` to inspect whether stderr is a terminal and read its dimensions

### Changed
- Write progress to stderr instead of stdout; read progress from stderr and use `writeOutput(_:)` for command results on stdout (breaking)
- Require Swift 6.2 and macOS 15; upgrade the toolchain and macOS deployment target before adopting this release (breaking)

### Removed
- Remove `ConsoleProgressBar` and `ConsoleColor`, including configurable bar width and color; migrate to `LiveProgressDisplay` or `PlainProgressDisplay`, wrap work in `track(_:operation:)`, and report progress through `ActivityHandle.progress(completed:total:)` (breaking)

## [0.4.0] - 2025-11-14

### Added
- Initial release with `ConsoleProgressBar`, a colorized in-place progress bar for command-line tools
- Add configurable bar width and color through `init(width:color:)`
- Add `updateProgress(current:total:message:detail:)` with an optional detail line under the bar
- Add `complete(message:)` to print a final completion line
- Add `ConsoleColor` with green, yellow, blue, magenta, and cyan options
- Require Swift 6.0

[Unreleased]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/0.7.0...HEAD
[0.7.0]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/nikolainobadi/ConsoleProgressKit/releases/tag/v0.4.0
