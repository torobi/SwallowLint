struct RuleDescription {
    let identifier: String
    let name: String
    let description: String
    let severity: ViolationSeverity = .warning
    let reason: String? = nil
}