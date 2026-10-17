//
//  NoteLineTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct NoteLineTests {
    @Test(arguments: [true, false])
    func `An info note is printed as plain text whether or not colors are enabled`(colorsAreEnabled: Bool) {
        let sut = makeSUT()
        let text = "Using cached results"

        #expect(sut.make(text: text, style: .info, colorsAreEnabled: colorsAreEnabled) == text)
    }

    @Test
    func `A warning note is prefixed with an exclamation mark when colors are disabled`() {
        let sut = makeSUT()

        #expect(sut.make(text: "Disk almost full", style: .warning, colorsAreEnabled: false) == "! Disk almost full")
    }

    @Test
    func `A warning note's exclamation mark is yellow when colors are enabled`() {
        let sut = makeSUT()

        #expect(sut.make(text: "Disk almost full", style: .warning, colorsAreEnabled: true) == "\u{1B}[33m!\u{1B}[0m Disk almost full")
    }
}

// MARK: - SUT
private extension NoteLineTests {
    func makeSUT() -> NoteLine.Type {
        return NoteLine.self
    }
}
