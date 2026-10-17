//
//  TerminalCapabilities.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

public enum TerminalCapabilities {
    /// Whether stderr is attached to a terminal, rather than a pipe or a file.
    public static var standardErrorIsTerminal: Bool {
        return isatty(STDERR_FILENO) == 1
    }

    /// The size of the terminal stderr is attached to, or `nil` when it can't be read.
    public static var standardErrorSize: TerminalSize? {
        var size = winsize()

        guard ioctl(STDERR_FILENO, TIOCGWINSZ, &size) == 0, size.ws_col > 0, size.ws_row > 0 else {
            return nil
        }

        return .init(width: Int(size.ws_col), height: Int(size.ws_row))
    }
}

// MARK: - Dependencies
public struct TerminalSize: Sendable {
    public let width: Int
    public let height: Int
}
