struct StyleViolation: CustomStringConvertible, Codable, Hashable {
    /// The identifier of the rule that generated this violation.
    let ruleIdentifier: String

    /// The description of the rule that generated this violation.
    let ruleDescription: String

    /// The name of the rule that generated this violation.
    let ruleName: String

    /// The severity of this violation.
    private(set) var severity: ViolationSeverity

    /// The location of this violation.
    private(set) var location: Location

    /// The justification for this violation.
    let reason: String

    /// A printable description for this violation.
    var description: String {
        return XcodeReporter.generateForSingleViolation(self)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}