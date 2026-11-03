//
//  ActivityLineTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct ActivityLineTests {
    @Test
    func `A succeeded activity is marked with a check and its elapsed seconds`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .milliseconds(1500), theme: nil) == "✓ Build (1.5s)")
    }

    @Test
    func `A failed activity is marked with a cross and its elapsed seconds`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: false, elapsed: .milliseconds(1500), theme: nil) == "✗ Build (1.5s)")
    }

    @Test
    func `Elapsed time is shown to one decimal place`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .seconds(42), theme: nil) == "✓ Build (42.0s)")
    }
}

// MARK: - Colors
extension ActivityLineTests {
    @Test
    func `A succeeded activity's check is green with the standard theme`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .milliseconds(1500), theme: .standard) == "\u{1B}[32m✓\u{1B}[0m Build (1.5s)")
    }

    @Test
    func `A failed activity's cross is red with the standard theme`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: false, elapsed: .milliseconds(1500), theme: .standard) == "\u{1B}[31m✗\u{1B}[0m Build (1.5s)")
    }

    @Test
    func `A succeeded activity's check uses the theme's success color`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .milliseconds(1500), theme: makeCustomTheme()) == "\u{1B}[96m✓\u{1B}[0m Build (1.5s)")
    }

    @Test
    func `A failed activity's cross uses the theme's failure color`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: false, elapsed: .milliseconds(1500), theme: makeCustomTheme()) == "\u{1B}[35m✗\u{1B}[0m Build (1.5s)")
    }
}

// MARK: - SUT
private extension ActivityLineTests {
    func makeSUT() -> ActivityLine.Type {
        return ActivityLine.self
    }
}

// MARK: - Helpers
private extension ActivityLineTests {
    func makeCustomTheme() -> ProgressTheme {
        return .init(spinner: nil, progressBar: nil, success: .brightCyan, failure: .magenta, warning: .blue)
    }
}
