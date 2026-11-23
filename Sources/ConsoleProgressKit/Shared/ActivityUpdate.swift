package enum ActivityUpdate: Sendable {
    case detail(String?)
    case waiting(Bool)
    case output(String)
    case progress(completed: Int, total: Int)
}
