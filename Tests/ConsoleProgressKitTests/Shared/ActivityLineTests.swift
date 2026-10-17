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

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .milliseconds(1500), colorsAreEnabled: false) == "✓ Build (1.5s)")
    }

    @Test
    func `A failed activity is marked with a cross and its elapsed seconds`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: false, elapsed: .milliseconds(1500), colorsAreEnabled: false) == "✗ Build (1.5s)")
    }

    @Test
    func `Elapsed time is shown to one decimal place`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .seconds(42), colorsAreEnabled: false) == "✓ Build (42.0s)")
    }
}

// MARK: - Colors
extension ActivityLineTests {
    @Test
    func `A succeeded activity's check is green when colors are enabled`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: true, elapsed: .milliseconds(1500), colorsAreEnabled: true) == "\u{1B}[32m✓\u{1B}[0m Build (1.5s)")
    }

    @Test
    func `A failed activity's cross is red when colors are enabled`() {
        let sut = makeSUT()

        #expect(sut.finished(title: "Build", succeeded: false, elapsed: .milliseconds(1500), colorsAreEnabled: true) == "\u{1B}[31m✗\u{1B}[0m Build (1.5s)")
    }
}

// MARK: - SUT
private extension ActivityLineTests {
    func makeSUT() -> ActivityLine.Type {
        return ActivityLine.self
    }
}
