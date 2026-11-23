/// How a note is marked when it prints.
public enum NoteStyle: Sendable {
    /// Printed as plain text.
    case info

    /// Prefixed with `!`, which `LiveProgressDisplay` draws in its theme's warning color.
    case warning
}
