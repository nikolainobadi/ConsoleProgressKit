# ConsoleProgressKit

[![Swift](https://img.shields.io/badge/Swift-6.1-purple)](https://swift.org)
![Platform](https://img.shields.io/badge/platform-macOS-blue)
![License](https://img.shields.io/badge/license-MIT-lightgray)

---

## Overview

**ConsoleProgressKit** is a lightweight, colorized command-line progress bar for Swift applications. Designed for clarity and minimalism, it enhances CLI tools by providing a visual indicator of task progress with optional messages and detail lines.

---

## Features

- Customizable width and color
- Clean ANSI-style progress bar
- Multi-line updates with optional detail messages
- Minimal dependencies (none)

---

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
.package(url: "https://github.com/nikolainobadi/ConsoleProgressKit", from: "0.3.0")
```

Then add `"ConsoleProgressKit"` as a dependency for your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["ConsoleProgressKit"]
)
```

---

## Usage

```swift
import ConsoleProgressKit

let progressBar = ConsoleProgressBar(width: 40, color: .cyan)

for i in 1...100 {
    progressBar.updateProgress(
        current: i,
        total: 100,
        message: "Processing items...",
        detail: "Item \(i) of 100"
    )
    usleep(50000) // Simulate work
}

progressBar.complete(message: "All tasks completed.")
```

---

## Architecture Notes

- `ConsoleProgressBar` handles rendering and state management.
- `ConsoleColor` is a simple enum for ANSI color codes.
- Terminal output is updated in-place using escape sequences.

---

## Documentation

This project is documented via inline comments. For more detailed docs in future versions, see the [GitHub Wiki](https://github.com/nikolainobadi/ConsoleProgressKit/wiki) or consider a `Docs/` folder in later releases.

---

## Acknowledgments

ConsoleProgressKit uses:

- ANSI escape codes for cursor control and coloring
- `fflush(stdout)` to ensure timely terminal updates

No third-party libraries are used.

---

## About This Project

ConsoleProgressKit was built to streamline progress tracking for CLI Swift tools. It aims to provide an elegant, user-friendly way to visualize progress without external dependencies or heavy setup.

---

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests on [GitHub](https://github.com/nikolainobadi/ConsoleProgressKit).

---

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
