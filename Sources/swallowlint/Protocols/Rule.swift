protocol Rule {
    associatedtype Visitor: ViolationsSyntaxVisitor
    var description: RuleDescription { get }

    func makeVisitor(file: SwallowLintFileProtocol) -> Visitor
}

extension Rule {
    func makeVisitor(file: SwallowLintFileProtocol) -> Visitor {
        Visitor.init(ruleDescription: description, file: file)
    }
}
