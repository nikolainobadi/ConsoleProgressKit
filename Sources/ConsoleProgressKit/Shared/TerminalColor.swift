//
//  TerminalColor.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/3/26.
//

/// One of the 16 named ANSI colors.
///
/// The exact shade of each color comes from the user's terminal palette.
public enum TerminalColor: Sendable {
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    case brightBlack
    case brightRed
    case brightGreen
    case brightYellow
    case brightBlue
    case brightMagenta
    case brightCyan
    case brightWhite
}

// MARK: - Escape Codes
extension TerminalColor {
    var sgrCode: Int {
        switch self {
        case .black:
            return 30
        case .red:
            return 31
        case .green:
            return 32
        case .yellow:
            return 33
        case .blue:
            return 34
        case .magenta:
            return 35
        case .cyan:
            return 36
        case .white:
            return 37
        case .brightBlack:
            return 90
        case .brightRed:
            return 91
        case .brightGreen:
            return 92
        case .brightYellow:
            return 93
        case .brightBlue:
            return 94
        case .brightMagenta:
            return 95
        case .brightCyan:
            return 96
        case .brightWhite:
            return 97
        }
    }
}
