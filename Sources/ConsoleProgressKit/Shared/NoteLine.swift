//
//  NoteLine.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum NoteLine {
    /// Makes the line for a note, with its symbol uncolored when `theme` is `nil`.
    static func make(text: String, style: NoteStyle, theme: ProgressTheme?) -> String {
        switch style {
        case .info:
            return text
        case .warning:
            return TerminalStyle.apply(theme?.warning, to: warningSymbol) + " " + text
        }
    }
}

// MARK: - Private Constants
private extension NoteLine {
    static let warningSymbol = "!"
}
