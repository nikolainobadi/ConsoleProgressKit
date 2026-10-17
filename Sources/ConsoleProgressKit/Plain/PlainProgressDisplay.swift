//
//  PlainProgressDisplay.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// Writes one line when an activity starts, one per detail update, and one when it finishes, with
/// no animation or escape codes, for pipes, logs, and non-interactive callers.
public struct PlainProgressDisplay {
    private let clock = ContinuousClock()

    public init() { }
}

// MARK: - ProgressDisplay
extension PlainProgressDisplay: ProgressDisplay {
    public nonisolated(nonsending) func track<T>(_ title: String, operation: nonisolated(nonsending) (ActivityHandle) async throws -> T) async throws -> T {
        let handle = ActivityHandle(send: { update in
            Self.write(update, title: title)
        })

        StandardStream.error.write("\(title)...\n")

        return try await TimedActivity.run(clock: clock, operation: { try await operation(handle) }, finish: { succeeded, elapsed in
            finish(title: title, succeeded: succeeded, elapsed: elapsed)
        })
    }

    public func note(_ text: String, style: NoteStyle) {
        StandardStream.error.write(NoteLine.make(text: text, style: style, colorsAreEnabled: false) + "\n")
    }

    public func suspended<T>(_ body: () throws -> T) rethrows -> T {
        return try body()
    }

    public func writeOutput(_ text: String) {
        StandardStream.output.write(text + "\n")
    }

    public func restoreTerminal() { }
}

// MARK: - Private Methods
private extension PlainProgressDisplay {
    static func write(_ update: ActivityUpdate, title: String) {
        switch update {
        case .detail(let detail):
            if let detail {
                writeDetail(detail, title: title)
            }
        case .waiting(let isWaiting):
            writeDetail(isWaiting ? "waiting" : "started", title: title)
        case .output(let line):
            StandardStream.error.write(line + "\n")
        case .progress(let completed, let total):
            writeDetail("\(completed)/\(total)", title: title)
        }
    }

    static func writeDetail(_ detail: String, title: String) {
        StandardStream.error.write(DetailLine.make(title: title, detail: detail) + "\n")
    }

    func finish(title: String, succeeded: Bool, elapsed: Duration) {
        StandardStream.error.write(ActivityLine.finished(title: title, succeeded: succeeded, elapsed: elapsed, colorsAreEnabled: false) + "\n")
    }
}
