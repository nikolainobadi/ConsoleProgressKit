//
//  TerminalScreenTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct TerminalScreenTests {
    @Test
    func `A screen with nothing drawn draws the region without erasing first`() {
        let sut = makeSUT(renderedLineCount: 0, cursorIsHidden: true)

        #expect(sut.makeRedraw(above: nil, region: ["⠋ Build", "⠋ Test"], cursorIsHidden: true) == "⠋ Build\n⠋ Test")
    }

    @Test
    func `A single drawn line is erased without moving the cursor up`() {
        let sut = makeSUT(renderedLineCount: 1, cursorIsHidden: true)

        #expect(sut.makeRedraw(above: nil, region: ["⠙ Build"], cursorIsHidden: true) == "\r\u{1B}[J⠙ Build")
    }

    @Test
    func `Several drawn lines are erased by moving the cursor up to the first of them`() {
        let sut = makeSUT(renderedLineCount: 3, cursorIsHidden: true)

        #expect(sut.makeRedraw(above: nil, region: ["⠙ Build"], cursorIsHidden: true) == "\r\u{1B}[2A\u{1B}[J⠙ Build")
    }

    @Test
    func `A line printed above the region is written after erasing and before redrawing`() {
        let sut = makeSUT(renderedLineCount: 1, cursorIsHidden: true)

        #expect(sut.makeRedraw(above: "✓ Lint (0.4s)", region: ["⠙ Build"], cursorIsHidden: true) == "\r\u{1B}[J✓ Lint (0.4s)\n⠙ Build")
    }
}

// MARK: - Cursor
extension TerminalScreenTests {
    @Test
    func `The cursor is hidden when a region starts being drawn`() {
        let sut = makeSUT(renderedLineCount: 0, cursorIsHidden: false)

        #expect(sut.makeRedraw(above: nil, region: ["⠋ Build"], cursorIsHidden: true) == "\u{1B}[?25l⠋ Build")
    }

    @Test
    func `The cursor is shown again when the region is erased for good`() {
        let sut = makeSUT(renderedLineCount: 2, cursorIsHidden: true)

        #expect(sut.makeRedraw(above: nil, region: [], cursorIsHidden: false) == "\r\u{1B}[1A\u{1B}[J\u{1B}[?25h")
    }
}

// MARK: - SUT
private extension TerminalScreenTests {
    func makeSUT(renderedLineCount: Int, cursorIsHidden: Bool) -> TerminalScreen {
        return TerminalScreen(renderedLineCount: renderedLineCount, cursorIsHidden: cursorIsHidden)
    }
}
