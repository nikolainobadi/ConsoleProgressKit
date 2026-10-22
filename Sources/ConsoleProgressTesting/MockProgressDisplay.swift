//
//  MockProgressDisplay.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 10/21/26.
//

import Synchronization

/// A ``ProgressDisplay`` for tests that writes nothing and records everything it is asked to show.
///
/// Tracked operations run with a working `ActivityHandle`, and their values and errors pass through
/// unchanged. Recording continues after `restoreTerminal()`, so work that runs after an interrupt
/// cleanup is still visible to a test.
///
/// All state lives in a `Mutex`, so concurrent activities can record safely.
public final class MockProgressDisplay: Sendable {
    private let state = Mutex(RecordedState())

    public init() { }
}

// MARK: - Recorded State
public extension MockProgressDisplay {
    /// One activity per `track(_:operation:)` call, in the order they started.
    var activities: [RecordedActivity] {
        return state.withLock { return $0.activities }
    }

    /// The titles of ``activities``, in the order they started.
    var trackedTitles: [String] {
        return activities.map(\.title)
    }

    /// Every `note(_:style:)` call, in order.
    var notes: [RecordedNote] {
        return state.withLock { return $0.notes }
    }

    /// Every `writeOutput(_:)` text, in order.
    var writtenOutput: [String] {
        return state.withLock { return $0.writtenOutput }
    }

    /// How many times `suspended(_:)` ran its body.
    var suspensionCount: Int {
        return state.withLock { return $0.suspensionCount }
    }

    /// Whether `restoreTerminal()` was called.
    var terminalWasRestored: Bool {
        return state.withLock { return $0.terminalWasRestored }
    }
}

// MARK: - ProgressDisplay
extension MockProgressDisplay: ProgressDisplay {
    public func track<T>(_ title: String, operation: (ActivityHandle) async throws -> T) async throws -> T {
        let index = state.withLock { state in
            state.activities.append(RecordedActivity(title: title, updates: [], outcome: nil))

            return state.activities.count - 1
        }
        let handle = ActivityHandle(send: { [weak self] update in
            self?.state.withLock { $0.activities[index].updates.append(RecordedUpdate(update)) }
        })

        do {
            let value = try await operation(handle)
            finish(at: index, outcome: .succeeded)

            return value
        } catch {
            finish(at: index, outcome: .failed)
            throw error
        }
    }

    public func note(_ text: String, style: NoteStyle) {
        state.withLock { $0.notes.append(RecordedNote(text: text, style: style)) }
    }

    public func suspended<T>(_ body: () throws -> T) rethrows -> T {
        state.withLock { $0.suspensionCount += 1 }

        return try body()
    }

    public func writeOutput(_ text: String) {
        state.withLock { $0.writtenOutput.append(text) }
    }

    public func restoreTerminal() {
        state.withLock { $0.terminalWasRestored = true }
    }
}

// MARK: - Private Methods
private extension MockProgressDisplay {
    func finish(at index: Int, outcome: RecordedOutcome) {
        state.withLock { $0.activities[index].outcome = outcome }
    }
}

// MARK: - Dependencies
private struct RecordedState: Sendable {
    var activities: [RecordedActivity] = []
    var notes: [RecordedNote] = []
    var writtenOutput: [String] = []
    var suspensionCount = 0
    var terminalWasRestored = false
}

private extension RecordedUpdate {
    init(_ update: ActivityUpdate) {
        switch update {
        case .detail(let detail):
            self = .detail(detail)
        case .waiting(true):
            self = .waiting
        case .waiting(false):
            self = .running
        case .output(let line):
            self = .output(line)
        case .progress(let completed, let total):
            self = .progress(completed: completed, total: total)
        }
    }
}
