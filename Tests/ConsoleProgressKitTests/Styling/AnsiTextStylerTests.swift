//
//  AnsiTextStylerTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Testing
@testable import ConsoleProgressKit

struct AnsiTextStylerTests {
    @Test(arguments: [
        (TextStyle.title, "1;36"),
        (TextStyle.heading, "1"),
        (TextStyle.added, "32"),
        (TextStyle.deleted, "31"),
        (TextStyle.muted, "2"),
        (TextStyle.standout, "1;35"),
        (TextStyle.success, "1;32"),
        (TextStyle.warning, "1;33"),
        (TextStyle.failure, "1;31"),
        (TextStyle.command, "1"),
        (TextStyle.url, "4")
    ])
    func `A standard style wraps text in its escape sequence and a reset`(style: TextStyle, codes: String) {
        let sut = makeSUT()

        #expect(sut.styled("Build", as: style) == "\u{1B}[\(codes)mBuild\u{1B}[0m")
    }

    @Test
    func `A custom style combines its attributes in a fixed order`() {
        let sut = makeSUT()
        let style = TextStyle(name: "custom", color: .brightBlue, isBold: true, isDim: true, isUnderlined: true)

        #expect(sut.styled("Build", as: style) == "\u{1B}[1;2;4;94mBuild\u{1B}[0m")
    }

    @Test
    func `A style with no attributes leaves text unchanged`() {
        let sut = makeSUT()
        let text = "Build"
        let style = TextStyle(name: "none", color: nil, isBold: false, isDim: false, isUnderlined: false)

        #expect(sut.styled(text, as: style) == text)
    }

    @Test
    func `Empty text stays empty in any style`() {
        let sut = makeSUT()

        #expect(sut.styled("", as: .title) == "")
    }
}

// MARK: - SUT
private extension AnsiTextStylerTests {
    func makeSUT() -> AnsiTextStyler {
        return AnsiTextStyler()
    }
}
