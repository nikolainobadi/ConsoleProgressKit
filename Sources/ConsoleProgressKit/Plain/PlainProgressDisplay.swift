//
//  PlainProgressDisplay.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Synchronization

/// Writes one line when an activity starts, one per detail update, and one when it finishes, with
/// no animation or escape codes, for pipes, logs, and non-interactive callers.
///
/// Once the terminal is restored, the display writes nothing more; activities still run and finish
/// unseen.
public final class PlainProgressDisplay: Sendable {
    private let clock = ContinuousClock()
    private let isStopped = Mutex(false)

    public init() { }
}

// MARK: - ProgressDisplay
extension PlainProgressDisplay: ProgressDisplay {
    public func track<T>(_ title: String, operation: (ActivityHandle) async throws -> T) async throws -> T {
        let handle = ActivityHandle(send: { [weak self] update in
            self?.write(update, title: title)
        })

        write("\(title)...\n", to: .error)

        return try await TimedActivity.run(clock: clock, operation: { try await operation(handle) }, finish: { succeeded, elapsed in
            finish(title: title, succeeded: succeeded, elapsed: elapsed)
        })
    }

    public func note(_ text: String, style: NoteStyle) {
        write(NoteLine.make(text: text, style: style, colorsAreEnabled: false) + "\n", to: .error)
    }

    public func suspended<T>(_ body: () throws -> T) rethrows -> T {
        return try body()
    }

    public func writeOutput(_ text: String) {
        write(text + "\n", to: .output)
    }

    public func restoreTerminal() {
        isStopped.withLock { $0 = true }
    }
}

// MARK: - Private Methods
private extension PlainProgressDisplay {
    /// Writes `text` unless the terminal has been restored, holding the lock so nothing is written after.
    func write(_ text: String, to stream: StandardStream) {
        isStopped.withLock { isStopped in
            guard !isStopped else {
                return
            }

            stream.write(text)
        }
    }

    func write(_ update: ActivityUpdate, title: String) {
        switch update {
        case .detail(let detail):
            if let detail {
                writeDetail(detail, title: title)
            }
        case .waiting(let isWaiting):
            writeDetail(isWaiting ? "waiting" : "started", title: title)
        case .output(let line):
            write(line + "\n", to: .error)
        case .progress(let completed, let total):
            writeDetail("\(completed)/\(total)", title: title)
        }
    }

    func writeDetail(_ detail: String, title: String) {
        write(DetailLine.make(title: title, detail: detail) + "\n", to: .error)
    }

    func finish(title: String, succeeded: Bool, elapsed: Duration) {
        write(ActivityLine.finished(title: title, succeeded: succeeded, elapsed: elapsed, colorsAreEnabled: false) + "\n", to: .error)
    }
}
