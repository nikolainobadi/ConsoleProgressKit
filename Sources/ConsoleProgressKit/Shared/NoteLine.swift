//
//  NoteLine.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum NoteLine {
    static func make(text: String, style: NoteStyle, colorsAreEnabled: Bool) -> String {
        switch style {
        case .info:
            return text
        case .warning:
            return TerminalStyle.apply(TerminalStyle.yellow, to: warningSymbol, colorsAreEnabled: colorsAreEnabled) + " " + text
        }
    }
}

// MARK: - Private Constants
private extension NoteLine {
    static let warningSymbol = "!"
}
