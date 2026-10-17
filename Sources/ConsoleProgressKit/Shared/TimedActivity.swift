//
//  TimedActivity.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum TimedActivity {
    /// Runs `operation`, then calls `finish` with whether it succeeded and how long it took.
    ///
    /// Errors thrown by `operation` are rethrown after `finish` runs.
    static func run<T>(clock: ContinuousClock, operation: () async throws -> T, finish: (Bool, Duration) -> Void) async throws -> T {
        let start = clock.now

        do {
            let value = try await operation()
            finish(true, clock.now - start)

            return value
        } catch {
            finish(false, clock.now - start)
            throw error
        }
    }
}
