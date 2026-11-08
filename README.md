# ConsoleProgressKit

![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blueviolet.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## Overview

ConsoleProgressKit is a lightweight Swift Package Manager library providing activity tracking, spinners, and progress bars for Swift CLI applications. It offers an animated terminal display and plain output for logs and pipes, with zero external dependencies.

## Features

- **In-place activity updates** with animated spinners and progress bars
- **Concurrent activities** with individual details, waiting states, and output tails
- **Automatic outcomes** showing success or failure and elapsed time
- **Custom colors** for the live display's spinner, progress bars, and status symbols
- **Honors `NO_COLOR`** and turns off color and dimming on dumb terminals and redirected streams
- **Styled command output** with standard and custom text styles
- **Plain output** without animation or escape codes for logs and pipes
- **Separate output streams** - progress on stderr and command results on stdout
- **Zero dependencies** - pure Swift implementation
- **Simple API** - track an operation and report updates through its activity handle
- **Testing support** - record activities, updates, and outcomes with `MockProgressDisplay`

## Requirements

- Swift 6.2+
- macOS 15+ (the live display requires terminal ANSI support)

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "0.7.0")
```

Then include it in your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ConsoleProgressKit"]
)
```

## Usage

Choose a display based on whether stderr is attached to a terminal. Run `track` from an async throwing context:

```swift
import ConsoleProgressKit

let display: any ProgressDisplay = TerminalCapabilities.standardErrorIsTerminal
    ? LiveProgressDisplay()
    : PlainProgressDisplay()

try await display.track("Processing items") { activity in
    for i in 1...100 {
        // Your work here
        activity.progress(completed: i, total: 100)
    }
}

display.writeOutput("All items processed!")
```

`track` returns the operation's result and automatically reports success or failure with elapsed time. Errors thrown by the operation are rethrown unchanged.

### With Optional Detail Line

Using the same `display`, report the current item and any activity output:

```swift
let files = ["first.txt", "second.txt"]

try await display.track("Processing files") { activity in
    for (index, file) in files.enumerated() {
        activity.update(detail: "Current: \(file)")
        // Process file
        activity.output(line: "Processed \(file)")
        activity.progress(completed: index + 1, total: files.count)
    }
}

display.writeOutput("File processing complete!")
```

Details are omitted from the finished activity line. The live display shows recent output beneath running activities and more output if an activity fails; the plain display prints every output line. Use `markWaiting()` and `markRunning()` on the activity handle to indicate queued work.

### Notes and Terminal Interaction

Use `display.note("Message", style: .info)` for informational notes or `.warning` for warnings. The live display colors the symbols for outcomes and warnings; the plain display emits no escape codes.

Wrap synchronous prompts in `display.suspended { ... }` to clear running activities while reading input, then redraw them. Use `writeOutput(_:)` for command results on stdout while progress remains on stderr.

Call `restoreTerminal()` when ending early to erase running activities, reset colors, and show the cursor. This permanently stops display output; it does not cancel the tracked operations.

### Custom Colors

Pass a `ProgressTheme` when creating a live display to choose its colors from the 16 named ANSI colors in `TerminalColor`. The theme applies for the display's whole lifetime:

```swift
let theme = ProgressTheme(
    spinner: .cyan,
    progressBar: .brightBlue,
    success: .green,
    failure: .red,
    warning: .yellow
)
let display = LiveProgressDisplay(theme: theme)
```

Pass `nil` for `spinner` or `progressBar` to use the terminal's default foreground color. `LiveProgressDisplay()` uses `ProgressTheme.standard`: no spinner or bar color, green success, red failure, and yellow warnings.

A theme colors the spinner, the progress bar's filled cells, and the `✓`, `✗`, and `!` symbols. Titles, details, and info notes keep the default foreground color, and waiting lines and output tails stay dim. `PlainProgressDisplay` and `MockProgressDisplay` don't take a theme.

The live display leaves out colors and dimming, even with an explicit theme, when `NO_COLOR` is set to a non-empty value, `TERM` is `dumb`, or stderr isn't a terminal.

### Styling Text

Style a command's final output with the same rules. `TerminalCapabilities.textStyler(for:)` returns a styler that writes escape codes when the stream supports color and plain text when it doesn't. Choose the stream the text goes to: `.standardOutput` for `writeOutput(_:)` and `.standardError` for `note(_:style:)`.

```swift
let styler = TerminalCapabilities.textStyler(for: .standardOutput)

display.writeOutput(styler.styled("Release 1.3.0", as: .title))
display.writeOutput(styler.successLine("Published"))
```

The standard styles are `title`, `heading`, `added`, `deleted`, `muted`, `standout`, `success`, `warning`, `failure`, `command`, and `url`. `successLine(_:)`, `warningLine(_:)`, and `failureLine(_:)` add an emoji outside the styled text.

Add your own styles in a `TextStyle` extension, and call them the same way:

```swift
extension TextStyle {
    static let ticketID = TextStyle(name: "ticketID", color: .yellow, isBold: false, isDim: false, isUnderlined: false)
}

display.writeOutput(styler.styled("PROJ-42", as: .ticketID))
```

Styles don't nest, because every span ends with a full reset. Style adjacent pieces separately and join the results:

```swift
let line = styler.styled("Ticket ", as: .heading) + styler.styled("PROJ-42", as: .ticketID)
```

## Testing

The `ConsoleProgressTesting` product provides `MockProgressDisplay`, a display that writes nothing and records what your code reported. Add it to a test target:

```swift
.testTarget(
    name: "YourTargetTests",
    dependencies: [
        "YourTarget",
        .product(name: "ConsoleProgressTesting", package: "ConsoleProgressKit")
    ]
)
```

Pass it wherever your code takes `any ProgressDisplay`, then assert on what was recorded:

```swift
import Testing
import ConsoleProgressTesting

let display = MockProgressDisplay()
try await Uploader(display: display).upload(["a.zip", "b.zip"])

#expect(display.activities == [
    RecordedActivity(
        title: "Uploading",
        updates: [.progress(completed: 1, total: 2), .progress(completed: 2, total: 2)],
        outcome: .succeeded
    )
])
```

The mock also records notes, `writeOutput(_:)` text, prompt suspensions, and whether `restoreTerminal()` was called.

To check styled text, inject `TaggingTextStyler`, which wraps text as `<name>text</name>`, and compare the full message.

## Architecture

### Core Components

**ProgressDisplay**
- Common public API for tracking operations, notes, prompts, command output, and terminal restoration
- Implemented by `LiveProgressDisplay`, `PlainProgressDisplay`, and `MockProgressDisplay` (in `ConsoleProgressTesting`)

**ActivityHandle**
- Reports details, progress counts, waiting states, and activity output
- Passed to each operation by `track`

**TerminalCapabilities**
- Reports whether stderr is a terminal, its available dimensions, and whether a stream supports color
- Lets callers select the appropriate display and text styler

**ProgressTheme**
- Holds the `TerminalColor` values `LiveProgressDisplay` uses for its spinner, progress bars, and status symbols
- Set when the display is created

**TextStyle and TextStyler**
- `TextStyle` describes how text looks; `TextStyler` applies it
- `AnsiTextStyler` writes escape codes and `PlainTextStyler` returns text unchanged

### Terminal Output Management

The live display keeps running activities in a shared region on stderr:
1. A timer redraws spinners and activity updates in place using ANSI escape sequences
2. Finished activities and notes appear above the running region
3. Lines fit the terminal width, and output tails or activities collapse when space is limited

The plain display writes activity starts, updates, and outcomes to stderr without animation. Both displays write command results to stdout through `writeOutput(_:)`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
