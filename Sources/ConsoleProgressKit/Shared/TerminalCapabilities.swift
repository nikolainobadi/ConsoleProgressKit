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
        return TerminalStream.standardError.isTerminal
    }

    /// The size of the terminal stderr is attached to, or `nil` when it can't be read.
    ///
    /// The same as `size(for: .standardError)`.
    public static var standardErrorSize: TerminalSize? {
        return size(for: .standardError)
    }

    /// The size of the terminal `stream` is attached to, or `nil` when it can't be read.
    ///
    /// Read fresh on each call. `nil` when the stream isn't a terminal, the size can't be read, or the
    /// terminal reports zero columns or rows. Choose the stream the text goes to: stdout can be piped
    /// while stderr is still a terminal.
    public static func size(for stream: TerminalStream) -> TerminalSize? {
        var size = winsize()

        guard ioctl(stream.fileDescriptor, TIOCGWINSZ, &size) == 0 else {
            return nil
        }

        return self.size(columns: Int(size.ws_col), rows: Int(size.ws_row))
    }

    /// Whether styled text should be written to `stream`.
    ///
    /// True only when the stream is a terminal, `NO_COLOR` is unset or empty, and `TERM` isn't `dumb`.
    /// The answer covers all styling, so bold, dim, and underline are off whenever color is.
    public static func supportsColor(on stream: TerminalStream) -> Bool {
        return supportsColor(isTerminal: stream.isTerminal, environment: ProcessInfo.processInfo.environment)
    }

    /// Returns the styler to use for text written to `stream`: ANSI when it supports color, otherwise plain.
    ///
    /// Choose the stream the text goes to: `.standardOutput` for `writeOutput(_:)` and
    /// `.standardError` for `note(_:style:)`.
    public static func textStyler(for stream: TerminalStream) -> any TextStyler {
        return textStyler(supportsColor: supportsColor(on: stream))
    }
}

// MARK: - Decisions
extension TerminalCapabilities {
    static func supportsColor(isTerminal: Bool, environment: [String: String]) -> Bool {
        let noColor = environment["NO_COLOR"] ?? ""

        return isTerminal && noColor.isEmpty && environment["TERM"] != "dumb"
    }

    static func size(columns: Int, rows: Int) -> TerminalSize? {
        guard columns > 0, rows > 0 else {
            return nil
        }

        return .init(width: columns, height: rows)
    }

    static func textStyler(supportsColor: Bool) -> any TextStyler {
        if supportsColor {
            return AnsiTextStyler()
        }

        return PlainTextStyler()
    }
}

// MARK: - Dependencies
public struct TerminalSize: Sendable {
    public let width: Int
    public let height: Int
}
