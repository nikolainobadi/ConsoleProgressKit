//
//  NoteStyle.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

/// How a note is marked when it prints.
public enum NoteStyle: Sendable {
    /// Printed as plain text.
    case info

    /// Prefixed with `!`, in yellow when colors are enabled.
    case warning
}
