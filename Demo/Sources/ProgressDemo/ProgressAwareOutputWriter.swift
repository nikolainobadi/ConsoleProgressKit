//
//  ProgressAwareOutputWriter.swift
//  ProgressDemo
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import ConsoleProgressKit
import NnArgumentParser

/// Sends `NnOutput` writes through the display, so results on stdout don't break up running activities.
struct ProgressAwareOutputWriter: NnOutputWriter {
    let display: any ProgressDisplay

    func write(_ text: String) {
        display.writeOutput(text)
    }
}
