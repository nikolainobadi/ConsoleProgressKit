# ConsoleProgressKit API

Shows what a long-running Swift command is doing. `ProgressDisplay` and its two displays — `LiveProgressDisplay` for interactive terminals, `PlainProgressDisplay` for pipes, logs, and CI — plus how a running activity reports what it is doing (`ActivityHandle`), how notes are marked (`NoteStyle`), and how to tell whether stderr is a terminal (`TerminalCapabilities`, `TerminalSize`).

## Contents

- Protocol: ProgressDisplay
- ProgressDisplay Implementations
- Class: LiveProgressDisplay
- Class: PlainProgressDisplay
- Struct: ActivityHandle
- Enum: NoteStyle
- Enum: TerminalCapabilities
- Struct: TerminalSize
- Best Practices

---

<!-- type:ProgressDisplay -->
## Protocol: ProgressDisplay

Shows the user what a long-running command is doing. Progress is written to stderr so a command's results on stdout stay clean for pipes.

```swift
public protocol ProgressDisplay: Sendable
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `track<T>(_ title: String, operation: (ActivityHandle) async throws -> T) async throws -> T` | `T` | Shows `title` while `operation` runs, then marks it ✓ or ✗ with the elapsed time. Returns the operation's value; rethrows its error unchanged after the ✗ line is shown. |
| `note(_ text: String, style: NoteStyle)` | `Void` | Prints `text` as its own line, marked by `style`, above any activity that is still running. |
| `suspended<T>(_ body: () throws -> T) rethrows -> T` | `T` | Clears running activities from the screen while `body` runs, then redraws them. Wrap prompts and other user input. |
| `writeOutput(_ text: String)` | `Void` | Writes `text` and a newline to stdout without breaking up running activities. Use for a command's results. |
| `restoreTerminal()` | `Void` | Stops display output for good; the live display also erases running activities, resets colors, and shows the cursor. Later `track` operations and `suspended` bodies still execute, returning values or throwing errors, but the display writes nothing. |

### Usage Example

```swift
func makeDisplay() -> any ProgressDisplay {
    if TerminalCapabilities.standardErrorIsTerminal {
        return LiveProgressDisplay()
    }

    return PlainProgressDisplay()
}

let display = makeDisplay()
let summary = try await display.track("Building", operation: { activity in
    activity.update(detail: "compiling")
    return try await build()
})
display.writeOutput(summary)
```

### Shared Activity Timing

Both displays run `operation` the same way:

- The elapsed time comes from a `ContinuousClock` and is shown as seconds to one decimal place: `1.5s`, `42.0s`. There is no minutes form.
- The finished line is `✓ <title> (<elapsed>)` or `✗ <title> (<elapsed>)`. The activity's detail is never part of it.
- Any thrown error, including `CancellationError`, counts as a failure: the ✗ line is written first, then the same error is rethrown.
- The displays add no timeouts and throw nothing of their own.

```swift
do {
    try await display.track("Uploading", operation: { _ in try await upload() })
} catch {
    // "✗ Uploading (3.2s)" has already been printed; `error` is upload()'s own error
}
```

### ProgressDisplay Implementations

| Aspect | `LiveProgressDisplay` | `PlainProgressDisplay` |
|--------|-----------------------|------------------------|
| Meant for | Interactive terminals | Pipes, files, CI logs, non-interactive callers |
| Activity start | Spinner line in a region redrawn in place | `Title...` line |
| `update(detail:)` | Replaces `— detail` on the running line | New `Title — detail` line per non-nil detail; `nil` prints nothing |
| `markWaiting()` / `markRunning()` | Dim `◦ Title (waiting)` line while waiting; spinner returns when running | `Title — waiting` / `Title — started` lines |
| `output(line:)` | Last 5 lines dimmed under the activity; last 20 printed under ✗ on failure; dropped on success | Every line printed immediately, raw, no title prefix |
| `progress(completed:total:)` | 20-cell `█░` bar plus `c/t`, clamped (total of at least 1) | `Title — c/t`, raw numbers |
| `note(_:style:)` | Above the region, `!` in yellow for warnings; held while suspended | In order, uncolored |
| `suspended(_:)` | Erases the region, shows the cursor, holds finished lines and notes until resume | Just runs `body` |
| `writeOutput(_:)` | Erases the region on stderr, writes to stdout; region returns on the next tick | Writes to stdout |
| `restoreTerminal()` | Erases, shows cursor, writes `ESC[0m`, cancels timer, then silent forever | Silent forever |
| Escape codes and colors | Always on | Never |

Neither display picks itself. The caller chooses, usually with `TerminalCapabilities.standardErrorIsTerminal`.
<!-- /type:ProgressDisplay -->

<!-- type:LiveProgressDisplay -->
## Class: LiveProgressDisplay

Animates one spinner line per running activity on stderr, then replaces each with its outcome. Running activities share a region at the bottom of the output that is redrawn in place; finished ✓/✗ lines and notes print above it, so finished lines stack up in order while running ones stay below.

```swift
public final class LiveProgressDisplay: Sendable
extension LiveProgressDisplay: ProgressDisplay
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init()` | Creates a display with nothing on screen. The redraw timer starts with the first activity. |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `track<T>(_ title: String, operation: (ActivityHandle) async throws -> T) async throws -> T` | `T` | Adds a spinner line for `title`, redraws immediately, and on finish prints the ✓/✗ line above the region. |
| `note(_ text: String, style: NoteStyle)` | `Void` | Prints the note above the region and redraws it. |
| `suspended<T>(_ body: () throws -> T) rethrows -> T` | `T` | Erases the region while `body` runs; resumes even if `body` throws. |
| `writeOutput(_ text: String)` | `Void` | Erases the region on stderr, then writes `text` to stdout. |
| `restoreTerminal()` | `Void` | Erases the region, shows the cursor, resets colors, and stops drawing for good. |

### Usage Example

```swift
let display = LiveProgressDisplay()

try await withThrowingTaskGroup(of: Void.self) { group in
    for task in tasks {
        group.addTask {
            try await display.track(task.title, operation: task.operation)
        }
    }
    try await group.waitForAll()
}
```

### Redraw Timing

- A timer on a private queue redraws the region every 80 ms, so spinners keep moving even while an activity blocks its thread on a synchronous call.
- The timer starts when the first activity starts and is cancelled when none remain.
- `ActivityHandle` updates only change state; the next tick draws them. A fast stream of updates costs no more than the frame rate.
- Ticks with nothing spinning and nothing changed draw nothing, so a display whose activities are all waiting goes quiet.
- All state is behind a `Mutex`, and text is written while it is held, so writes reach the terminal in the order the state changed.

### Fitting the Terminal

The size is read from stderr on every draw (`TerminalCapabilities.standardErrorSize`):

- Region lines longer than `max(width - 1, 1)` visible characters are cut to that limit, ending with `…` and a style reset. Escape codes don't count toward the width. Every character counts as one column, so emoji and other wide characters can still overflow.
- The region uses at most `max(height - 1, 1)` lines. When it is too tall, output tails are dropped first; if the titles still don't fit, the last activities collapse into a dim `… and N more` line.
- Notes and finished lines above the region are not cut.
- When the size can't be read (not a terminal), nothing is cut or collapsed.

### Line Formats

```
⠋ Build — compiling                         running, with detail
⠙ Upload ██████████░░░░░░░░░░ 2/4 — a.zip    running, with progress and detail
◦ Test (waiting)                            waiting (dim)
    error: missing symbol                   output tail (dim, indented 4 spaces)
✓ Build (12.4s)                             finished (✓ green, ✗ red)
! Disk almost full                          warning note (! yellow)
```

Spinner frames cycle through `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`. The cursor is hidden while any activity is running and shown again when none are.

### Suspension and Stopping

- While suspended, the live region is not drawn; finished lines and notes are held and printed in order on resume. `writeOutput(_:)` still writes to stdout immediately.
- `suspended(_:)` is not meant to be nested: the inner call's resume ends the outer suspension.
- After `restoreTerminal()`, every method writes nothing, including `writeOutput`, and held lines are discarded. Activities still run, and `track` still returns their values or throws their errors.
<!-- /type:LiveProgressDisplay -->

<!-- type:PlainProgressDisplay -->
## Class: PlainProgressDisplay

Writes one line when an activity starts, one per update, and one when it finishes, with no animation or escape codes, for pipes, logs, and non-interactive callers.

```swift
public final class PlainProgressDisplay: Sendable
extension PlainProgressDisplay: ProgressDisplay
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init()` | Creates a display. It keeps no state other than whether the terminal has been restored. |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `track<T>(_ title: String, operation: (ActivityHandle) async throws -> T) async throws -> T` | `T` | Writes `Title...` to stderr, one line per update, then the uncolored ✓/✗ line. |
| `note(_ text: String, style: NoteStyle)` | `Void` | Writes the note to stderr: `text`, or `! text` for a warning. |
| `suspended<T>(_ body: () throws -> T) rethrows -> T` | `T` | Runs `body` and returns its result; there is nothing on screen to clear. |
| `writeOutput(_ text: String)` | `Void` | Writes `text` and a newline to stdout. |
| `restoreTerminal()` | `Void` | Stops all further writes. Writes no escape codes. |

### Usage Example

```swift
let display = PlainProgressDisplay()

try await display.track("Uploading release assets", operation: { activity in
    for (index, fileName) in fileNames.enumerated() {
        activity.progress(completed: index, total: fileNames.count)
        try await upload(fileName)
    }
    activity.progress(completed: fileNames.count, total: fileNames.count)
})
```

### Output Format

Everything except `writeOutput` goes to stderr:

```
Uploading release assets...
Uploading release assets — 0/3
Uploading release assets — 1/3
Uploading release assets — 2/3
Uploading release assets — 3/3
✓ Uploading release assets (1.8s)
```

- Concurrent activities interleave their lines; every line except raw `output(line:)` lines names its activity.
- Progress numbers are printed as given, with no clamping.
- Output lines are not replayed on failure, because they were already printed.
- After `restoreTerminal()`, nothing more is written, including `writeOutput`.
<!-- /type:PlainProgressDisplay -->

<!-- type:ActivityHandle -->
## Struct: ActivityHandle

Lets a running activity report what it is doing right now. A handle is passed to the `operation` closure of `ProgressDisplay.track(_:operation:)`; it has no public initializer.

```swift
public struct ActivityHandle: Sendable
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `update(detail: String?)` | `Void` | Shows `detail` after the activity's title, replacing any earlier detail; `nil` clears it. The detail is dropped from the finished ✓/✗ line. |
| `markWaiting()` | `Void` | Shows the activity as queued, such as while it waits for a free slot under a concurrency cap. |
| `markRunning()` | `Void` | Shows the activity as running again after `markWaiting()`. |
| `output(line: String)` | `Void` | Records one line of the activity's own output, such as a build log line. |
| `progress(completed: Int, total: Int)` | `Void` | Shows a progress bar for an activity made of a known number of steps. |

### Usage Example

```swift
try await display.track("Build and test", operation: { activity in
    for line in try await runBuild() {
        activity.output(line: line)
    }
})

try await display.track("Publishing 1.3.0", operation: { activity in
    for detail in ["pushing branch main", "creating tag 1.3.0", "pushing tag 1.3.0"] {
        activity.update(detail: detail)
        try await perform(detail)
    }
})
```

### How Each Display Shows Updates

| Method | Live display | Plain display |
|--------|--------------|---------------|
| `update(detail:)` | `⠋ Title — detail` on the running line | `Title — detail` line; `nil` prints nothing |
| `markWaiting()` | Dim `◦ Title (waiting)`, no spinner, no tail | `Title — waiting` |
| `markRunning()` | Spinner returns | `Title — started` |
| `output(line:)` | Last 5 shown dimmed and indented; last 20 printed under ✗ on failure | Printed immediately, raw |
| `progress(completed:total:)` | `Title ████░░… c/t`, clamped to `0...total`, total at least 1 | `Title — c/t`, unclamped |

- The live display draws updates on its next 80 ms tick, not immediately.
- The handle holds the display weakly; updates after the display is gone do nothing.
- Updates after `restoreTerminal()` do nothing.
- `markWaiting()` and `markRunning()` fit a concurrency limiter's wait and resume callbacks:

```swift
try await slots.run(onWait: activity.markWaiting, onResume: activity.markRunning, operation: { try await step() })
```
<!-- /type:ActivityHandle -->

<!-- type:NoteStyle -->
## Enum: NoteStyle

How a note is marked when it prints.

```swift
public enum NoteStyle: Sendable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `info` | — | Printed as plain text. |
| `warning` | — | Prefixed with `!`, in yellow when colors are enabled (live display only). |

### Usage Example

```swift
display.note("Using cached results.", style: .info)
display.note("Disk almost full.", style: .warning)
```
<!-- /type:NoteStyle -->

<!-- type:TerminalCapabilities -->
## Enum: TerminalCapabilities

A caseless namespace for what the terminal attached to stderr supports.

```swift
public enum TerminalCapabilities
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `standardErrorIsTerminal` | `Bool` | Whether stderr is attached to a terminal, rather than a pipe or a file. Static. |
| `standardErrorSize` | `TerminalSize?` | The size of the terminal stderr is attached to, or `nil` when it can't be read. Static. |

### Usage Example

```swift
func makeDisplay() -> any ProgressDisplay {
    if TerminalCapabilities.standardErrorIsTerminal {
        return LiveProgressDisplay()
    }

    return PlainProgressDisplay()
}
```

### Behavior

- `standardErrorIsTerminal` is `isatty(STDERR_FILENO) == 1`, read fresh on each access.
- `standardErrorSize` asks the terminal with `ioctl(TIOCGWINSZ)` on each access, and is `nil` when that fails or reports zero columns or rows.
- The displays never check `standardErrorIsTerminal` themselves; the caller decides. `LiveProgressDisplay` reads `standardErrorSize` on every draw to fit its region.
<!-- /type:TerminalCapabilities -->

<!-- type:TerminalSize -->
## Struct: TerminalSize

The width and height of a terminal, in columns and rows.

```swift
public struct TerminalSize: Sendable
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `width` | `Int` | Number of columns. |
| `height` | `Int` | Number of rows. |

### Usage Example

```swift
if let size = TerminalCapabilities.standardErrorSize {
    let separator = String(repeating: "─", count: size.width)
}
```

Its initializer is not public; values come from `TerminalCapabilities.standardErrorSize`.
<!-- /type:TerminalSize -->

---

## Best Practices

- **Depend on `any ProgressDisplay`** — Pass the protocol into the code that does the work, and construct `LiveProgressDisplay` or `PlainProgressDisplay` once, at the entry point.
- **Choose the display from the terminal** — Use `LiveProgressDisplay` only when `TerminalCapabilities.standardErrorIsTerminal` is true (and the session is interactive); otherwise use `PlainProgressDisplay`. The live display always writes escape codes, even into a file.
- **Write results with `writeOutput(_:)`, not `print`** — `print` writes over the live region; `writeOutput` erases it first and keeps progress on stderr and results on stdout.
- **Wrap every prompt in `suspended(_:)`** — Otherwise the live region is redrawn over the prompt. It costs nothing with the plain display.
- **Call `restoreTerminal()` on early exit** — Register it as a Ctrl-C cleanup so the cursor is shown and colors are reset. A normal finish restores the cursor on its own.
- **Expect the error after the ✗ line** — `track` prints the failure, then rethrows the operation's error unchanged; don't print the failure again.
- **Don't rely on output after restoring** — Once `restoreTerminal()` runs, both displays drop everything, including `writeOutput`.
- **Only report through the handle you were given** — `ActivityHandle` has no public initializer; keep it inside the `operation` closure, or pass it down to the functions that do the work.
- **Test with `MockProgressDisplay`** — In tests, inject the mock from the `ConsoleProgressTesting` product instead of a silenced real display; see `TestingReference.md`.
- **Use `update(detail:)` for "what's happening now", `output(line:)` for logs** — Details replace each other and vanish from the finished line; output lines are kept so a failure shows them.
- **Report progress with the final count** — Call `progress(completed: total, total: total)` at the end, or the live bar stops one step short.
- **Pair `markWaiting()` with `markRunning()`** — In the live display, a waiting activity hides its spinner, detail, progress, and output tail until it is marked running again. The plain display continues printing updates while waiting.
- **Check `standardErrorIsTerminal`, not stdout** — Progress is drawn on stderr, so stdout being piped doesn't mean the live display is wrong.
- **Expect `standardErrorSize` to be `nil` in CI** — It needs a real terminal; code that uses it must handle `nil`.
