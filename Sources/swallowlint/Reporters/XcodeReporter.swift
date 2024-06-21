struct XcodeReporter: Reporter {
    static let description = "Reports violations in the format Xcode uses to display in the IDE. (default)"

    static func generateReport(_ violations: [StyleViolation]) -> String {
        violations.map(generateForSingleViolation).joined(separator: "\n")
    }

    static func generateForSingleViolation(_ violation: StyleViolation) -> String {
        return [
            "\(violation.location): ",
            "\(violation.severity.rawValue): ",
            "\(violation.ruleName) Violation: ",
            violation.reason,
            " (\(violation.ruleIdentifier))"
        ].joined()
    }
}