//
//  RunningActivity.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

/// An activity the live display is showing, with everything it has reported so far.
struct RunningActivity {
    let id: UUID
    let title: String
    var detail: String?
    var isWaiting = false
    var outputLines: [String] = []
    var progress: StepProgress?

    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

// MARK: - Actions
extension RunningActivity {
    func applying(_ update: ActivityUpdate, keptOutputLineCount: Int) -> RunningActivity {
        var next = self

        switch update {
        case .detail(let detail):
            next.detail = detail
        case .waiting(let isWaiting):
            next.isWaiting = isWaiting
        case .output(let line):
            next.outputLines = Array((outputLines + [line]).suffix(keptOutputLineCount))
        case .progress(let completed, let total):
            next.progress = .init(completed: completed, total: total)
        }

        return next
    }
}

// MARK: - Dependencies
struct StepProgress {
    let completed: Int
    let total: Int
}
