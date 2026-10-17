//
//  LineFitterTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct LineFitterTests {
    @Test
    func `A line narrower than the terminal is left unchanged`() {
        let sut = makeSUT()
        let line = "Build"

        #expect(sut.fit(line, width: 20) == line)
    }

    @Test
    func `A line wider than the terminal is cut and ends with an ellipsis and a style reset`() {
        let sut = makeSUT()

        #expect(sut.fit("abcdefghij", width: 6) == "abcd…\u{1B}[0m")
    }

    @Test
    func `A terminal one column wide shows only the ellipsis`() {
        let sut = makeSUT()

        #expect(sut.fit("abcdef", width: 1) == "…\u{1B}[0m")
    }
}

// MARK: - Escape Sequences
extension LineFitterTests {
    @Test
    func `Escape sequences do not count toward the line's width`() {
        let sut = makeSUT()
        let line = "\u{1B}[2mabc\u{1B}[0m"

        #expect(sut.fit(line, width: 4) == line)
    }

    @Test
    func `Escape sequences are kept when a line is cut`() {
        let sut = makeSUT()

        #expect(sut.fit("\u{1B}[31mabcdefgh\u{1B}[0m", width: 5) == "\u{1B}[31mabc\u{1B}[0m…\u{1B}[0m")
    }
}

// MARK: - SUT
private extension LineFitterTests {
    func makeSUT() -> LineFitter.Type {
        return LineFitter.self
    }
}
