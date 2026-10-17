# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2025-11-14

### Added
- Initial release with `ConsoleProgressBar`, a colorized in-place progress bar for command-line tools
- Add configurable bar width and color through `init(width:color:)`
- Add `updateProgress(current:total:message:detail:)` with an optional detail line under the bar
- Add `complete(message:)` to print a final completion line
- Add `ConsoleColor` with green, yellow, blue, magenta, and cyan options
- Require Swift 6.0

[Unreleased]: https://github.com/nikolainobadi/ConsoleProgressKit/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/nikolainobadi/ConsoleProgressKit/releases/tag/v0.4.0
