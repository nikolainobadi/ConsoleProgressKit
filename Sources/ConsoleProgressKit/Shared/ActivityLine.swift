//
//  ActivityLine.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

enum ActivityLine {
    /// Makes the line for a finished activity, with its symbol uncolored when `theme` is `nil`.
    static func finished(title: String, succeeded: Bool, elapsed: Duration, theme: ProgressTheme?) -> String {
        return "\(makeSymbol(succeeded: succeeded, theme: theme)) \(title) (\(format(elapsed: elapsed)))"
    }
}

// MARK: - Private Methods
private extension ActivityLine {
    static let successSymbol = "✓"
    static let failureSymbol = "✗"

    static func makeSymbol(succeeded: Bool, theme: ProgressTheme?) -> String {
        if succeeded {
            return TerminalStyle.apply(theme?.success, to: successSymbol)
        }

        return TerminalStyle.apply(theme?.failure, to: failureSymbol)
    }

    static func format(elapsed: Duration) -> String {
        let components = elapsed.components
        let seconds = Double(components.seconds) + Double(components.attoseconds) / 1e18

        return String(format: "%.1fs", seconds)
    }
}
