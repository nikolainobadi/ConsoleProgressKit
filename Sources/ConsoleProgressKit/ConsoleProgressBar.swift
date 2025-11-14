//
//  ConsoleProgressBar.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/13/25.
//

import Foundation

public final class ConsoleProgressBar {
    private let width: Int
    private let color: ConsoleColor
    
    private var current = 0
    private var firstUpdate = true
    
    public init(width: Int = 50, color: ConsoleColor = .green) {
        self.width = width
        self.color = color
    }
}


// MARK: - PurgeProgressHandler
extension ConsoleProgressBar {
    public func complete(message: String? = nil) {
        if let message = message {
            print("\n\(color.rawValue)✅ \(message)\(ConsoleColor.reset.rawValue)")
        } else {
            print("\n\(color.rawValue)✅ Completed.\(ConsoleColor.reset.rawValue)")
        }
    }

    public func updateProgress(current: Int, total: Int, message: String) {
        self.current = current
        let total = total
        let progress = Double(current) / Double(total)
        let filled = Int(progress * Double(width))
        let empty = width - filled

        let filledBar = color.rawValue + String(repeating: "█", count: filled) + ConsoleColor.reset.rawValue
        let emptyBar = String(repeating: "-", count: empty)
        let bar = filledBar + emptyBar
        let percent = "\(color.rawValue)\(String(format: "%.2f%%", progress * 100))\(ConsoleColor.reset.rawValue)"

        if !firstUpdate { print("\u{1B}[2A", terminator: "") }
        else { firstUpdate = false }

        print("\u{1B}[2K\(message)")
        print("\u{1B}[2K\(bar) \(percent)")
        fflush(stdout)
    }
}
