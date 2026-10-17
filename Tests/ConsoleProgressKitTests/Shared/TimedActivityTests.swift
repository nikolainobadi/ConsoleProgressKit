//
//  TimedActivityTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct TimedActivityTests {
    @Test
    func `A successful operation's value is returned`() async throws {
        let (sut, clock) = makeSUT()
        let value = 42

        let result = try await sut.run(clock: clock, operation: { value }, finish: { _, _ in })

        #expect(result == value)
    }

    @Test
    func `A successful operation is reported as succeeded`() async throws {
        let (sut, clock) = makeSUT()
        var reportedSuccess: Bool?

        _ = try await sut.run(clock: clock, operation: { 42 }, finish: { succeeded, _ in reportedSuccess = succeeded })

        let succeeded = try #require(reportedSuccess as Bool?)
        #expect(succeeded)
    }
}

// MARK: - Failure
extension TimedActivityTests {
    @Test
    func `A failing operation's error is rethrown unchanged`() async {
        let (sut, clock) = makeSUT()

        await #expect(throws: SampleError.self) {
            try await sut.run(clock: clock, operation: { () throws -> Int in throw SampleError() }, finish: { _, _ in })
        }
    }

    @Test
    func `A failing operation is reported as failed`() async throws {
        let (sut, clock) = makeSUT()
        var reportedSuccess: Bool?

        _ = try? await sut.run(clock: clock, operation: { () throws -> Int in throw SampleError() }, finish: { succeeded, _ in reportedSuccess = succeeded })

        let succeeded = try #require(reportedSuccess as Bool?)
        #expect(!succeeded)
    }
}

// MARK: - SUT
private extension TimedActivityTests {
    func makeSUT() -> (sut: TimedActivity.Type, clock: ContinuousClock) {
        return (TimedActivity.self, ContinuousClock())
    }
}

// MARK: - Dependencies
private extension TimedActivityTests {
    struct SampleError: Error { }
}
