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

    /// Returns the region's lines. A `nil` theme draws them without color or dimming.
    static func lines(for activities: [RunningActivity], frameIndex: Int, size: TerminalSize?, theme: ProgressTheme?) -> [String] {
        let frame = TerminalStyle.apply(theme?.spinner, to: frames[frameIndex])
        let rows = activities.map { makeRows(for: $0, frame: frame, theme: theme) }

        guard let size else {
            return rows.flatMap { [$0.title] + $0.tail }
        }

        return fitToHeight(rows, height: size.height, theme: theme).map { LineFitter.fit($0, width: size.width) }
    }
}

// MARK: - Private Methods
private extension RegionLayout {
    static func dimmed(_ text: String, theme: ProgressTheme?) -> String {
        return theme == nil ? text : TerminalStyle.apply(TerminalStyle.dim, to: text)
    }

    static func fitToHeight(_ rows: [ActivityRows], height: Int, theme: ProgressTheme?) -> [String] {
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
        let moreLine = dimmed("… and \(titles.count - shownCount) more", theme: theme)

        return Array(titles.prefix(shownCount)) + [moreLine]
    }

    static func makeRows(for activity: RunningActivity, frame: String, theme: ProgressTheme?) -> ActivityRows {
        guard !activity.isWaiting else {
            let waitingLine = dimmed(waitingSymbol + " " + activity.title + " (waiting)", theme: theme)

            return .init(title: waitingLine, tail: [])
        }

        let tail = activity.outputLines.suffix(visibleOutputLineCount).map { dimmed(outputIndent + $0, theme: theme) }

        return .init(title: frame + " " + makeTitle(for: activity, barColor: theme?.progressBar), tail: tail)
    }

    static func makeTitle(for activity: RunningActivity, barColor: TerminalColor?) -> String {
        guard let progress = activity.progress else {
            return DetailLine.make(title: activity.title, detail: activity.detail)
        }

        let bar = ProgressBar.make(completed: progress.completed, total: progress.total, fillColor: barColor)

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
