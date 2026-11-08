//
//  TextStyler+StatusLines.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 11/8/26.
//

/// Each line keeps its emoji outside the styled text, so it reads the same without color.
public extension TextStyler {
    /// Returns `✅` and `text` in the ``TextStyle/success`` style.
    func successLine(_ text: String) -> String {
        return "✅ " + styled(text, as: .success)
    }

    /// Returns `⚠️` and `text` in the ``TextStyle/warning`` style.
    func warningLine(_ text: String) -> String {
        return "⚠️ " + styled(text, as: .warning)
    }

    /// Returns `❌` and `text` in the ``TextStyle/failure`` style.
    func failureLine(_ text: String) -> String {
        return "❌ " + styled(text, as: .failure)
    }
}
