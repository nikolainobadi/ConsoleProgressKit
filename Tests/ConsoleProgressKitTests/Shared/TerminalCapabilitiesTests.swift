//
//  TerminalCapabilitiesTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Testing
@testable import ConsoleProgressKit

struct TerminalCapabilitiesTests {
    @Test
    func `Color is off when the stream is not a terminal`() {
        let sut = makeSUT()

        #expect(!sut.supportsColor(isTerminal: false, environment: makeEnvironment(noColor: nil, term: "xterm-256color")))
    }

    @Test(arguments: [nil, ""] as [String?])
    func `Color stays on when NO_COLOR is unset or empty`(noColor: String?) {
        let sut = makeSUT()

        #expect(sut.supportsColor(isTerminal: true, environment: makeEnvironment(noColor: noColor, term: "xterm-256color")))
    }

    @Test(arguments: ["1", "0", "true"])
    func `Color is off when NO_COLOR has any value`(noColor: String) {
        let sut = makeSUT()

        #expect(!sut.supportsColor(isTerminal: true, environment: makeEnvironment(noColor: noColor, term: "xterm-256color")))
    }

    @Test(arguments: [nil, "xterm-256color"] as [String?])
    func `Color stays on when TERM is unset or a capable terminal`(term: String?) {
        let sut = makeSUT()

        #expect(sut.supportsColor(isTerminal: true, environment: makeEnvironment(noColor: nil, term: term)))
    }

    @Test
    func `Color is off on a dumb terminal`() {
        let sut = makeSUT()

        #expect(!sut.supportsColor(isTerminal: true, environment: makeEnvironment(noColor: nil, term: "dumb")))
    }
}

// MARK: - Choosing a Styler
extension TerminalCapabilitiesTests {
    @Test
    func `Styled escape codes are used when color is supported`() {
        let sut = makeSUT()

        #expect(sut.textStyler(supportsColor: true) is AnsiTextStyler)
    }

    @Test
    func `Text is left plain when color is not supported`() {
        let sut = makeSUT()

        #expect(sut.textStyler(supportsColor: false) is PlainTextStyler)
    }
}

// MARK: - Reading the Size
extension TerminalCapabilitiesTests {
    @Test(arguments: [(0, 24), (80, 0)])
    func `Size is unavailable when the terminal reports zero columns or rows`(columns: Int, rows: Int) {
        let sut = makeSUT()

        #expect(sut.size(columns: columns, rows: rows) == nil)
    }

    @Test
    func `Size reports the terminal's columns as width and rows as height`() throws {
        let sut = makeSUT()

        let size = try #require(sut.size(columns: 80, rows: 24))

        #expect(size.width == 80)
        #expect(size.height == 24)
    }
}

// MARK: - SUT
private extension TerminalCapabilitiesTests {
    func makeSUT() -> TerminalCapabilities.Type {
        return TerminalCapabilities.self
    }
}

// MARK: - Helpers
private extension TerminalCapabilitiesTests {
    func makeEnvironment(noColor: String?, term: String?) -> [String: String] {
        var environment: [String: String] = [:]
        environment["NO_COLOR"] = noColor
        environment["TERM"] = term

        return environment
    }
}
