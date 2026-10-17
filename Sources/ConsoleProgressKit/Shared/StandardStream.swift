//
//  StandardStream.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

import Foundation

struct StandardStream: Sendable {
    private let handle: FileHandle

    static let output = StandardStream(handle: .standardOutput)
    static let error = StandardStream(handle: .standardError)

    func write(_ text: String) {
        handle.write(Data(text.utf8))
    }
}
