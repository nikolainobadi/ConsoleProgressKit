//
//  RegionLayout.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// Lays out the live region's lines for the running activities, fitted to the terminal.
///
/// Lines are cut to the terminal's width. When the region would be taller than the terminal,
/// output tails are dropped first, then the last activities are collapsed into one "and N more" line.
enum RegionLayout {
    static let frameCount = frames.count
    static let outputIndent = "    "

    static func lines(for activities: [RunningActivity], frameIndex: Int, size: TerminalSize?) -> [String] {
        let frame = frames[frameIndex]
        let rows = activities.map { makeRows(for: $0, frame: frame) }

        guard let size else {
            return rows.flatMap { [$0.title] + $0.tail }
        }

        return fitToHeight(rows, height: size.height).map { LineFitter.fit($0, width: size.width) }
    }
}

// MARK: - Private Methods
private extension RegionLayout {
    static func fitToHeight(_ rows: [ActivityRows], height: Int) -> [String] {
        let maximumLineCount = max(height - 1, 1)
        let titles = rows.map(\.title)
        let fullLineCount = titles.count + rows.reduce(0) { $0 + $1.tail.count }

        if fullLineCount <= maximumLineCount {
            return rows.flatMap { [$0.title] + $0.tail }
        }

        if titles.count <= maximumLineCount {
            return titles
        }

        let shownCount = maximumLineCount - 1
        let moreLine = TerminalStyle.apply(TerminalStyle.dim, to: "… and \(titles.count - shownCount) more", colorsAreEnabled: true)

        return Array(titles.prefix(shownCount)) + [moreLine]
    }

    static func makeRows(for activity: RunningActivity, frame: String) -> ActivityRows {
        guard !activity.isWaiting else {
            let waitingLine = TerminalStyle.apply(TerminalStyle.dim, to: waitingSymbol + " " + activity.title + " (waiting)", colorsAreEnabled: true)

            return .init(title: waitingLine, tail: [])
        }

        let tail = activity.outputLines.suffix(visibleOutputLineCount).map { TerminalStyle.apply(TerminalStyle.dim, to: outputIndent + $0, colorsAreEnabled: true) }

        return .init(title: frame + " " + makeTitle(for: activity), tail: tail)
    }

    static func makeTitle(for activity: RunningActivity) -> String {
        guard let progress = activity.progress else {
            return DetailLine.make(title: activity.title, detail: activity.detail)
        }

        let bar = ProgressBar.make(completed: progress.completed, total: progress.total)

        return DetailLine.make(title: activity.title + " " + bar, detail: activity.detail)
    }
}

// MARK: - Private Constants
private extension RegionLayout {
    static let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    static let waitingSymbol = "◦"
    static let visibleOutputLineCount = 5
}

// MARK: - Dependencies
private struct ActivityRows {
    let title: String
    let tail: [String]
}
