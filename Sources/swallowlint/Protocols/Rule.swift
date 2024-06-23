protocol Rule {
    associatedtype Visitor: ViolationsSyntaxVisitor
    var description: RuleDescription { get }

    func makeVisitor(file: SwallowLintFile) -> Visitor
}

extension Rule {
    func makeVisitor(file: SwallowLintFile) -> Visitor {
        Visitor.init(ruleDescription: description, file: file)
    }
}