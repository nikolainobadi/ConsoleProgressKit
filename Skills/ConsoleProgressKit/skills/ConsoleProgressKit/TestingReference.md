# ConsoleProgressKit Testing Reference

Test helpers for code that takes `any ProgressDisplay`. Add the `ConsoleProgressTesting` product to a test target and `import ConsoleProgressTesting`; it re-exports `ConsoleProgressKit`, so no second import is needed.

```swift
.testTarget(
    name: "MyToolTests",
    dependencies: [
        "MyTool",
        .product(name: "ConsoleProgressTesting", package: "ConsoleProgressKit")
    ]
)
```

Requires ConsoleProgressKit `0.6.0` or later.

## Contents

- Class: MockProgressDisplay
- Struct: RecordedActivity
- Enum: RecordedUpdate
- Enum: RecordedOutcome
- Struct: RecordedNote
- Complete Example
- Best Practices

---

<!-- type:MockProgressDisplay -->
## Class: MockProgressDisplay

A `ProgressDisplay` for tests that writes nothing to stderr or stdout and records everything it is asked to show.

```swift
public final class MockProgressDisplay: Sendable
extension MockProgressDisplay: ProgressDisplay
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init()` | Creates a display with nothing recorded. There is no reset; create a new mock per test. |

### Properties

All read-only.

| Property | Type | Description |
|----------|------|-------------|
| `activities` | `[RecordedActivity]` | One per `track(_:operation:)` call, in the order they started. |
| `trackedTitles` | `[String]` | The titles of `activities`, in the order they started. |
| `notes` | `[RecordedNote]` | Every `note(_:style:)` call, in order. |
| `writtenOutput` | `[String]` | Every `writeOutput(_:)` text exactly as supplied, in order. No newline is added or removed. |
| `suspensionCount` | `Int` | How many times `suspended(_:)` ran its body. |
| `terminalWasRestored` | `Bool` | Whether `restoreTerminal()` was called. |

### Behavior

| Method | Mock behavior |
|--------|---------------|
| `track(_:operation:)` | Records a new activity, then runs `operation` with a working `ActivityHandle` whose updates are recorded on that activity. Marks it `.succeeded` or `.failed`, then returns the value or rethrows the error unchanged. |
| `note(_:style:)` | Records the note. Writes nothing. |
| `suspended(_:)` | Increments `suspensionCount`, runs `body`, and returns its result or rethrows its error. |
| `writeOutput(_:)` | Records the text. Writes nothing to stdout. |
| `restoreTerminal()` | Sets `terminalWasRestored`. Recording continues afterwards, unlike the real displays, so work that runs after an interrupt cleanup is still visible. |

- Concurrent `track` calls each record their own activity in the order they started, and each handle records only on its own activity. Two activities with the same title stay separate.
- An activity's `outcome` is `nil` while its operation is still running.
- No elapsed time is recorded, and the mock injects no errors of its own; an operation's own errors pass through.
- State is behind a `Mutex`, so the mock is safe to share across concurrent tasks.

### Usage Example

```swift
let display = MockProgressDisplay()
let uploader = Uploader(display: display)

try await uploader.upload(["a.zip", "b.zip"])

#expect(display.activities == [
    RecordedActivity(
        title: "Uploading",
        updates: [.progress(completed: 1, total: 2), .progress(completed: 2, total: 2)],
        outcome: .succeeded
    )
])
```
<!-- /type:MockProgressDisplay -->

---

<!-- type:RecordedActivity -->
## Struct: RecordedActivity

One `track(_:operation:)` call recorded by `MockProgressDisplay`.

```swift
public struct RecordedActivity: Sendable, Equatable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(title: String, updates: [RecordedUpdate], outcome: RecordedOutcome?)` | Builds an expected value to compare against `activities`. |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `String` | The title passed to `track`. |
| `updates` | `[RecordedUpdate]` | Every update the activity's handle sent, in order. Read-only. |
| `outcome` | `RecordedOutcome?` | How the activity finished, or `nil` while it is still running. Read-only. |
<!-- /type:RecordedActivity -->

---

<!-- type:RecordedUpdate -->
## Enum: RecordedUpdate

One update sent through an `ActivityHandle`.

```swift
public enum RecordedUpdate: Sendable, Equatable
```

### Cases

| Case | Associated Values | Sent by |
|------|-------------------|---------|
| `detail` | `String?` | `update(detail:)`, including `nil` |
| `waiting` | — | `markWaiting()` |
| `running` | — | `markRunning()` |
| `output` | `String` | `output(line:)` |
| `progress` | `completed: Int, total: Int` | `progress(completed:total:)`, numbers as given |
<!-- /type:RecordedUpdate -->

---

<!-- type:RecordedOutcome -->
## Enum: RecordedOutcome

How a recorded activity finished.

```swift
public enum RecordedOutcome: Sendable, Equatable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `succeeded` | — | The operation returned a value. |
| `failed` | — | The operation threw an error, including `CancellationError`. The error is not stored; assert on it where `track` rethrows it. |
<!-- /type:RecordedOutcome -->

---

<!-- type:RecordedNote -->
## Struct: RecordedNote

One `note(_:style:)` call recorded by `MockProgressDisplay`.

```swift
public struct RecordedNote: Sendable, Equatable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(text: String, style: NoteStyle)` | Builds an expected value to compare against `notes`. |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `text` | `String` | The note's text. |
| `style` | `NoteStyle` | `.info` or `.warning`. |
<!-- /type:RecordedNote -->

---

## Complete Example

```swift
import Testing
import ConsoleProgressTesting
@testable import MyTool

struct ReleasePublisherTests {
    @Test
    func `Publishing reports each step as a detail`() async throws {
        let (sut, display) = makeSUT()

        try await sut.publish(version: "1.3.0")

        let activity = try #require(display.activities.first)
        #expect(activity.updates == [.detail("pushing branch"), .detail("pushing tag")])
    }

    @Test
    func `A failed push is reported as a failed activity`() async throws {
        let (sut, display) = makeSUT()

        _ = try? await sut.publish(version: "bad")

        let activity = try #require(display.activities.first)
        #expect(activity.outcome == .failed)
    }

    @Test
    func `The published version is written to stdout`() async throws {
        let (sut, display) = makeSUT()

        try await sut.publish(version: "1.3.0")

        #expect(display.writtenOutput == ["1.3.0"])
    }
}

// MARK: - SUT
private extension ReleasePublisherTests {
    func makeSUT() -> (sut: ReleasePublisher, display: MockProgressDisplay) {
        let display = MockProgressDisplay()
        let sut = ReleasePublisher(display: display)

        return (sut, display)
    }
}
```

---

## Best Practices

- **Inject the mock where `any ProgressDisplay` is expected** — It needs no configuration; the work under test runs exactly as it would with a real display.
- **Compare whole values** — Every recorded type is `Equatable` and has a public initializer, so build the expected `RecordedActivity` or `RecordedNote` and compare with `==`.
- **Assert on errors where `track` rethrows them** — `RecordedOutcome.failed` says only that the operation threw.
- **Don't capture stdout or stderr** — The mock writes nothing; assert on `writtenOutput` and `notes` instead.
- **Find activities by title only when titles are unique** — Concurrent activities are recorded in start order, which may vary between runs; matching by title is stable when each title is used once.
- **Use a new mock per test** — There is no reset method.
