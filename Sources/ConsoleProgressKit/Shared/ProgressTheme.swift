//
//  ProgressTheme.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/3/26.
//

/// The colors `LiveProgressDisplay` uses for its spinner, progress bar, and status symbols.
public struct ProgressTheme: Sendable {
    /// The color of the spinner, or `nil` for the terminal's default foreground color.
    public let spinner: TerminalColor?

    /// The color of the progress bar's filled cells, or `nil` for the terminal's default foreground color.
    public let progressBar: TerminalColor?

    /// The color of the `✓` on a succeeded activity.
    public let success: TerminalColor

    /// The color of the `✗` on a failed activity.
    public let failure: TerminalColor

    /// The color of the `!` on a warning note.
    public let warning: TerminalColor

    public init(spinner: TerminalColor?, progressBar: TerminalColor?, success: TerminalColor, failure: TerminalColor, warning: TerminalColor) {
        self.spinner = spinner
        self.progressBar = progressBar
        self.success = success
        self.failure = failure
        self.warning = warning
    }
}

// MARK: - Standard Theme
public extension ProgressTheme {
    /// No spinner or bar color, green success, red failure, yellow warning.
    static let standard = ProgressTheme(spinner: nil, progressBar: nil, success: .green, failure: .red, warning: .yellow)
}
