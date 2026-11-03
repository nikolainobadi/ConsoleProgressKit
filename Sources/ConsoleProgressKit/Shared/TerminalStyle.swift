//
//  TerminalStyle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum TerminalStyle {
    static let reset = "\u{1B}[0m"
    static let dim = "\u{1B}[2m"
    static let hideCursor = "\u{1B}[?25l"
    static let showCursor = "\u{1B}[?25h"
    static let clearToEndOfScreen = "\u{1B}[J"

    static func cursorUp(_ lineCount: Int) -> String {
        return "\u{1B}[\(lineCount)A"
    }

    static func apply(_ style: String, to text: String) -> String {
        return style + text + reset
    }

    /// Wraps `text` in `color`, or returns it unchanged when there's no color or nothing to color.
    static func apply(_ color: TerminalColor?, to text: String) -> String {
        guard let color, !text.isEmpty else {
            return text
        }

        return apply("\u{1B}[\(color.sgrCode)m", to: text)
    }
}
