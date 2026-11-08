//
//  TerminalStyleTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/3/26.
//

import Testing
@testable import ConsoleProgressKit

struct TerminalStyleTests {
    @Test
    func `Text with no color is left unchanged`() {
        let sut = makeSUT()
        let text = "Build"

        #expect(sut.apply(nil, to: text) == text)
    }

    @Test
    func `Empty text stays empty even with a color`() {
        let sut = makeSUT()

        #expect(sut.apply(.cyan, to: "") == "")
    }

    @Test
    func `Text with a color is wrapped in that color and a style reset`() {
        let sut = makeSUT()

        #expect(sut.apply(.cyan, to: "Build") == "\u{1B}[36mBuild\u{1B}[0m")
    }
}

// MARK: - Escape Sequences
extension TerminalStyleTests {
    @Test
    func `The dim sequence turns on dimming`() {
        let sut = makeSUT()

        #expect(sut.dim == "\u{1B}[2m")
    }

    @Test
    func `Several codes are joined into one sequence`() {
        let sut = makeSUT()

        #expect(sut.sgr([1, 36]) == "\u{1B}[1;36m")
    }
}

// MARK: - SUT
private extension TerminalStyleTests {
    func makeSUT() -> TerminalStyle.Type {
        return TerminalStyle.self
    }
}
