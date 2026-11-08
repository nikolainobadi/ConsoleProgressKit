//
//  AnsiTextStyler.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// Styles text with ANSI escape codes, whatever the output stream supports.
///
/// Use ``TerminalCapabilities/textStyler(for:)`` to respect the user's terminal and settings. Empty
/// text, and text in a style with no attributes, is returned unchanged.
public struct AnsiTextStyler: TextStyler {
    public init() {}

    public func styled(_ text: String, as style: TextStyle) -> String {
        let codes = makeCodes(for: style)

        guard !text.isEmpty, !codes.isEmpty else {
            return text
        }

        return TerminalStyle.apply(TerminalStyle.sgr(codes), to: text)
    }
}

// MARK: - Private Methods
private extension AnsiTextStyler {
    func makeCodes(for style: TextStyle) -> [Int] {
        var codes: [Int] = []

        if style.isBold {
            codes.append(TerminalStyle.boldCode)
        }

        if style.isDim {
            codes.append(TerminalStyle.dimCode)
        }

        if style.isUnderlined {
            codes.append(TerminalStyle.underlineCode)
        }

        if let color = style.color {
            codes.append(color.sgrCode)
        }

        return codes
    }
}
