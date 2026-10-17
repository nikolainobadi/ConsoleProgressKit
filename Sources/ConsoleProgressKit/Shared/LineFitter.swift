//
//  LineFitter.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum LineFitter {
    /// Cuts `line` so its visible characters fit in `width` columns, ending it with `…` when cut.
    ///
    /// Escape sequences don't count toward the width and are kept, and a cut line ends with a style
    /// reset so a cut-off color can't leak into the next line. Every character is counted as one
    /// column, so wide characters such as emoji can still overflow.
    static func fit(_ line: String, width: Int) -> String {
        let maximumVisibleCount = max(width - 1, 1)

        guard line.utf8.count > maximumVisibleCount else {
            return line
        }

        let pieces = split(line)
        let visibleCount = pieces.filter { !$0.isEscape }.count

        guard visibleCount > maximumVisibleCount else {
            return line
        }

        return cut(pieces, keepingVisibleCount: maximumVisibleCount - 1) + ellipsis + TerminalStyle.reset
    }
}

// MARK: - Private Methods
private extension LineFitter {
    static let escape: Character = "\u{1B}"
    static let ellipsis = "…"

    static func split(_ line: String) -> [LinePiece] {
        var pieces: [LinePiece] = []
        var escapeSequence = ""

        for character in line {
            if character == escape {
                escapeSequence = String(character)
            } else if escapeSequence.isEmpty {
                pieces.append(.init(text: String(character), isEscape: false))
            } else {
                escapeSequence.append(character)

                if character.isLetter {
                    pieces.append(.init(text: escapeSequence, isEscape: true))
                    escapeSequence = ""
                }
            }
        }

        if !escapeSequence.isEmpty {
            pieces.append(.init(text: escapeSequence, isEscape: true))
        }

        return pieces
    }

    static func cut(_ pieces: [LinePiece], keepingVisibleCount keptCount: Int) -> String {
        var result = ""
        var visibleCount = 0

        for piece in pieces {
            if piece.isEscape {
                result += piece.text
            } else if visibleCount < keptCount {
                result += piece.text
                visibleCount += 1
            }
        }

        return result
    }
}

// MARK: - Dependencies
private struct LinePiece {
    let text: String
    let isEscape: Bool
}
