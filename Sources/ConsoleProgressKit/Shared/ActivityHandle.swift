//
//  ActivityHandle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// Lets a running activity report what it is doing right now.
public struct ActivityHandle: Sendable {
    private let send: @Sendable (ActivityUpdate) -> Void

    init(send: @escaping @Sendable (ActivityUpdate) -> Void) {
        self.send = send
    }
}

// MARK: - Actions
public extension ActivityHandle {
    /// Shows `detail` after the activity's title, replacing any earlier detail; `nil` clears it.
    ///
    /// The detail is dropped from the finished ✓ or ✗ line.
    func update(detail: String?) {
        send(.detail(detail))
    }

    /// Shows the activity as queued, such as while it waits for a free slot under a concurrency cap.
    func markWaiting() {
        send(.waiting(true))
    }

    /// Shows the activity as running again after ``markWaiting()``.
    func markRunning() {
        send(.waiting(false))
    }

    /// Records one line of the activity's own output, such as a build log line.
    ///
    /// The live display shows only the last few lines under the activity while it runs, and more
    /// of them if it fails; the plain display prints every line.
    func output(line: String) {
        send(.output(line))
    }

    /// Shows a progress bar for an activity made of a known number of steps.
    func progress(completed: Int, total: Int) {
        send(.progress(completed: completed, total: total))
    }
}
