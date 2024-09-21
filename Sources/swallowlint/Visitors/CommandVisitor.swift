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
                lines[ruleIdentifier, default: []].append(command.line + 1)
            }
        }

        return lines
    }

    let locationConverter: SourceLocationConverter

    private lazy var commandLinesDict = {
        self.getCommandLinesDict()
    }()
    private lazy var disableRangesDict = {
        self.getDisableRangesDict()
    }()
    
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

    func isValidViolation(violation: StyleViolation) -> Bool {
        guard let line = violation.location.line else { return true }

        let disableRanges = disableRangesDict[violation.ruleIdentifier, default: []]
        let disableLines = commandLinesDict.disable[violation.ruleIdentifier, default: []]
        let enableLines = commandLinesDict.enable[violation.ruleIdentifier, default: []]

        if disableLines.contains(line) { return false }
        for range in disableRanges {
            if range.contains(line) && !enableLines.contains(line) { return false }
        }
        return true
    }
}

// MARK: - Command Line {
private extension CommandVisitor {
    final class CommandLine {
        let line: Int

        var action: Command.Action {
            if enableCount == disableCount { return .invalid }
            if enableCount > disableCount { return .enable }
            return .disable
        }
        
        private var enableCount: Int = 0
        private var disableCount: Int = 0
        
        init(line: Int) {
            self.line = line
        }
        
        func increment(action: Command.Action) {
            switch action {
            case .enable:
                enableCount += 1
            case .disable:
                disableCount += 1
            case .invalid:
                break
            }
        }
    }
    
    func getCommandLinesDict() -> (disable: [RuleIdentifier: Set<Int>], enable: [RuleIdentifier: Set<Int>]) {
        var commandLinesDict: [RuleIdentifier: [Int: CommandLine]] = [:]

        for command in commands {
            if command.action == .invalid { break }
            let line: Int
            switch command.modifier {
            case .previous:
                line = command.line - 1
            case .this:
                line = command.line
            case .next:
                line = command.line + 1
            case .invalid, .none:
                continue
            }
            command.ruleIdentifiers.forEach {
                var commandLines = commandLinesDict[$0, default: [:]]
                let commandLine = commandLines[line, default: .init(line: line)]
                commandLine.increment(action: command.action)
                commandLines[line] = commandLine
                commandLinesDict[$0] = commandLines
            }
        }

        var enableLinesDict: [RuleIdentifier: Set<Int>] = [:]
        var disableLinesDict: [RuleIdentifier: Set<Int>] = [:]
        commandLinesDict.forEach { (ruleIdentifier, commandLines) in
            let commandLines = commandLines.map { $0.value }
            var enableLines: Set<Int> = []
            var disableLines: Set<Int> = []
            commandLines.forEach {
                switch $0.action {
                case .enable:
                    enableLines.insert($0.line)
                case .disable:
                    disableLines.insert($0.line)
                case .invalid:
                    break
                }
            }
            enableLinesDict[ruleIdentifier] = enableLines
            disableLinesDict[ruleIdentifier] = disableLines
        }
        return (disableLinesDict, enableLinesDict)
    }
}

// MARK: - Command Disable Range
private extension CommandVisitor {
    func getDisableRangesDict() -> [RuleIdentifier: [any RangeExpression<Int>]] {
        struct CommandRangeEdge {
            let line: Int
            let action: Command.Action
        }

        var rangeEdges: [RuleIdentifier: [CommandRangeEdge]] = [:]
        
        for command in commands {
            switch command.modifier {
            case .none:
                if command.action == .invalid { break }
                command.ruleIdentifiers.forEach {
                    rangeEdges[$0, default: []].append(.init(line: command.line, action: command.action))
                }
            case .previous, .this, .next, .invalid:
                continue
            }
        }

        var disableRangesDict: [RuleIdentifier: [any RangeExpression<Int>]] = [:]
        for (ruleIdentifier, edges) in rangeEdges {
            var invalidRanges: [any RangeExpression<Int>] = []
            for edge in edges {
                switch edge.action {
                case .disable:
                    if invalidRanges.isEmpty || invalidRanges.last is CountableRange<Int> {
                        invalidRanges.append(edge.line...)
                    }
                case .enable:
                    if let last = invalidRanges.last as? CountablePartialRangeFrom<Int> {
                        invalidRanges[invalidRanges.count - 1] = last.lowerBound..<edge.line
                    }
                case .invalid:
                    break
                }
            }
            disableRangesDict[ruleIdentifier] = invalidRanges
        }

        return disableRangesDict
    }
}

// MARK: - Trivia
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
