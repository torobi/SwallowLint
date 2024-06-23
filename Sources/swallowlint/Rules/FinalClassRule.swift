import SwiftSyntax

struct FinalClassRule: Rule {
    typealias Visitor = FinalClassRuleVisitor
    let description = RuleDescription(
        identifier: "final_class",
        name: "Final Class Rule",
        description: "Class need to be marked with the final modifier"
    )
}

final class FinalClassRuleVisitor: ViolationsSyntaxVisitor {
    override func visitPost(_ node: ClassDeclSyntax) {
        if !node.modifiers.contains(where: { $0.name.text == "final" }) {
            addViolation(node: node)
        }
    }
}