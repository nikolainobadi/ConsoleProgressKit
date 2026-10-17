//
//  TerminalScreen.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// What the live display last put on screen, so the next redraw can replace it in place.
struct TerminalScreen {
    let renderedLineCount: Int
    let cursorIsHidden: Bool
}

// MARK: - Actions
extension TerminalScreen {
    /// Returns the text that erases this screen's region, prints `line` above it, sets the cursor,
    /// and draws `region` in its place.
    ///
    /// Pass an empty `region` to only erase. The cursor is only written when its state changes.
    func makeRedraw(above line: String?, region: [String], cursorIsHidden: Bool) -> String {
        let printed = line.map { $0 + "\n" } ?? ""

        return makeErase() + printed + makeCursor(isHidden: cursorIsHidden) + region.joined(separator: "\n")
    }
}

// MARK: - Private Methods
private extension TerminalScreen {
    func makeErase() -> String {
        guard renderedLineCount > 0 else {
            return ""
        }

        let linesAboveCursor = renderedLineCount - 1
        let moveUp = linesAboveCursor > 0 ? TerminalStyle.cursorUp(linesAboveCursor) : ""

        return "\r" + moveUp + TerminalStyle.clearToEndOfScreen
    }

    func makeCursor(isHidden: Bool) -> String {
        guard isHidden != cursorIsHidden else {
            return ""
        }

        return isHidden ? TerminalStyle.hideCursor : TerminalStyle.showCursor
    }
}
