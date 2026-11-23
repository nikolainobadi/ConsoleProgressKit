/// How a recorded activity finished.
public enum RecordedOutcome: Sendable, Equatable {
    /// The operation returned a value.
    case succeeded

    /// The operation threw an error.
    case failed
}
