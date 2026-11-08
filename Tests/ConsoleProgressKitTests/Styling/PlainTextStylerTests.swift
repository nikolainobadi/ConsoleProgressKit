//
//  PlainTextStylerTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Testing
@testable import ConsoleProgressKit

struct PlainTextStylerTests {
    @Test(arguments: [
        TextStyle.title,
        TextStyle.heading,
        TextStyle.added,
        TextStyle.deleted,
        TextStyle.muted,
        TextStyle.standout,
        TextStyle.success,
        TextStyle.warning,
        TextStyle.failure,
        TextStyle.command,
        TextStyle.url
    ])
    func `Every standard style leaves text unchanged`(style: TextStyle) {
        let sut = makeSUT()
        let text = "Build"

        #expect(sut.styled(text, as: style) == text)
    }
}

// MARK: - SUT
private extension PlainTextStylerTests {
    func makeSUT() -> PlainTextStyler {
        return PlainTextStyler()
    }
}
