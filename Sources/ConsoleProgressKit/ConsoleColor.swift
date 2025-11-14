//
//  ConsoleColor.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/13/25.
//

public enum ConsoleColor: String {
    case green = "\u{1B}[32m"
    case yellow = "\u{1B}[33m"
    case blue = "\u{1B}[34m"
    case magenta = "\u{1B}[35m"
    case cyan = "\u{1B}[36m"
    case reset = "\u{1B}[0m"
}
