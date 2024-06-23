import SwiftSyntax

// MARK: - CommandVisitor
/// Visits the source syntax tree to collect all SwallowLint-style comment commands.
final class CommandVisitor: SyntaxVisitor {
    private(set) var commands: [Command] = []
    var nextDisableRulesLines: [RuleIdentifier: [Int]] {
        let nextCommands = commands.filter { $0.modifier == .next && $0.isValid }
        var lines: [RuleIdentifier: [Int]] = [:]
        nextCommands.forEach { command in
            command.ruleIdentifiers.forEach{ ruleIdentifier in
                lines[ruleIdentifier]?.append(command.line)
            }
        }

        return lines
    }
    var thisCommands: [Command] {
        commands.filter { $0.modifier == .this && $0.isValid }
    }

    let locationConverter: SourceLocationConverter

    init(locationConverter: SourceLocationConverter) {
        self.locationConverter = locationConverter
        super.init(viewMode: .sourceAccurate)
    }

    override func visitPost(_ node: TokenSyntax) {
        let leadingCommands = node.leadingTrivia.commands(offset: node.position,
                                                          locationConverter: locationConverter)
        let trailingCommands = node.trailingTrivia.commands(offset: node.endPositionBeforeTrailingTrivia,
                                                            locationConverter: locationConverter)
        self.commands.append(contentsOf: leadingCommands + trailingCommands)
    }
}

// MARK: - Private Method
private extension Trivia {
    func commands(offset: AbsolutePosition, locationConverter: SourceLocationConverter) -> [Command] {
        var triviaOffset = SourceLength.zero
        var results: [Command] = []
        for trivia in self {
            triviaOffset += trivia.sourceLength
            switch trivia {
            case .lineComment(let comment):
                guard let lower = comment.range(of: "swallowlint:")?.lowerBound else {
                    break
                }

                let actionString = String(comment[lower...])
                let end = locationConverter.location(for: offset + triviaOffset)
                let command = Command(actionString: actionString, line: end.line, character: end.column)
                results.append(command)
            default:
                break
            }
        }

        return results
    }
}