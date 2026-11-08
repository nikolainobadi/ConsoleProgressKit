//
//  TextStyle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// How a piece of text looks.
///
/// Add styles of your own in a `TextStyle` extension, so call sites read the same as they do for
/// the standard styles.
public struct TextStyle: Sendable, Equatable {
    /// Identifies the style in `TaggingTextStyler` output. Give each style a distinct name.
    public let name: String

    /// The foreground color, or `nil` for the terminal's default foreground color.
    public let color: TerminalColor?

    public let isBold: Bool
    public let isDim: Bool
    public let isUnderlined: Bool

    public init(name: String, color: TerminalColor?, isBold: Bool, isDim: Bool, isUnderlined: Bool) {
        self.name = name
        self.color = color
        self.isBold = isBold
        self.isDim = isDim
        self.isUnderlined = isUnderlined
    }
}

// MARK: - Standard Styles
public extension TextStyle {
    static let title = TextStyle(name: "title", color: .cyan, isBold: true, isDim: false, isUnderlined: false)
    static let heading = TextStyle(name: "heading", color: nil, isBold: true, isDim: false, isUnderlined: false)
    static let added = TextStyle(name: "added", color: .green, isBold: false, isDim: false, isUnderlined: false)
    static let deleted = TextStyle(name: "deleted", color: .red, isBold: false, isDim: false, isUnderlined: false)
    static let muted = TextStyle(name: "muted", color: nil, isBold: false, isDim: true, isUnderlined: false)
    static let standout = TextStyle(name: "standout", color: .magenta, isBold: true, isDim: false, isUnderlined: false)
    static let success = TextStyle(name: "success", color: .green, isBold: true, isDim: false, isUnderlined: false)
    static let warning = TextStyle(name: "warning", color: .yellow, isBold: true, isDim: false, isUnderlined: false)
    static let failure = TextStyle(name: "failure", color: .red, isBold: true, isDim: false, isUnderlined: false)
    static let command = TextStyle(name: "command", color: nil, isBold: true, isDim: false, isUnderlined: false)
    static let url = TextStyle(name: "url", color: nil, isBold: false, isDim: false, isUnderlined: true)
}
