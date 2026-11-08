//
//  TaggingTextStyler.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// A ``TextStyler`` for tests that wraps text as `<name>text</name>`, using the style's `name`.
///
/// Compare a full tagged message to check that each piece got the right style and that no span
/// sits inside another.
public struct TaggingTextStyler: TextStyler {
    public init() {}

    public func styled(_ text: String, as style: TextStyle) -> String {
        return "<\(style.name)>\(text)</\(style.name)>"
    }
}
