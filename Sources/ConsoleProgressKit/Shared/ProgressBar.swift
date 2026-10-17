//
//  ProgressBar.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum ProgressBar {
    static func make(completed: Int, total: Int) -> String {
        let clampedTotal = max(total, 1)
        let clampedCompleted = min(max(completed, 0), clampedTotal)
        let filledCount = clampedCompleted * width / clampedTotal

        return String(repeating: filled, count: filledCount) + String(repeating: empty, count: width - filledCount) + " \(clampedCompleted)/\(clampedTotal)"
    }
}

// MARK: - Private Constants
private extension ProgressBar {
    static let width = 20
    static let filled = "█"
    static let empty = "░"
}
