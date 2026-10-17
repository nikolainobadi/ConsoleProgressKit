//
//  RegionLayoutTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
import Foundation
@testable import ConsoleProgressKit

struct RegionLayoutTests {
    @Test
    func `A running activity is shown with a spinner frame before its title`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == ["⠋ Build"])
    }

    @Test
    func `The frame index selects which spinner frame is shown`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 1, size: nil) == ["⠙ Build"])
    }

    @Test
    func `An activity's detail is shown after its title`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.detail("compiling")])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == ["⠋ Build — compiling"])
    }

    @Test
    func `An activity with known steps shows a progress bar after its title`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == ["⠋ Build ██████████░░░░░░░░░░ 2/4"])
    }

    @Test
    func `A waiting activity is dimmed and marked as waiting instead of spinning`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.waiting(true)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == ["\u{1B}[2m◦ Build (waiting)\u{1B}[0m"])
    }
}

// MARK: - Output Tail
extension RegionLayoutTests {
    @Test
    func `Only the last five output lines are shown under a running activity, dimmed and indented`() {
        let sut = makeSUT()
        let outputs = (1...7).map { ActivityUpdate.output("line \($0)") }
        let activities = [makeActivity(title: "Build", updates: outputs)]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == [
            "⠋ Build",
            "\u{1B}[2m    line 3\u{1B}[0m",
            "\u{1B}[2m    line 4\u{1B}[0m",
            "\u{1B}[2m    line 5\u{1B}[0m",
            "\u{1B}[2m    line 6\u{1B}[0m",
            "\u{1B}[2m    line 7\u{1B}[0m"
        ])
    }

    @Test
    func `A waiting activity hides its output`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.output("line 1"), .waiting(true)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil) == ["\u{1B}[2m◦ Build (waiting)\u{1B}[0m"])
    }
}

// MARK: - Fitting the Terminal
extension RegionLayoutTests {
    @Test
    func `Output lines are dropped first when the region is taller than the terminal`() {
        let sut = makeSUT()
        let activities = [
            makeActivity(title: "Build", updates: [.output("line 1")]),
            makeActivity(title: "Test", updates: [])
        ]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 80, height: 3)) == ["⠋ Build", "⠋ Test"])
    }

    @Test
    func `Activities that still don't fit are collapsed into a count of the rest`() {
        let sut = makeSUT()
        let activities = [
            makeActivity(title: "Build", updates: []),
            makeActivity(title: "Test", updates: []),
            makeActivity(title: "Lint", updates: [])
        ]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 80, height: 3)) == ["⠋ Build", "\u{1B}[2m… and 2 more\u{1B}[0m"])
    }

    @Test
    func `Lines wider than the terminal are cut to its width`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Building", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 6, height: 10)) == ["⠋ Bu…\u{1B}[0m"])
    }
}

// MARK: - SUT
private extension RegionLayoutTests {
    func makeSUT() -> RegionLayout.Type {
        return RegionLayout.self
    }
}

// MARK: - Helpers
private extension RegionLayoutTests {
    func makeActivity(title: String, updates: [ActivityUpdate]) -> RunningActivity {
        return updates.reduce(RunningActivity(id: UUID(), title: title)) { activity, update in
            activity.applying(update, keptOutputLineCount: 20)
        }
    }
}
