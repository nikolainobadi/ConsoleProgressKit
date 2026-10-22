//
//  MockProgressDisplayTests.swift
//  ConsoleProgressTestingTests
//
//  Created by Nikolai Nobadi on 10/21/26.
//

import Testing
@testable import ConsoleProgressTesting

struct MockProgressDisplayTests {
    @Test
    func `A tracked activity is recorded with its title`() async throws {
        let sut = makeSUT()
        let title = "Build"

        try await sut.track(title) { _ in }

        #expect(sut.activities.map(\.title) == [title])
    }

    @Test
    func `Tracked titles are listed in the order the activities started`() async throws {
        let sut = makeSUT()

        try await sut.track("Fetch") { _ in }
        try await sut.track("Build") { _ in }
        try await sut.track("Upload") { _ in }

        #expect(sut.trackedTitles == ["Fetch", "Build", "Upload"])
    }

    @Test
    func `Every handle update is recorded on its activity in the order it was sent`() async throws {
        let sut = makeSUT()

        try await sut.track("Build") { handle in
            handle.update(detail: "compiling")
            handle.update(detail: nil)
            handle.markWaiting()
            handle.markRunning()
            handle.output(line: "Compiling main.swift")
            handle.progress(completed: 1, total: 3)
        }

        let activity = try #require(sut.activities.first)
        #expect(activity.updates == [
            .detail("compiling"),
            .detail(nil),
            .waiting,
            .running,
            .output("Compiling main.swift"),
            .progress(completed: 1, total: 3)
        ])
    }
}

// MARK: - Outcome
extension MockProgressDisplayTests {
    @Test
    func `A successful operation's value is returned`() async throws {
        let sut = makeSUT()
        let value = 42

        let result = try await sut.track("Build") { _ in value }

        #expect(result == value)
    }

    @Test
    func `A successful operation is recorded as succeeded`() async throws {
        let sut = makeSUT()

        try await sut.track("Build") { _ in }

        let activity = try #require(sut.activities.first)
        #expect(activity.outcome == .succeeded)
    }

    @Test
    func `A failing operation's error is rethrown unchanged`() async {
        let sut = makeSUT()
        let error = SampleError(message: "build failed")

        await #expect(throws: error) {
            try await sut.track("Build") { (_: ActivityHandle) throws -> Int in throw error }
        }
    }

    @Test
    func `A failing operation is recorded as failed`() async throws {
        let sut = makeSUT()

        _ = try? await sut.track("Build") { (_: ActivityHandle) throws -> Int in throw SampleError(message: "build failed") }

        let activity = try #require(sut.activities.first)
        #expect(activity.outcome == .failed)
    }
}

// MARK: - Separate Activities
extension MockProgressDisplayTests {
    @Test
    func `Updates from concurrent activities stay on their own activities`() async throws {
        let sut = makeSUT()

        async let fetch: Void = sut.track("Fetch") { handle in
            handle.update(detail: "downloading")
            handle.progress(completed: 1, total: 2)
        }
        async let build: Void = sut.track("Build") { handle in
            handle.output(line: "Compiling main.swift")
            handle.markWaiting()
        }
        _ = try await (fetch, build)

        let updatesByTitle = Dictionary(uniqueKeysWithValues: sut.activities.map { ($0.title, $0.updates) })
        #expect(updatesByTitle == [
            "Fetch": [.detail("downloading"), .progress(completed: 1, total: 2)],
            "Build": [.output("Compiling main.swift"), .waiting]
        ])
    }

    @Test
    func `Activities with the same title are recorded separately`() async throws {
        let sut = makeSUT()
        let title = "Build"

        try await sut.track(title) { handle in handle.update(detail: "first") }
        _ = try? await sut.track(title) { (handle: ActivityHandle) throws -> Int in
            handle.update(detail: "second")
            throw SampleError(message: "build failed")
        }

        #expect(sut.activities == [
            RecordedActivity(title: title, updates: [.detail("first")], outcome: .succeeded),
            RecordedActivity(title: title, updates: [.detail("second")], outcome: .failed)
        ])
    }
}

// MARK: - Notes and Output
extension MockProgressDisplayTests {
    @Test
    func `Notes are recorded in order with their style`() {
        let sut = makeSUT()

        sut.note("Using cached build", style: .info)
        sut.note("Skipping tests", style: .warning)

        #expect(sut.notes == [
            RecordedNote(text: "Using cached build", style: .info),
            RecordedNote(text: "Skipping tests", style: .warning)
        ])
    }

    @Test
    func `Written output is recorded in order`() {
        let sut = makeSUT()

        sut.writeOutput("first")
        sut.writeOutput("second")

        #expect(sut.writtenOutput == ["first", "second"])
    }
}

// MARK: - Suspension
extension MockProgressDisplayTests {
    @Test
    func `A suspended body's value is returned`() {
        let sut = makeSUT()
        let answer = "yes"

        let result = sut.suspended { answer }

        #expect(result == answer)
    }

    @Test
    func `Each suspension that runs its body is counted`() {
        let sut = makeSUT()

        sut.suspended { }
        sut.suspended { }

        #expect(sut.suspensionCount == 2)
    }

    @Test
    func `A suspended body's error is rethrown unchanged`() {
        let sut = makeSUT()
        let error = SampleError(message: "prompt cancelled")

        #expect(throws: error) {
            try sut.suspended { () throws -> String in throw error }
        }
    }
}

// MARK: - Restoring the Terminal
extension MockProgressDisplayTests {
    @Test
    func `Restoring the terminal is recorded`() {
        let sut = makeSUT()

        sut.restoreTerminal()

        #expect(sut.terminalWasRestored)
    }

    @Test
    func `Activities tracked after restoring the terminal are still recorded`() async throws {
        let sut = makeSUT()
        let title = "Cleanup"

        sut.restoreTerminal()
        try await sut.track(title) { _ in }

        #expect(sut.trackedTitles == [title])
    }
}

// MARK: - SUT
private extension MockProgressDisplayTests {
    func makeSUT() -> MockProgressDisplay {
        return MockProgressDisplay()
    }
}

// MARK: - Dependencies
private extension MockProgressDisplayTests {
    struct SampleError: Error, Equatable {
        let message: String
    }
}
