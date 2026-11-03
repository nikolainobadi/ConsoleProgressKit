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

        #expect(sut.make(completed: 5, total: 10, fillColor: nil) == "██████████░░░░░░░░░░ 5/10")
    }

    @Test
    func `All steps completed fill the whole bar`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 4, total: 4, fillColor: nil) == "████████████████████ 4/4")
    }
}

// MARK: - Colors
extension ProgressBarTests {
    @Test
    func `A fill color applies only to the filled cells`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 5, total: 10, fillColor: .cyan) == "\u{1B}[36m██████████\u{1B}[0m░░░░░░░░░░ 5/10")
    }

    @Test
    func `A bar with no filled cells stays uncolored even with a fill color`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 0, total: 10, fillColor: .cyan) == "░░░░░░░░░░░░░░░░░░░░ 0/10")
    }
}

// MARK: - Out of Range Counts
extension ProgressBarTests {
    @Test
    func `A completed count above the total is shown as fully complete`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 15, total: 10, fillColor: nil) == "████████████████████ 10/10")
    }

    @Test
    func `A negative completed count is shown as no progress`() {
        let sut = makeSUT()

        #expect(sut.make(completed: -3, total: 10, fillColor: nil) == "░░░░░░░░░░░░░░░░░░░░ 0/10")
    }

    @Test
    func `The largest possible counts fill the whole bar`() {
        let sut = makeSUT()

        #expect(sut.make(completed: Int.max, total: Int.max, fillColor: nil) == "████████████████████ \(Int.max)/\(Int.max)")
    }

    @Test
    func `Half of a very large total fills half the bar`() {
        let sut = makeSUT()
        let total = Int.max - 1
        let completed = total / 2

        #expect(sut.make(completed: completed, total: total, fillColor: nil) == "██████████░░░░░░░░░░ \(completed)/\(total)")
    }

    @Test
    func `A zero total is shown as a single step`() {
        let sut = makeSUT()

        #expect(sut.make(completed: 0, total: 0, fillColor: nil) == "░░░░░░░░░░░░░░░░░░░░ 0/1")
    }
}

// MARK: - SUT
private extension ProgressBarTests {
    func makeSUT() -> ProgressBar.Type {
        return ProgressBar.self
    }
}
