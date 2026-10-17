//
//  TerminalStyle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum TerminalStyle {
    static let reset = "\u{1B}[0m"
    static let dim = "\u{1B}[2m"
    static let red = "\u{1B}[31m"
    static let green = "\u{1B}[32m"
    static let yellow = "\u{1B}[33m"
    static let hideCursor = "\u{1B}[?25l"
    static let showCursor = "\u{1B}[?25h"
    static let clearToEndOfScreen = "\u{1B}[J"

    static func cursorUp(_ lineCount: Int) -> String {
        return "\u{1B}[\(lineCount)A"
    }

    static func apply(_ style: String, to text: String, colorsAreEnabled: Bool) -> String {
        guard colorsAreEnabled else {
            return text
        }

        return style + text + reset
    }
}
