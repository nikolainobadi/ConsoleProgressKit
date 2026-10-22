//
//  RecordedUpdate.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 10/21/26.
//

/// One update sent through an `ActivityHandle`.
public enum RecordedUpdate: Sendable, Equatable {
    /// Sent by `update(detail:)`.
    case detail(String?)

    /// Sent by `markWaiting()`.
    case waiting

    /// Sent by `markRunning()`.
    case running

    /// Sent by `output(line:)`.
    case output(String)

    /// Sent by `progress(completed:total:)`.
    case progress(completed: Int, total: Int)
}
