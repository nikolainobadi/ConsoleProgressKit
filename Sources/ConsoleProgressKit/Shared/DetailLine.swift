//
//  DetailLine.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum DetailLine {
    static func make(title: String, detail: String?) -> String {
        guard let detail else {
            return title
        }

        return title + separator + detail
    }
}

// MARK: - Private Constants
private extension DetailLine {
    static let separator = " — "
}
