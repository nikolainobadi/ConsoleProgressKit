//
//  ProgressDisplay.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// Shows the user what a long-running command is doing.
///
/// Progress is written to stderr so a command's results on stdout stay clean for pipes.
public protocol ProgressDisplay: Sendable {
    /// Shows `title` while `operation` runs, then marks it as succeeded or failed with the elapsed time.
    ///
    /// `operation` receives a handle for reporting what it is doing while it runs. Errors thrown by
    /// `operation` are rethrown unchanged after the failure is shown.
    nonisolated(nonsending) func track<T>(_ title: String, operation: nonisolated(nonsending) (ActivityHandle) async throws -> T) async throws -> T

    /// Prints `text` as its own line, marked by `style`, above any activity that is still running.
    func note(_ text: String, style: NoteStyle)

    /// Clears running activities from the screen while `body` runs, then redraws them.
    ///
    /// Wrap anything that reads from the user, such as a prompt, so the prompt isn't drawn over.
    func suspended<T>(_ body: () throws -> T) rethrows -> T

    /// Writes `text` and a newline to stdout without breaking up running activities.
    ///
    /// Use this for a command's results, which belong on stdout, while progress is on screen.
    func writeOutput(_ text: String)

    /// Erases running activities, resets colors, and shows the cursor, then stops drawing for good.
    ///
    /// Call this when the process is about to end early, such as on Ctrl-C. Every later call does nothing.
    func restoreTerminal()
}
