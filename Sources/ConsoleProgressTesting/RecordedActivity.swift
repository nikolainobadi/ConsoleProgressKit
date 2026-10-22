//
//  RecordedActivity.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 10/21/26.
//

/// One `track(_:operation:)` call recorded by ``MockProgressDisplay``.
public struct RecordedActivity: Sendable, Equatable {
    public let title: String

    /// Every update the activity's handle sent, in order.
    public internal(set) var updates: [RecordedUpdate]

    /// How the activity finished, or `nil` while it is still running.
    public internal(set) var outcome: RecordedOutcome?

    public init(title: String, updates: [RecordedUpdate], outcome: RecordedOutcome?) {
        self.title = title
        self.updates = updates
        self.outcome = outcome
    }
}
