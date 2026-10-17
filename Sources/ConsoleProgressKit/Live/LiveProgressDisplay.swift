//
//  LiveProgressDisplay.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation
import Synchronization

/// Animates one spinner line per running activity on stderr, then replaces each with its outcome.
///
/// Running activities share a region at the bottom of the output that is redrawn in place. A
/// finished activity's ✓ or ✗ line, and any note, is printed above the region, so finished lines
/// stack up in order while running ones stay below. The region is redrawn by a timer on a private
/// queue, so spinners keep moving even while an activity blocks its own thread on a synchronous call.
/// Updates from an activity only change its state; the next tick draws them, so a fast stream of
/// updates costs no more than the frame rate, and ticks with nothing to animate or redraw are skipped.
///
/// While suspended for a prompt, the region is erased and nothing is drawn; lines finished in the
/// meantime are held and printed when the display resumes.
///
/// The region is kept within the terminal: lines are cut to its width, and when the region would be
/// taller than the terminal, output tails are dropped first, then the last activities are collapsed
/// into a single "and N more" line.
///
/// Once the terminal is restored, the display writes nothing more; activities still run and finish
/// unseen.
///
/// All state lives in a `Mutex`, and text is written while it is held, so writes reach the
/// terminal in the order the state changed.
public final class LiveProgressDisplay: Sendable {
    private let clock = ContinuousClock()
    private let state = Mutex(LiveDisplayState())
    private let timerQueue = DispatchQueue(label: "ProgressDisplay.LiveProgressDisplay")

    public init() { }
}

// MARK: - ProgressDisplay
extension LiveProgressDisplay: ProgressDisplay {
    public nonisolated(nonsending) func track<T>(_ title: String, operation: nonisolated(nonsending) (ActivityHandle) async throws -> T) async throws -> T {
        let id = UUID()
        let handle = ActivityHandle(send: { [weak self] update in
            self?.perform { $0.updating(update, id: id) }
        })

        perform { $0.starting(id: id, title: title) }

        return try await TimedActivity.run(clock: clock, operation: { try await operation(handle) }, finish: { succeeded, elapsed in
            perform { $0.finishing(id: id, succeeded: succeeded, elapsed: elapsed) }
        })
    }

    public func note(_ text: String, style: NoteStyle) {
        perform { $0.noting(text, style: style) }
    }

    public func suspended<T>(_ body: () throws -> T) rethrows -> T {
        perform { $0.suspending() }
        defer { perform { $0.resuming() } }

        return try body()
    }

    public func writeOutput(_ text: String) {
        state.withLock { state in
            guard !state.isStopped else {
                return
            }

            let transition = state.preparingForOutput()
            state = transition.state

            Self.writeError(transition.output)
            StandardStream.output.write(text + "\n")
        }
    }

    public func restoreTerminal() {
        perform { $0.stopping() }
    }
}

// MARK: - Private Methods
private extension LiveProgressDisplay {
    /// Stores the state `change` returns, starts or stops the timer to match it, and writes its text,
    /// all under the lock. Once stopped, `change` is skipped.
    func perform(_ change: (LiveDisplayState) -> LiveDisplayState.Transition) {
        state.withLock { state in
            guard !state.isStopped else {
                return
            }

            let transition = change(state)
            state = syncingTimer(for: transition.state)

            Self.writeError(transition.output)
        }
    }

    func syncingTimer(for state: LiveDisplayState) -> LiveDisplayState {
        if state.timerIsNeeded && state.timer == nil {
            return state.replacingTimer(makeTimer())
        }

        if !state.timerIsNeeded, let timer = state.timer {
            timer.cancel()

            return state.replacingTimer(nil)
        }

        return state
    }

    func makeTimer() -> any DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + Self.frameInterval, repeating: Self.frameInterval)
        timer.setEventHandler { [weak self] in
            self?.perform { $0.ticking() }
        }
        timer.resume()

        return timer
    }

    static func writeError(_ text: String) {
        guard !text.isEmpty else {
            return
        }

        StandardStream.error.write(text)
    }
}

// MARK: - Private Constants
private extension LiveProgressDisplay {
    static let frameInterval = DispatchTimeInterval.milliseconds(80)
}
