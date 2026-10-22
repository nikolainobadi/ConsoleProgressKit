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
.package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "0.6.0")
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

Use `display.note("Message", style: .info)` for informational notes or `.warning` for warnings. The live display uses colors for outcomes and warnings; the plain display emits no escape codes.

Wrap synchronous prompts in `display.suspended { ... }` to clear running activities while reading input, then redraw them. Use `writeOutput(_:)` for command results on stdout while progress remains on stderr.

Call `restoreTerminal()` when ending early to erase running activities, reset colors, and show the cursor. This permanently stops display output; it does not cancel the tracked operations.

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

## Architecture

### Core Components

**ProgressDisplay**
- Common public API for tracking operations, notes, prompts, command output, and terminal restoration
- Implemented by `LiveProgressDisplay`, `PlainProgressDisplay`, and `MockProgressDisplay` (in `ConsoleProgressTesting`)

**ActivityHandle**
- Reports details, progress counts, waiting states, and activity output
- Passed to each operation by `track`

**TerminalCapabilities**
- Reports whether stderr is a terminal and its available dimensions
- Lets callers select the appropriate display

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
