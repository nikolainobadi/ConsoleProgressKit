# ConsoleProgressKit

![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-macOS-blueviolet.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

## Overview

ConsoleProgressKit is a lightweight Swift Package Manager library providing colorized command-line progress bars for Swift CLI applications. It uses ANSI escape sequences for terminal manipulation and has zero external dependencies.

## Features

- **In-place progress updates** using ANSI escape sequences
- **Colorized output** with customizable colors (green, yellow, blue, magenta, cyan)
- **Dynamic display** supporting 2 or 3 line layouts with optional detail messages
- **Stateful rendering** for smooth multi-line terminal updates
- **Zero dependencies** - pure Swift implementation
- **Simple API** - initialize, update, complete

## Requirements

- Swift 6.0+
- macOS (relies on terminal ANSI support)

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "1.0.0")
]
```

Then include it in your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ConsoleProgressKit"]
)
```

## Usage

```swift
import ConsoleProgressKit

// Create a progress bar with custom width and color
let progressBar = ConsoleProgressBar(width: 50, color: .green)

// Update progress with a message
for i in 1...100 {
    progressBar.updateProgress(
        current: i,
        total: 100,
        message: "Processing items..."
    )
    // Your work here
}

// Mark as complete
progressBar.complete(message: "All items processed!")
```

### With Optional Detail Line

```swift
let progressBar = ConsoleProgressBar(width: 50, color: .blue)

for i in 1...files.count {
    progressBar.updateProgress(
        current: i,
        total: files.count,
        message: "Processing files...",
        detail: "Current: \(files[i-1].name)"
    )
    // Process file
}

progressBar.complete(message: "File processing complete!")
```

### Available Colors

The `ConsoleColor` enum provides:
- `.green` (default)
- `.yellow`
- `.blue`
- `.magenta`
- `.cyan`

## Architecture

### Core Components

**ConsoleProgressBar**
- Main public API for progress tracking
- Manages terminal state and cursor positioning
- Renders progress using ANSI escape sequences (`\u{1B}[2K` for line clearing, `\u{1B}[nA` for cursor movement)
- Dynamically handles 2 or 3 line displays based on optional detail parameter

**ConsoleColor**
- Enum wrapping ANSI color codes
- Provides color options for progress bar and text emphasis

### Terminal Output Management

Progress updates render in-place by:
1. Moving cursor up to previous lines
2. Clearing each line before writing new content
3. Flushing stdout to ensure immediate display

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
