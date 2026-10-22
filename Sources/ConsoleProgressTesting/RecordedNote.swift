//
//  RecordedNote.swift
//  ConsoleProgressTesting
//
//  Created by Nikolai Nobadi on 10/21/26.
//

/// One `note(_:style:)` call recorded by ``MockProgressDisplay``.
public struct RecordedNote: Sendable, Equatable {
    public let text: String
    public let style: NoteStyle

    public init(text: String, style: NoteStyle) {
        self.text = text
        self.style = style
    }
}
