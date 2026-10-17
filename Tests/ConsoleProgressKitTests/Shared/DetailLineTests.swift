//
//  DetailLineTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 10/17/26.
//

import Testing
@testable import ConsoleProgressKit

struct DetailLineTests {
    @Test
    func `A title without a detail is shown on its own`() {
        let sut = makeSUT()
        let title = "Build"

        #expect(sut.make(title: title, detail: nil) == title)
    }

    @Test
    func `A detail is shown after the title, separated by a dash`() {
        let sut = makeSUT()

        #expect(sut.make(title: "Build", detail: "compiling") == "Build — compiling")
    }
}

// MARK: - SUT
private extension DetailLineTests {
    func makeSUT() -> DetailLine.Type {
        return DetailLine.self
    }
}
