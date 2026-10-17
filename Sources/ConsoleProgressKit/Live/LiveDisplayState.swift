//
//  LiveDisplayState.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

/// Everything `LiveProgressDisplay` changes while it runs, and the text each change draws.
///
/// The state never changes in place. Each method returns a ``Transition``: the next state, and the
/// text to write to stderr, or an empty string when nothing should be written. The display stores the
/// next state and writes the text under its lock, so writes happen in the same order the state changed.
///
/// Once stopped, the display makes no further changes, so these methods assume the state is running.
struct LiveDisplayState {
    private var activities: [RunningActivity] = []
    private var heldLines: [String] = []
    private var frameIndex = 0
    private var isSuspended = false
    private var regionIsStale = false
    private var screen = TerminalScreen(renderedLineCount: 0, cursorIsHidden: false)
    private(set) var isStopped = false
    private(set) var timer: (any DispatchSourceTimer)?
}

// MARK: - Actions
extension LiveDisplayState {
    var timerIsNeeded: Bool {
        return !activities.isEmpty && !isStopped
    }

    func replacingTimer(_ timer: (any DispatchSourceTimer)?) -> LiveDisplayState {
        var next = self
        next.timer = timer

        return next
    }

    func starting(id: UUID, title: String) -> Transition {
        var next = self
        next.frameIndex = activities.isEmpty ? 0 : frameIndex
        next.activities.append(.init(id: id, title: title))

        return next.drawing(above: nil)
    }

    func finishing(id: UUID, succeeded: Bool, elapsed: Duration) -> Transition {
        guard let index = activities.firstIndex(where: { $0.id == id }) else {
            return unchanged
        }

        var next = self
        let activity = next.activities.remove(at: index)

        return next.drawing(above: Self.makeFinishedLines(for: activity, succeeded: succeeded, elapsed: elapsed))
    }

    func updating(_ update: ActivityUpdate, id: UUID) -> Transition {
        guard let index = activities.firstIndex(where: { $0.id == id }) else {
            return unchanged
        }

        var next = self
        next.activities[index] = activities[index].applying(update, keptOutputLineCount: Self.failureOutputLineCount)
        next.regionIsStale = true

        return .init(state: next, output: "")
    }

    func noting(_ text: String, style: NoteStyle) -> Transition {
        return drawing(above: NoteLine.make(text: text, style: style, colorsAreEnabled: true))
    }

    /// Erases the region so a line can be written to stdout; the next tick draws it again.
    func preparingForOutput() -> Transition {
        guard !isSuspended else {
            return unchanged
        }

        var next = self
        next.regionIsStale = true

        return next.redrawing(above: nil, region: [], cursorIsHidden: !activities.isEmpty)
    }

    func suspending() -> Transition {
        var next = self
        next.isSuspended = true

        return next.redrawing(above: nil, region: [], cursorIsHidden: false)
    }

    func resuming() -> Transition {
        var next = self
        next.isSuspended = false
        next.heldLines = []

        return next.drawing(above: heldLines.isEmpty ? nil : heldLines.joined(separator: "\n"))
    }

    func ticking() -> Transition {
        let somethingIsSpinning = activities.contains { !$0.isWaiting }

        guard somethingIsSpinning || regionIsStale else {
            return unchanged
        }

        var next = self
        next.frameIndex = (frameIndex + 1) % RegionLayout.frameCount

        return next.drawing(above: nil)
    }

    func stopping() -> Transition {
        var next = self
        next.isStopped = true
        next.heldLines = []

        let erased = next.redrawing(above: nil, region: [], cursorIsHidden: false)

        return .init(state: erased.state, output: erased.output + TerminalStyle.reset)
    }
}

// MARK: - Private Methods
private extension LiveDisplayState {
    var unchanged: Transition {
        return .init(state: self, output: "")
    }

    func drawing(above line: String?) -> Transition {
        var next = self

        guard !isSuspended else {
            next.heldLines += line.map { [$0] } ?? []

            return .init(state: next, output: "")
        }

        let region = RegionLayout.lines(for: activities, frameIndex: frameIndex, size: TerminalCapabilities.standardErrorSize)
        next.regionIsStale = false

        return next.redrawing(above: line, region: region, cursorIsHidden: !activities.isEmpty)
    }

    func redrawing(above line: String?, region: [String], cursorIsHidden: Bool) -> Transition {
        var next = self
        next.screen = .init(renderedLineCount: region.count, cursorIsHidden: cursorIsHidden)

        return .init(state: next, output: screen.makeRedraw(above: line, region: region, cursorIsHidden: cursorIsHidden))
    }

    static func makeFinishedLines(for activity: RunningActivity, succeeded: Bool, elapsed: Duration) -> String {
        let finishedLine = ActivityLine.finished(title: activity.title, succeeded: succeeded, elapsed: elapsed, colorsAreEnabled: true)
        let failureLines = succeeded ? [] : activity.outputLines.map { RegionLayout.outputIndent + $0 }

        return ([finishedLine] + failureLines).joined(separator: "\n")
    }
}

// MARK: - Private Constants
private extension LiveDisplayState {
    static let failureOutputLineCount = 20
}

// MARK: - Dependencies
extension LiveDisplayState {
    /// The state after a change, and the text that shows it.
    struct Transition {
        let state: LiveDisplayState
        let output: String
    }
}
