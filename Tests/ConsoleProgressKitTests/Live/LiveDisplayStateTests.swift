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
        let sut = makeSUT()

        #expect(!sut.timerIsNeeded)
    }

    @Test
    func `A display with a running activity needs its timer`() {
        let sut = makeSUT()

        let started = sut.starting(id: UUID(), title: "Build").state

        #expect(started.timerIsNeeded)
    }

    @Test
    func `A display whose last activity finished no longer needs its timer`() {
        let sut = makeSUT()
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
        let sut = makeSUT()
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .updating(.detail("compiling"), id: id)

        #expect(transition.output.isEmpty)
    }

    @Test
    func `An update for an activity that is not running writes nothing`() {
        let sut = makeSUT()

        #expect(sut.updating(.detail("compiling"), id: UUID()).output.isEmpty)
    }

    @Test
    func `A tick with nothing to animate or redraw writes nothing`() {
        let sut = makeSUT()

        #expect(sut.ticking().output.isEmpty)
    }

    @Test
    func `A note is written on its own line when no activity is running`() {
        let sut = makeSUT()

        #expect(sut.noting("Using cached results", style: .info).output == "Using cached results\n")
    }
}

// MARK: - Suspension
extension LiveDisplayStateTests {
    @Test
    func `An activity that finishes while suspended is not written yet`() {
        let sut = makeSUT()
        let id = UUID()

        let transition = sut
            .starting(id: id, title: "Build").state
            .suspending().state
            .finishing(id: id, succeeded: true, elapsed: .seconds(1))

        #expect(transition.output.isEmpty)
    }

    @Test
    func `An activity that finished while suspended is written when the display resumes`() {
        let sut = makeSUT()
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
        let sut = makeSUT()

        #expect(sut.suspending().state.preparingForOutput().output.isEmpty)
    }
}

// MARK: - Stopping
extension LiveDisplayStateTests {
    @Test
    func `A stopped display is marked as stopped`() {
        let sut = makeSUT()

        #expect(sut.stopping().state.isStopped)
    }

    @Test
    func `Stopping a display that has drawn nothing only resets colors`() {
        let sut = makeSUT()

        #expect(sut.stopping().output == "\u{1B}[0m")
    }
}

// MARK: - SUT
private extension LiveDisplayStateTests {
    func makeSUT() -> LiveDisplayState {
        return LiveDisplayState()
    }
}
