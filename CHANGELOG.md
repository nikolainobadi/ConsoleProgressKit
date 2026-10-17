# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/nikolainobadi/ConsoleProgressKit/releases/tag/v0.4.0
