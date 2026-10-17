//
//  RunningActivityTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
import Foundation
@testable import ConsoleProgressKit

struct RunningActivityTests {
    @Test
    func `A detail update replaces the activity's detail`() throws {
        let sut = makeSUT()
        let detail = "compiling"

        let updated = sut.applying(.detail(detail), keptOutputLineCount: 20)

        let shownDetail = try #require(updated.detail)
        #expect(shownDetail == detail)
    }

    @Test
    func `An empty detail update clears the activity's detail`() {
        let sut = makeSUT()

        let updated = sut
            .applying(.detail("compiling"), keptOutputLineCount: 20)
            .applying(.detail(nil), keptOutputLineCount: 20)

        #expect(updated.detail == nil)
    }

    @Test
    func `A progress update records the completed and total steps`() throws {
        let sut = makeSUT()
        let completed = 3
        let total = 5

        let updated = sut.applying(.progress(completed: completed, total: total), keptOutputLineCount: 20)

        let progress = try #require(updated.progress)
        #expect(progress.completed == completed)
        #expect(progress.total == total)
    }
}

// MARK: - Waiting
extension RunningActivityTests {
    @Test
    func `Marking an activity as waiting shows it as waiting`() {
        let sut = makeSUT()

        let updated = sut.applying(.waiting(true), keptOutputLineCount: 20)

        #expect(updated.isWaiting)
    }

    @Test
    func `Marking a waiting activity as running shows it as running again`() {
        let sut = makeSUT()

        let updated = sut
            .applying(.waiting(true), keptOutputLineCount: 20)
            .applying(.waiting(false), keptOutputLineCount: 20)

        #expect(!updated.isWaiting)
    }
}

// MARK: - Output
extension RunningActivityTests {
    @Test
    func `Output lines are kept in the order they arrive`() {
        let sut = makeSUT()

        let updated = sut
            .applying(.output("first"), keptOutputLineCount: 20)
            .applying(.output("second"), keptOutputLineCount: 20)

        #expect(updated.outputLines == ["first", "second"])
    }

    @Test
    func `Only the most recent output lines are kept once the limit is reached`() {
        let sut = makeSUT()

        let updated = sut
            .applying(.output("first"), keptOutputLineCount: 2)
            .applying(.output("second"), keptOutputLineCount: 2)
            .applying(.output("third"), keptOutputLineCount: 2)

        #expect(updated.outputLines == ["second", "third"])
    }
}

// MARK: - SUT
private extension RunningActivityTests {
    func makeSUT() -> RunningActivity {
        return RunningActivity(id: UUID(), title: "Build")
    }
}
