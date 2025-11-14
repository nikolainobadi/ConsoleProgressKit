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
    private let completionSymbol: String?
    private let reset = ConsoleColor.reset.rawValue
    private let clearLine = "\u{1B}[2K"
    private let moveUp2 = "\u{1B}[2A"
    
    private var firstUpdate = true
    private var lastMessage: String?
    private var maxBar: String
    private var lastUpdateTime: CFAbsoluteTime = 0
    private let minInterval: Double
    
    public init(
        width: Int = 50,
        color: ConsoleColor = .green,
        throttleInterval: Double = 0.05,
        completionSymbol: String? = "✅"
    ) {
        self.width = width
        self.color = color
        self.minInterval = throttleInterval
        self.completionSymbol = completionSymbol
        self.maxBar = String(repeating: "█", count: width)
    }
}


// MARK: - Actions
public extension ConsoleProgressBar {
    func complete(message: String? = nil) {
        let prefix: String
        if let symbol = completionSymbol {
            prefix = "\(color.rawValue)\(symbol) "
        } else {
            prefix = "\(color.rawValue)"
        }

        if let message = message {
            print("\n\(prefix)\(message)\(reset)")
        } else {
            print("\n\(prefix)Completed.\(reset)")
        }
    }

    func updateProgress(current: Int, total: Int, message: String) {
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastUpdateTime < minInterval { return }
        lastUpdateTime = now

        let progress = Double(current) / Double(total)
        let filledCount = Int(progress * Double(width))
        let emptyCount = width - filledCount

        let filledBar = String(maxBar.prefix(filledCount))
        let emptyBar = String(repeating: "-", count: emptyCount)

        let percentValue = Int(progress * 10000)
        let percentText = "\(percentValue / 100).\(String(format: "%02d", percentValue % 100))%"

        let bar = "\(color.rawValue)\(filledBar)\(reset)\(emptyBar)"
        let percentColored = "\(color.rawValue)\(percentText)\(reset)"

        if !firstUpdate {
            print(moveUp2, terminator: "")
        } else {
            firstUpdate = false
        }

        if lastMessage != message {
            print("\(clearLine)\(message)")
            lastMessage = message
        } else {
            print(clearLine)
        }

        print("\(clearLine)\(bar) \(percentColored)")
        fflush(stdout)
    }
}
