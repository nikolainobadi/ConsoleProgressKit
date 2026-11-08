//
//  TaggingTextStylerTests.swift
//  ConsoleProgressTestingTests
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Testing
@testable import ConsoleProgressTesting

struct TaggingTextStylerTests {
    @Test
    func `Text is wrapped in tags named after its style`() {
        let sut = makeSUT()

        #expect(sut.styled("Build", as: .title) == "<title>Build</title>")
    }

    @Test
    func `A custom style is tagged with its own name`() {
        let sut = makeSUT()
        let style = TextStyle(name: "ticketID", color: .yellow, isBold: false, isDim: false, isUnderlined: false)

        #expect(sut.styled("PROJ-42", as: style) == "<ticketID>PROJ-42</ticketID>")
    }

    @Test
    func `A status line tags its text and leaves the emoji outside`() {
        let sut = makeSUT()

        #expect(sut.successLine("Done") == "✅ <success>Done</success>")
    }
}

// MARK: - SUT
private extension TaggingTextStylerTests {
    func makeSUT() -> TaggingTextStyler {
        return TaggingTextStyler()
    }
}
