//
//  TerminalColorTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/3/26.
//

import Testing
@testable import ConsoleProgressKit

struct TerminalColorTests {
    @Test(arguments: [
        (TerminalColor.black, 30),
        (.red, 31),
        (.green, 32),
        (.yellow, 33),
        (.blue, 34),
        (.magenta, 35),
        (.cyan, 36),
        (.white, 37)
    ])
    func `A standard color uses its ANSI foreground code`(color: TerminalColor, code: Int) {
        #expect(color.sgrCode == code)
    }

    @Test(arguments: [
        (TerminalColor.brightBlack, 90),
        (.brightRed, 91),
        (.brightGreen, 92),
        (.brightYellow, 93),
        (.brightBlue, 94),
        (.brightMagenta, 95),
        (.brightCyan, 96),
        (.brightWhite, 97)
    ])
    func `A bright color uses its ANSI bright foreground code`(color: TerminalColor, code: Int) {
        #expect(color.sgrCode == code)
    }
}
