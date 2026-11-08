//
//  TerminalStream.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Foundation

/// A standard stream a caller can ask terminal questions about.
///
/// Progress goes to stderr and results go to stdout, and either can be redirected on its own, so
/// the answer depends on the stream. This type only identifies a stream; writing is handled internally.
public enum TerminalStream: Sendable {
    /// The stream a command's results are written to.
    case standardOutput

    /// The stream progress and notes are written to.
    case standardError
}

// MARK: - Terminal Detection
extension TerminalStream {
    var isTerminal: Bool {
        switch self {
        case .standardOutput:
            return isatty(STDOUT_FILENO) == 1
        case .standardError:
            return isatty(STDERR_FILENO) == 1
        }
    }
}
