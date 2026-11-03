//
//  ProgressBar.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum ProgressBar {
    /// Makes the bar and its count. `fillColor` colors the filled cells only.
    static func make(completed: Int, total: Int, fillColor: TerminalColor?) -> String {
        let clampedTotal = max(total, 1)
        let clampedCompleted = min(max(completed, 0), clampedTotal)
        let filledCount = clampedTotal.dividingFullWidth(width.multipliedFullWidth(by: clampedCompleted)).quotient
        let filledCells = TerminalStyle.apply(fillColor, to: String(repeating: filled, count: filledCount))

        return filledCells + String(repeating: empty, count: width - filledCount) + " \(clampedCompleted)/\(clampedTotal)"
    }
}

// MARK: - Private Constants
private extension ProgressBar {
    static let width = 20
    static let filled = "█"
    static let empty = "░"
}
