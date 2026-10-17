//
//  ActivityUpdate.swift
//  ConsoleProgressKit
//
//  Created by Nikolai Nobadi on 10/16/26.
//

enum ActivityUpdate: Sendable {
    case detail(String?)
    case waiting(Bool)
    case output(String)
    case progress(completed: Int, total: Int)
}
