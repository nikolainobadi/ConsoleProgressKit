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

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == ["⠋ Build"])
    }

    @Test
    func `The frame index selects which spinner frame is shown`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 1, size: nil, theme: .standard) == ["⠙ Build"])
    }

    @Test
    func `An activity's detail is shown after its title`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.detail("compiling")])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == ["⠋ Build — compiling"])
    }

    @Test
    func `An activity with known steps shows a progress bar after its title`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == ["⠋ Build ██████████░░░░░░░░░░ 2/4"])
    }

    @Test
    func `A waiting activity is dimmed and marked as waiting instead of spinning`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.waiting(true)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == ["\u{1B}[2m◦ Build (waiting)\u{1B}[0m"])
    }
}

// MARK: - Output Tail
extension RegionLayoutTests {
    @Test
    func `Only the last five output lines are shown under a running activity, dimmed and indented`() {
        let sut = makeSUT()
        let outputs = (1...7).map { ActivityUpdate.output("line \($0)") }
        let activities = [makeActivity(title: "Build", updates: outputs)]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == [
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

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: .standard) == ["\u{1B}[2m◦ Build (waiting)\u{1B}[0m"])
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

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 80, height: 3), theme: .standard) == ["⠋ Build", "⠋ Test"])
    }

    @Test
    func `Activities that still don't fit are collapsed into a count of the rest`() {
        let sut = makeSUT()
        let activities = [
            makeActivity(title: "Build", updates: []),
            makeActivity(title: "Test", updates: []),
            makeActivity(title: "Lint", updates: [])
        ]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 80, height: 3), theme: .standard) == ["⠋ Build", "\u{1B}[2m… and 2 more\u{1B}[0m"])
    }

    @Test
    func `Lines wider than the terminal are cut to its width`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Building", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 6, height: 10), theme: .standard) == ["⠋ Bu…\u{1B}[0m"])
    }

    @Test
    func `A colored spinner's escape codes do not count toward the terminal's width`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]
        let theme = makeTheme(spinner: .cyan, progressBar: nil)

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 8, height: 10), theme: theme) == ["\u{1B}[36m⠋\u{1B}[0m Build"])
    }

    @Test
    func `A line with a colored spinner is cut to the terminal's width`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Building", updates: [])]
        let theme = makeTheme(spinner: .cyan, progressBar: nil)

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 6, height: 10), theme: theme) == ["\u{1B}[36m⠋\u{1B}[0m Bu…\u{1B}[0m"])
    }

    @Test
    func `A colored bar cut partway through its filled cells ends its color before the cut`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]
        let theme = makeTheme(spinner: nil, progressBar: .magenta)

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 12, height: 10), theme: theme) == ["⠋ Build \u{1B}[35m██\u{1B}[0m…\u{1B}[0m"])
    }
}

// MARK: - Colors
extension RegionLayoutTests {
    @Test
    func `The spinner frame uses the theme's spinner color`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]
        let theme = makeTheme(spinner: .cyan, progressBar: nil)

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: theme) == ["\u{1B}[36m⠋\u{1B}[0m Build"])
    }

    @Test
    func `The progress bar's filled cells use the theme's progress bar color`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]
        let theme = makeTheme(spinner: nil, progressBar: .magenta)

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: theme) == ["⠋ Build \u{1B}[35m██████████\u{1B}[0m░░░░░░░░░░ 2/4"])
    }

    @Test
    func `A progress bar with no color of its own does not take the spinner's color`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]
        let theme = makeTheme(spinner: .cyan, progressBar: nil)

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: theme) == ["\u{1B}[36m⠋\u{1B}[0m Build ██████████░░░░░░░░░░ 2/4"])
    }

    @Test
    func `A waiting activity stays dim whatever the theme's spinner color`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.waiting(true)])]
        let theme = makeTheme(spinner: .cyan, progressBar: nil)

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: theme) == ["\u{1B}[2m◦ Build (waiting)\u{1B}[0m"])
    }
}

// MARK: - No Color
extension RegionLayoutTests {
    @Test
    func `A spinner has no color when color is off`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: nil) == ["⠋ Build"])
    }

    @Test
    func `A progress bar has no color when color is off`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.progress(completed: 2, total: 4)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: nil) == ["⠋ Build ██████████░░░░░░░░░░ 2/4"])
    }

    @Test
    func `A waiting activity is not dimmed when color is off`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.waiting(true)])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: nil) == ["◦ Build (waiting)"])
    }

    @Test
    func `Output lines are not dimmed when color is off`() {
        let sut = makeSUT()
        let activities = [makeActivity(title: "Build", updates: [.output("line 1")])]

        #expect(sut.lines(for: activities, frameIndex: 0, size: nil, theme: nil) == ["⠋ Build", "    line 1"])
    }

    @Test
    func `The count of collapsed activities is not dimmed when color is off`() {
        let sut = makeSUT()
        let activities = [
            makeActivity(title: "Build", updates: []),
            makeActivity(title: "Test", updates: []),
            makeActivity(title: "Lint", updates: [])
        ]

        #expect(sut.lines(for: activities, frameIndex: 0, size: TerminalSize(width: 80, height: 3), theme: nil) == ["⠋ Build", "… and 2 more"])
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
    func makeTheme(spinner: TerminalColor?, progressBar: TerminalColor?) -> ProgressTheme {
        return .init(spinner: spinner, progressBar: progressBar, success: .green, failure: .red, warning: .yellow)
    }

    func makeActivity(title: String, updates: [ActivityUpdate]) -> RunningActivity {
        return updates.reduce(RunningActivity(id: UUID(), title: title)) { activity, update in
            activity.applying(update, keptOutputLineCount: 20)
        }
    }
}
