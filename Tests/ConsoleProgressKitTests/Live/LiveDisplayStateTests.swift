//
//  LiveDisplayStateTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
import Foundation
@testable import ConsoleProgressKit

struct LiveDisplayStateTests {
    @Test
    func `A display with no running activities does not need its timer`() {
        let sut = makeSUT(theme: .standard)

        #expect(!sut.timerIsNeeded)
    }

    @Test
    func `A display with a running activity needs its timer`() {
        let sut = makeSUT(theme: .standard)

        let started = sut.starting(id: UUID(), title: "Build").state

        #expect(started.timerIsNeeded)
    }

    @Test
    func `A display whose last activity finished no longer needs its timer`() {
        let sut = makeSUT(theme: .standard)
        let id = UUID()

        let finished = sut
            .starting(id: id, title: "Build").state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1)).state

        #expect(!finished.timerIsNeeded)
    }
}

// MARK: - Updates
extension LiveDisplayStateTests {
    @Test
    func `An activity's update is not drawn until the next tick`() {
        let sut = makeSUT(theme: .standard)
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .updating(.detail("compiling"), id: id)

        #expect(transition.output.isEmpty)
    }

    @Test
    func `An update for an activity that is not running writes nothing`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.updating(.detail("compiling"), id: UUID()).output.isEmpty)
    }

    @Test
    func `A tick with nothing to animate or redraw writes nothing`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.ticking().output.isEmpty)
    }

    @Test
    func `A note is written on its own line when no activity is running`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.noting("Using cached results", style: .info).output == "Using cached results\n")
    }
}

// MARK: - Suspension
extension LiveDisplayStateTests {
    @Test
    func `An activity that finishes while suspended is not written yet`() {
        let sut = makeSUT(theme: .standard)
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .suspending().state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1))

        #expect(transition.output.isEmpty)
    }

    @Test
    func `An activity that finished while suspended is written when the display resumes`() {
        let sut = makeSUT(theme: .standard)
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .suspending().state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1)).state
            .resuming()

        #expect(transition.output.contains("\u{1B}[32m✓\u{1B}[0m Build (1.0s)"))
    }

    @Test
    func `Making room for output while suspended writes nothing`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.suspending().state.preparingForOutput().output.isEmpty)
    }
}

// MARK: - Theme
extension LiveDisplayStateTests {
    @Test
    func `A running activity's spinner uses the theme's spinner color`() {
        let sut = makeSUT(theme: makeCustomTheme())

        #expect(sut.starting(id: UUID(), title: "Build").output.contains("\u{1B}[36m⠋\u{1B}[0m Build"))
    }

    @Test
    func `A running activity's progress bar uses the theme's progress bar color`() {
        let sut = makeSUT(theme: makeCustomTheme())
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .updating(.progress(completed: 2, total: 4), id: id).state
            .ticking()

        #expect(transition.output.contains("\u{1B}[95m██████████\u{1B}[0m░░░░░░░░░░ 2/4"))
    }

    @Test
    func `A succeeded activity's finished line uses the theme's success color`() {
        let sut = makeSUT(theme: makeCustomTheme())
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1))

        #expect(transition.output.contains("\u{1B}[92m✓\u{1B}[0m Build (1.0s)"))
    }

    @Test
    func `A failed activity's finished line uses the theme's failure color`() {
        let sut = makeSUT(theme: makeCustomTheme())
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .finishing(id: id, succeeded: false, elapsed: .seconds(1))

        #expect(transition.output.contains("\u{1B}[91m✗\u{1B}[0m Build (1.0s)"))
    }

    @Test
    func `A warning note uses the theme's warning color`() {
        let sut = makeSUT(theme: makeCustomTheme())

        #expect(sut.noting("Disk almost full", style: .warning).output == "\u{1B}[93m!\u{1B}[0m Disk almost full\n")
    }

    @Test
    func `An activity that finished while suspended keeps the theme's color when the display resumes`() {
        let sut = makeSUT(theme: makeCustomTheme())
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .suspending().state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1)).state
            .resuming()

        #expect(transition.output.contains("\u{1B}[92m✓\u{1B}[0m Build (1.0s)"))
    }

    @Test
    func `A warning noted while suspended keeps the theme's color when the display resumes`() {
        let sut = makeSUT(theme: makeCustomTheme())

        let transition = sut
            .suspending().state
            .noting("Disk almost full", style: .warning).state
            .resuming()

        #expect(transition.output.contains("\u{1B}[93m!\u{1B}[0m Disk almost full"))
    }
}

// MARK: - No Color
extension LiveDisplayStateTests {
    @Test
    func `A succeeded activity's symbol has no color when color is off`() {
        let sut = makeSUT(theme: nil)
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1))

        #expect(transition.output.contains("✓ Build (1.0s)"))
    }

    @Test
    func `A failed activity's symbol has no color when color is off`() {
        let sut = makeSUT(theme: nil)
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .finishing(id: id, succeeded: false, elapsed: .seconds(1))

        #expect(transition.output.contains("✗ Build (1.0s)"))
    }

    @Test
    func `A warning note's symbol has no color when color is off`() {
        let sut = makeSUT(theme: nil)

        #expect(sut.noting("Disk almost full", style: .warning).output == "! Disk almost full\n")
    }
}

// MARK: - Stopping
extension LiveDisplayStateTests {
    @Test
    func `A stopped display is marked as stopped`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.stopping().state.isStopped)
    }

    @Test
    func `Stopping a display that has drawn nothing only resets colors`() {
        let sut = makeSUT(theme: .standard)

        #expect(sut.stopping().output == "\u{1B}[0m")
    }
}

// MARK: - SUT
private extension LiveDisplayStateTests {
    func makeSUT(theme: ProgressTheme?) -> LiveDisplayState {
        return LiveDisplayState(theme: theme)
    }
}

// MARK: - Helpers
private extension LiveDisplayStateTests {
    func makeCustomTheme() -> ProgressTheme {
        return .init(spinner: .cyan, progressBar: .brightMagenta, success: .brightGreen, failure: .brightRed, warning: .brightYellow)
    }
}
