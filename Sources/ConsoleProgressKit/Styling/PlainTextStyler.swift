/// Returns text unchanged, for output that shouldn't contain escape codes.
public struct PlainTextStyler: TextStyler {
    public init() {}

    public func styled(_ text: String, as style: TextStyle) -> String {
        return text
    }
}
