//
//  TextStyler.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// A type that applies a ``TextStyle`` to text.
///
/// Styles don't nest. Every styled span ends with a full reset, so text after an inner span loses
/// the outer style, and the inner span picks up any outer bold. Style adjacent pieces separately
/// and join the results. Nesting isn't detected at runtime.
public protocol TextStyler: Sendable {
    /// Applies `style` to `text`.
    ///
    /// - Parameters:
    ///   - text: The text to style.
    ///   - style: How the text should look.
    /// - Returns: The text in `style`, ready to write to the stream the styler was chosen for.
    func styled(_ text: String, as style: TextStyle) -> String
}
