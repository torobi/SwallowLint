import SwiftSyntax

class ViolationsSyntaxVisitor: SyntaxVisitor {
    let ruleDescription: RuleDescription
    private let file: SwallowLintFile
    private lazy var locationConverter = file.locationConverter
    private(set) var violations: [StyleViolation] = []

    required init(ruleDescription: RuleDescription, file: SwallowLintFile) {
        self.ruleDescription = ruleDescription
        self.file = file
        super.init(viewMode: .all)
    }

    func addViolation(violation: StyleViolation) {
        violations.append(violation)
    }

    func addViolation(node: SyntaxProtocol, reason: String? = nil) {
        let sourceLocation = node.startLocation(converter: locationConverter)
        let location = Location(sourceLocation: sourceLocation)

        let violation = StyleViolation(
            ruleIdentifier: ruleDescription.identifier,
            ruleDescription: ruleDescription.description,
            ruleName: ruleDescription.name,
            severity: ruleDescription.severity,
            location: location,
            reason: reason ?? ruleDescription.reason ?? ruleDescription.description
        )

        violations.append(violation)
    }

    func walk() {
        super.walk(file.syntaxTree)
    }
}