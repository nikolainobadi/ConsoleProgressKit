//
//  TextStylerStatusLinesTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/8/26.
//

import Testing
@testable import ConsoleProgressKit

struct TextStylerStatusLinesTests {
    @Test
    func `A success line keeps its emoji outside the styled text`() {
        let sut = makeSUT()

        #expect(sut.successLine("Done") == "✅ \u{1B}[1;32mDone\u{1B}[0m")
    }

    @Test
    func `A warning line keeps its emoji outside the styled text`() {
        let sut = makeSUT()

        #expect(sut.warningLine("Careful") == "⚠️ \u{1B}[1;33mCareful\u{1B}[0m")
    }

    @Test
    func `A failure line keeps its emoji outside the styled text`() {
        let sut = makeSUT()

        #expect(sut.failureLine("Failed") == "❌ \u{1B}[1;31mFailed\u{1B}[0m")
    }
}

// MARK: - SUT
private extension TextStylerStatusLinesTests {
    func makeSUT() -> AnsiTextStyler {
        return AnsiTextStyler()
    }
}
