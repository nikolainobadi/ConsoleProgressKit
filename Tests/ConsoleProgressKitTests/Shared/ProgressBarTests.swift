//
//  ProgressBarTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct ProgressBarTests {
    @Test
    func `Half the steps completed fill half the bar`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 5, total: 10) == "██████████░░░░░░░░░░ 5/10")
    }

    @Test
    func `All steps completed fill the whole bar`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 4, total: 4) == "████████████████████ 4/4")
    }
}

// MARK: - Out of Range Counts
extension ProgressBarTests {
    @Test
    func `A completed count above the total is shown as fully complete`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 15, total: 10) == "████████████████████ 10/10")
    }

    @Test
    func `A negative completed count is shown as no progress`() {
        let sut = makeSUT()

        #expect(sut.make(completed: -3, total: 10) == "░░░░░░░░░░░░░░░░░░░░ 0/10")
    }

    @Test
    func `A zero total is shown as a single step`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 0, total: 0) == "░░░░░░░░░░░░░░░░░░░░ 0/1")
    }
}

// MARK: - SUT
private extension ProgressBarTests {
    func makeSUT() -> ProgressBar.Type {
        return ProgressBar.self
    }
}
