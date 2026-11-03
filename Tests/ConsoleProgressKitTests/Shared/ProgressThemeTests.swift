//
//  ProgressThemeTests.swift
//  ConsoleProgressKitTests
//
//  Created by Nikolai Nobadi on 11/3/26.
//

import Testing
@testable import ConsoleProgressKit

struct ProgressThemeTests {
    @Test
    func `The standard theme leaves the spinner uncolored`() {
        #expect(makeSUT().spinner == nil)
    }

    @Test
    func `The standard theme leaves the progress bar uncolored`() {
        #expect(makeSUT().progressBar == nil)
    }

    @Test
    func `The standard theme shows success in green`() {
        #expect(makeSUT().success == .green)
    }

    @Test
    func `The standard theme shows failure in red`() {
        #expect(makeSUT().failure == .red)
    }

    @Test
    func `The standard theme shows warnings in yellow`() {
        #expect(makeSUT().warning == .yellow)
    }
}

// MARK: - SUT
private extension ProgressThemeTests {
    func makeSUT() -> ProgressTheme {
        return .standard
    }
}
