//
//  PlainTextStyler.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// Returns text unchanged, for output that shouldn't contain escape codes.
public struct PlainTextStyler: TextStyler {
    public init() {}

    public func styled(_ text: String, as style: TextStyle) -> String {
        return text
    }
}
