//
//  NoteLineTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct NoteLineTests {
    @Test(arguments: [ProgressTheme.standard, nil])
    func `An info note is printed as plain text with or without a theme`(theme: ProgressTheme?) {
        let sut = makeSUT()
        let text = "Using cached results"

        #expect(sut.make(text: text, style: .info, theme: theme) == text)
    }

    @Test
    func `A warning note is prefixed with an uncolored exclamation mark without a theme`() {
        let sut = makeSUT()

        #expect(sut.make(text: "Disk almost full", style: .warning, theme: nil) == "! Disk almost full")
    }

    @Test
    func `A warning note's exclamation mark is yellow with the standard theme`() {
        let sut = makeSUT()

        #expect(sut.make(text: "Disk almost full", style: .warning, theme: .standard) == "\u{1B}[33m!\u{1B}[0m Disk almost full")
    }

    @Test
    func `A warning note's exclamation mark uses the theme's warning color`() {
        let sut = makeSUT()
        let theme = ProgressTheme(spinner: nil, progressBar: nil, success: .brightCyan, failure: .magenta, warning: .blue)

        #expect(sut.make(text: "Disk almost full", style: .warning, theme: theme) == "\u{1B}[34m!\u{1B}[0m Disk almost full")
    }
}

// MARK: - SUT
private extension NoteLineTests {
    func makeSUT() -> NoteLine.Type {
        return NoteLine.self
    }
}
