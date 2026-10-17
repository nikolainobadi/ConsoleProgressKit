//
//  ProgressDemo.swift
//  ProgressDemo
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation
import SwiftPickerKit
import ConsoleProgressKit
import NnArgumentParser
import NnShellKit

@main
struct ProgressDemo: NnRootCommand {
    static let configuration = CommandConfiguration(
        commandName: "progress-demo",
        abstract: "Runs simulated activities to try out the progress display."
    )

    @OptionGroup var interactivity: InteractivityOptions

    @Option(help: "The simulated scenario to run. Prompts for one when omitted.")
    var scenario: ProgressDemoScenario?

    static var defaultFactory: DemoContextFactory {
        return .init()
    }

    func run() async throws {
        let scenario = try scenario ?? pickScenario()
        let display = makeDisplay()

        switch scenario {
        case .singleSuccess:
            try await display.track(Self.chooseVersionTitle, operation: { _ in try await Task.sleep(for: .seconds(3)) })
        case .singleFailure:
            try await display.track(Self.chooseVersionTitle, operation: { _ in try await Self.simulate(step: .init(title: Self.chooseVersionTitle, duration: .seconds(2), fails: true)) })
        case .noteDuringStep:
            try await display.track(Self.buildAndTestTitle, operation: { _ in try await Self.simulateWork(display: display, noteAfter: .seconds(2), note: "Skipping doc updates: nothing changed since the last release.", style: .info, remaining: .seconds(2)) })
        case .warningDuringStep:
            try await display.track("Asking the AI to work out the build and test commands", operation: { _ in try await Self.simulateWork(display: display, noteAfter: .seconds(2), note: "The AI couldn't find a test command. Falling back to `swift test`.", style: .warning, remaining: .seconds(2)) })
        case .changingDetail:
            try await display.track("Publishing 1.3.0 to origin", operation: { activity in try await Self.simulateWork(activity: activity, details: ["pushing branch main", "creating tag 1.3.0", "pushing tag 1.3.0"], durationPerDetail: .milliseconds(1500)) })
        case .sequence:
            try await runSequence(display: display, steps: Self.shipSteps)
        case .sequenceFailure:
            try await runSequence(display: display, steps: Self.failingShipSteps)
        case .parallel:
            try await runParallel(display: display, steps: Self.docUpdateSteps, slots: SimulatedSlots(count: Self.docUpdateSteps.count))
        case .parallelCapped:
            try await runParallel(display: display, steps: Self.cappedDocUpdateSteps, slots: SimulatedSlots(count: 2))
        case .promptMidRun:
            try await runPromptMidRun(display: display, picker: Self.contextFactory.makePicker())
        case .outputMidRun:
            NnOutput.register(writer: ProgressAwareOutputWriter(display: display))
            try await runOutputMidRun(display: display)
        case .outputTail:
            try await display.track(Self.buildAndTestTitle, operation: { activity in try await Self.simulateBuild(activity: activity, lines: Self.buildLines, fails: false) })
        case .outputTailFailure:
            try await display.track(Self.buildAndTestTitle, operation: { activity in try await Self.simulateBuild(activity: activity, lines: Self.failingBuildLines, fails: true) })
        case .progressBar:
            try await display.track("Uploading release assets", operation: { activity in try await Self.simulateUpload(activity: activity, fileNames: Self.assetFileNames) })
        case .longLines:
            try await runLongLines(display: display)
        case .manySteps:
            try await runManySteps(display: display, count: 12)
        case .interrupt:
            registerInterruptCleanups(display: display)
            try await runChildProcesses(display: display)
        case .interruptDuringPrompt:
            registerInterruptCleanups(display: display)
            try await runPromptWithChildProcess(display: display, picker: Self.contextFactory.makePicker())
        }
    }
}

// MARK: - Private Methods
private extension ProgressDemo {
    func pickScenario() throws -> ProgressDemoScenario {
        return try Self.contextFactory.makePicker().requiredSingleSelection(
            prompt: "Which scenario do you want to run?",
            items: ProgressDemoScenario.allCases,
            flagHint: "--scenario",
            layout: .singleColumn,
            newScreen: true,
            showSelectedItemText: true
        )
    }

    func makeDisplay() -> any ProgressDisplay {
        if InteractionMode.current.isInteractive && TerminalCapabilities.standardErrorIsTerminal {
            return LiveProgressDisplay()
        }

        return PlainProgressDisplay()
    }

    static func simulateWork(display: any ProgressDisplay, noteAfter delay: Duration, note: String, style: NoteStyle, remaining: Duration) async throws {
        try await Task.sleep(for: delay)
        display.note(note, style: style)
        try await Task.sleep(for: remaining)
    }

    static func simulateWork(activity: ActivityHandle, details: [String], durationPerDetail: Duration) async throws {
        for detail in details {
            activity.update(detail: detail)
            try await Task.sleep(for: durationPerDetail)
        }
    }

    func runSequence(display: any ProgressDisplay, steps: [SimulatedStep]) async throws {
        for step in steps {
            try await display.track(step.title, operation: { _ in try await Self.simulate(step: step) })
        }
    }

    func runPromptMidRun(display: any ProgressDisplay, picker: any CommandLinePicker) async throws {
        async let backgroundUpdate: Void = display.track(Self.readmeTitle, operation: { _ in try await Task.sleep(for: .seconds(6)) })

        try await display.track(Self.chooseVersionTitle, operation: { _ in try await Task.sleep(for: .seconds(2)) })

        let releaseIsConfirmed = display.suspended { picker.getPermission(prompt: "The AI chose 1.3.0 (minor). Release as 1.3.0?") }
        display.note(releaseIsConfirmed ? "Releasing 1.3.0." : "Keeping the prepared release.", style: .info)

        try await display.track("Creating the GitHub release", operation: { _ in try await Task.sleep(for: .seconds(2)) })
        try await backgroundUpdate
    }

    func runOutputMidRun(display: any ProgressDisplay) async throws {
        async let backgroundUpdate: Void = display.track(Self.readmeTitle, operation: { _ in try await Task.sleep(for: .seconds(5)) })

        try await display.track(Self.chooseVersionTitle, operation: { _ in try await Task.sleep(for: .seconds(1)) })

        for line in Self.resultLines {
            try await Task.sleep(for: .milliseconds(800))
            NnOutput.write(line)
        }

        try await backgroundUpdate
    }

    func runLongLines(display: any ProgressDisplay) async throws {
        async let longTitle: Void = display.track(Self.longTitle, operation: { activity in try await Self.simulateWork(activity: activity, details: Self.longDetails, durationPerDetail: .seconds(3)) })
        async let longOutput: Void = display.track(Self.buildAndTestTitle, operation: { activity in try await Self.simulateBuild(activity: activity, lines: Self.longBuildLines, fails: false) })

        _ = try await (longTitle, longOutput)
    }

    func runManySteps(display: any ProgressDisplay, count: Int) async throws {
        let tasks = (1...count).map { number in
            DemoTask(title: "Building package \(number) of \(count)", operation: { activity in try await Self.simulateBuild(activity: activity, lines: Array(Self.buildLines.prefix(5 + number)), fails: false) })
        }

        try await runConcurrently(display: display, tasks: tasks)
    }

    func runParallel(display: any ProgressDisplay, steps: [SimulatedStep], slots: SimulatedSlots) async throws {
        let tasks = steps.map { step in
            DemoTask(title: step.title, operation: { activity in try await Self.simulate(step: step, activity: activity, slots: slots) })
        }

        try await runConcurrently(display: display, tasks: tasks)
    }

    func registerInterruptCleanups(display: any ProgressDisplay) {
        NnInterrupt.register(cleanup: { display.restoreTerminal() })
        NnInterrupt.register(cleanup: { ChildProcesses.terminateAll(gracePeriod: 2) })
    }

    func runChildProcesses(display: any ProgressDisplay) async throws {
        let asyncShell = Self.contextFactory.makeAsyncShell()
        let shell = Self.contextFactory.makeShell()
        let tasks = [
            DemoTask(title: "Running sleep 30 through AsyncNnShell (1)", operation: { _ in try await asyncShell.bash(Self.childCommand) }),
            DemoTask(title: "Running sleep 30 through AsyncNnShell (2)", operation: { _ in try await asyncShell.bash(Self.childCommand) }),
            DemoTask(title: "Running sleep 30 through NnShell on a background thread", operation: { _ in try await Self.runOnBackgroundThread(shell: shell, command: Self.childCommand) })
        ]

        try await runConcurrently(display: display, tasks: tasks)
    }

    func runPromptWithChildProcess(display: any ProgressDisplay, picker: any CommandLinePicker) async throws {
        let asyncShell = Self.contextFactory.makeAsyncShell()

        async let backgroundChild: Void = display.track("Running sleep 30 through AsyncNnShell", operation: { _ in try await asyncShell.bash(Self.childCommand) })

        try await Task.sleep(for: .seconds(1))

        let version = try display.suspended {
            try picker.requiredSingleSelection(
                prompt: "Press Ctrl-C to interrupt, or pick a version.",
                items: Self.versionOptions,
                layout: .singleColumn,
                newScreen: true,
                showSelectedItemText: true
            )
        }
        display.note("Chose \(version).", style: .info)

        try await backgroundChild
    }

    static func runOnBackgroundThread(shell: any Shell, command: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Thread.detachNewThread {
                do {
                    try shell.bash(command)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func runConcurrently(display: any ProgressDisplay, tasks: [DemoTask]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    try await display.track(task.title, operation: task.operation)
                }
            }

            try await group.waitForAll()
        }
    }

    static func simulate(step: SimulatedStep, activity: ActivityHandle, slots: SimulatedSlots) async throws {
        try await slots.run(onWait: activity.markWaiting, onResume: activity.markRunning, operation: { try await simulate(step: step) })
    }

    static func simulateBuild(activity: ActivityHandle, lines: [String], fails: Bool) async throws {
        for line in lines {
            try await Task.sleep(for: .milliseconds(200))
            activity.output(line: line)
        }

        if fails {
            throw ProgressDemoError.simulatedFailure
        }
    }

    static func simulateUpload(activity: ActivityHandle, fileNames: [String]) async throws {
        for (index, fileName) in fileNames.enumerated() {
            activity.progress(completed: index, total: fileNames.count)
            activity.update(detail: fileName)
            try await Task.sleep(for: .milliseconds(600))
        }

        activity.progress(completed: fileNames.count, total: fileNames.count)
    }

    static func simulate(step: SimulatedStep) async throws {
        try await Task.sleep(for: step.duration)

        if step.fails {
            throw ProgressDemoError.simulatedFailure
        }
    }
}

// MARK: - Simulated Steps
private extension ProgressDemo {
    static let chooseVersionTitle = "Asking the AI to choose a version"
    static let readmeTitle = "Updating README.md with readme"
    static let buildAndTestTitle = "Building and testing the project"
    static let childCommand = "sleep 30"
    static let versionOptions = ["1.3.0 (minor)", "1.2.1 (patch)", "2.0.0 (major)"]

    static let shipSteps: [SimulatedStep] = [
        .init(title: "Fetching tags from origin", duration: .seconds(1), fails: false),
        .init(title: Self.buildAndTestTitle, duration: .milliseconds(2500), fails: false),
        .init(title: Self.chooseVersionTitle, duration: .seconds(2), fails: false),
        .init(title: "Creating the GitHub release", duration: .milliseconds(1500), fails: false)
    ]

    static let docUpdateSteps: [SimulatedStep] = [
        .init(title: Self.readmeTitle, duration: .seconds(3), fails: false),
        .init(title: "Updating CHANGELOG.md with changelog", duration: .seconds(2), fails: false),
        .init(title: "Updating AGENTS.md with agents", duration: .milliseconds(4500), fails: false),
        .init(title: "Updating docs/Usage.md with usage", duration: .milliseconds(1500), fails: false)
    ]

    static let cappedDocUpdateSteps: [SimulatedStep] = [
        .init(title: Self.readmeTitle, duration: .seconds(3), fails: false),
        .init(title: "Updating CHANGELOG.md with changelog", duration: .milliseconds(1500), fails: false),
        .init(title: "Updating AGENTS.md with agents", duration: .milliseconds(2500), fails: false),
        .init(title: "Updating docs/Usage.md with usage", duration: .seconds(2), fails: false),
        .init(title: "Updating docs/Install.md with install", duration: .milliseconds(1500), fails: false)
    ]

    static let resultLines = [
        "Version: 1.3.0 (minor)",
        "Tag: 1.3.0 on main",
        "Release: https://github.com/example/project/releases/tag/1.3.0"
    ]

    static let buildLines = [
        "Building for debugging...",
        "Compiling ProgressDisplay ActivityHandle.swift",
        "Compiling ProgressDisplay ActivityLine.swift",
        "Compiling ProgressDisplay DetailLine.swift",
        "Compiling ProgressDisplay LiveProgressDisplay.swift",
        "Compiling ProgressDisplay PlainProgressDisplay.swift",
        "Compiling nnex Nnex.swift",
        "Compiling nnex ShipPackage.swift",
        "Linking nnex",
        "Build complete! (4.21s)",
        "Test Suite 'All tests' started",
        "✔ Test parsesVersion() passed",
        "✔ Test bumpsMinor() passed",
        "✔ Test writesReleaseNotes() passed",
        "Test run with 3 tests passed"
    ]

    static let failingBuildLines = [
        "Building for debugging...",
        "Compiling nnex Nnex.swift",
        "Compiling nnex ShipPackage.swift",
        "Linking nnex",
        "Build complete! (3.87s)",
        "Test Suite 'All tests' started",
        "✔ Test parsesVersion() passed",
        "✘ Test bumpsMinor() failed",
        "  Expectation failed: (version → 1.3.0) == 1.2.1",
        "✔ Test writesReleaseNotes() passed",
        "Test run with 3 tests: 1 failed"
    ]

    static let assetFileNames = [
        "nnex-arm64.tar.gz",
        "nnex-x86_64.tar.gz",
        "nnex-arm64.sha256",
        "nnex-x86_64.sha256",
        "nnex.1",
        "LICENSE",
        "release-notes.md"
    ]

    static let longTitle = "Updating Documentation/Guides/GettingStarted/InstallingAndConfiguringTheCommandLineTool.md with getting-started-guide"

    static let longDetails = [
        "reading every source file changed since 1.2.0 so the guide matches the current flags and defaults",
        "rewriting the installation section to cover Homebrew, Mint, and building from source on macOS 15 and later",
        "checking every code sample in the guide still compiles against the public API of the current release"
    ]

    static let longBuildLines = (1...45).map { "[\($0)/45] Compiling ProdBossReleaseKit Sources/ProdBossReleaseKit/Pending/UpdateDocumentationUseCase+StagingAndRefreshing\($0).swift" }

    static let failingShipSteps: [SimulatedStep] = [
        .init(title: "Fetching tags from origin", duration: .seconds(1), fails: false),
        .init(title: Self.buildAndTestTitle, duration: .milliseconds(2500), fails: false),
        .init(title: "Pushing tag 1.3.0 to origin", duration: .milliseconds(1500), fails: true),
        .init(title: "Creating the GitHub release", duration: .milliseconds(1500), fails: false)
    ]
}

// MARK: - Dependencies
actor SimulatedSlots {
    private var freeCount: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(count: Int) {
        freeCount = count
    }

    func run(onWait: @Sendable () -> Void, onResume: @Sendable () -> Void, operation: () async throws -> Void) async throws {
        if freeCount > 0 {
            freeCount -= 1
        } else {
            onWait()
            await withCheckedContinuation { waiters.append($0) }
            onResume()
        }

        defer { release() }

        try await operation()
    }
}

// MARK: - Private Methods
private extension SimulatedSlots {
    func release() {
        guard waiters.isEmpty else {
            waiters.removeFirst().resume()
            return
        }

        freeCount += 1
    }
}

struct DemoTask: Sendable {
    let title: String
    let operation: @Sendable (ActivityHandle) async throws -> Void
}

struct SimulatedStep {
    let title: String
    let duration: Duration
    let fails: Bool
}

enum ProgressDemoScenario: String, CaseIterable, ExpressibleByArgument {
    case singleSuccess = "single-success"
    case singleFailure = "single-failure"
    case noteDuringStep = "note-during-step"
    case warningDuringStep = "warning-during-step"
    case changingDetail = "changing-detail"
    case sequence = "sequence"
    case sequenceFailure = "sequence-failure"
    case parallel = "parallel"
    case parallelCapped = "parallel-capped"
    case promptMidRun = "prompt-mid-run"
    case outputMidRun = "output-mid-run"
    case outputTail = "output-tail"
    case outputTailFailure = "output-tail-failure"
    case progressBar = "progress-bar"
    case longLines = "long-lines"
    case manySteps = "many-steps"
    case interrupt = "interrupt"
    case interruptDuringPrompt = "interrupt-during-prompt"
}

// MARK: - DisplayablePickerItem
extension ProgressDemoScenario: DisplayablePickerItem {
    var displayName: String {
        switch self {
        case .singleSuccess:
            return "Single step that succeeds"
        case .singleFailure:
            return "Single step that fails"
        case .noteDuringStep:
            return "Note printed while a step runs"
        case .warningDuringStep:
            return "Warning printed while a step runs"
        case .changingDetail:
            return "Step whose detail changes while it runs"
        case .sequence:
            return "Several steps, one after another"
        case .sequenceFailure:
            return "Several steps where one fails partway"
        case .parallel:
            return "Several steps at the same time"
        case .parallelCapped:
            return "Several steps limited to two at a time"
        case .promptMidRun:
            return "Prompt while another step is running"
        case .outputMidRun:
            return "Results printed to stdout while a step is running"
        case .outputTail:
            return "Build output shown as a short rolling tail"
        case .outputTailFailure:
            return "Build output that fails and shows more lines"
        case .progressBar:
            return "Progress bar for a known number of steps"
        case .longLines:
            return "Lines longer than the terminal is wide"
        case .manySteps:
            return "More steps than the terminal is tall"
        case .interrupt:
            return "Ctrl-C while real child processes run"
        case .interruptDuringPrompt:
            return "Ctrl-C during a prompt while a child process runs"
        }
    }
}

enum ProgressDemoError: Error {
    case simulatedFailure
}

// MARK: - LocalizedError
extension ProgressDemoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .simulatedFailure:
            return "The simulated activity failed on purpose."
        }
    }
}
