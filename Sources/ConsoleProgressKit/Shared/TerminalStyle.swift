//
//  TerminalStyle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum TerminalStyle {
    static let boldCode = 1
    static let dimCode = 2
    static let underlineCode = 4
    static let reset = "\u{1B}[0m"
    static let dim = sgr([dimCode])
    static let hideCursor = "\u{1B}[?25l"
    static let showCursor = "\u{1B}[?25h"
    static let clearToEndOfScreen = "\u{1B}[J"

    static func cursorUp(_ lineCount: Int) -> String {
        return "\u{1B}[\(lineCount)A"
    }

    /// Builds one escape sequence that turns on every code in `codes`.
    static func sgr(_ codes: [Int]) -> String {
        return "\u{1B}[" + codes.map { String($0) }.joined(separator: ";") + "m"
    }

    static func apply(_ style: String, to text: String) -> String {
        return style + text + reset
    }

    /// Wraps `text` in `color`, or returns it unchanged when there's no color or nothing to color.
    static func apply(_ color: TerminalColor?, to text: String) -> String {
        guard let color, !text.isEmpty else {
            return text
        }

        return apply(sgr([color.sgrCode]), to: text)
    }
}
