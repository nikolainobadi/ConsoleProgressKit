//
//  RecordedOutcome.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 10/21/26.
//

/// How a recorded activity finished.
public enum RecordedOutcome: Sendable, Equatable {
    /// The operation returned a value.
    case succeeded

    /// The operation threw an error.
    case failed
}
