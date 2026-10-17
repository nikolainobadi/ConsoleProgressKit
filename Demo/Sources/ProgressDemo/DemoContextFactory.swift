//
//  DemoContextFactory.swift
//  ProgressDemo
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import NnShellKit
import SwiftPickerKit
import NnArgumentParser

/// Vends the picker and shells the demo scenarios use.
struct DemoContextFactory {
    func makePicker() -> any CommandLinePicker {
        switch InteractionMode.current {
        case .interactive:
            return SwiftPicker(interruptBehavior: .waitForTermination)
        case .nonInteractive(let assumeYes):
            return NonInteractivePicker(assumeYes: assumeYes)
        }
    }

    func makeShell() -> any Shell {
        return NnShell()
    }

    func makeAsyncShell() -> any AsyncShell {
        return AsyncNnShell()
    }
}
