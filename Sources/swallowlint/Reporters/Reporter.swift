protocol Reporter: CustomStringConvertible {
    static func generateReport(_ violations: [StyleViolation]) -> String
}

extension Reporter {
    /// For CustomStringConvertible conformance.
    var description: String { self.description }
}