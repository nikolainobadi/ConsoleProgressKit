//
//  ActivityLine.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

enum ActivityLine {
    static func finished(title: String, succeeded: Bool, elapsed: Duration, colorsAreEnabled: Bool) -> String {
        return "\(makeSymbol(succeeded: succeeded, colorsAreEnabled: colorsAreEnabled)) \(title) (\(format(elapsed: elapsed)))"
    }
}

// MARK: - Private Methods
private extension ActivityLine {
    static let successSymbol = "✓"
    static let failureSymbol = "✗"

    static func makeSymbol(succeeded: Bool, colorsAreEnabled: Bool) -> String {
        if succeeded {
            return TerminalStyle.apply(TerminalStyle.green, to: successSymbol, colorsAreEnabled: colorsAreEnabled)
        }

        return TerminalStyle.apply(TerminalStyle.red, to: failureSymbol, colorsAreEnabled: colorsAreEnabled)
    }

    static func format(elapsed: Duration) -> String {
        let components = elapsed.components
        let seconds = Double(components.seconds) + Double(components.attoseconds) / 1e18

        return String(format: "%.1fs", seconds)
    }
}
