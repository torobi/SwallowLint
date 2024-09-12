import Foundation

typealias RuleIdentifier = String
/// A SwallowLint-interpretable command to modify SwallowLint's behavior embedded as comments in source code.
struct Command: Equatable {

    /// The action (verb) that SwallowLint should perform when interpreting this command.
    enum Action: String {
        /// The rule(s) associated with this command should be enabled by the SwallowLint engine.
        // case enable
        /// The rule(s) associated with this command should be disabled by the SwallowLint engine.
        case disable
        /// The action string was invalid.
        case invalid
    }

    /// The modifier for a command, used to modify its scope.
    enum Modifier: String {
        /// The command should only apply to the line preceding its definition.
        case previous
        /// The command should only apply to the same line as its definition.
        case this
        /// The command should only apply to the file as its definition.
        case thisFile
        /// The command should only apply to the line following its definition.
        case next
        /// The modifier string was invalid.
        case invalid
    }

    /// Text after this delimiter is not considered part of the rule.
    /// The purpose of this delimiter is to allow SwallowLint
    /// commands to be documented in source code.
    ///
    ///     swallowlint:disable:next force_try - Explanation here
    private static let commentDelimiter = " - "

    var isValid: Bool {
        action != .invalid && modifier != .invalid && !ruleIdentifiers.isEmpty
    }

    /// The action (verb) that SwallowLint should perform when interpreting this command.
    let action: Action
    /// The identifiers for the rules associated with this command.
    let ruleIdentifiers: Set<RuleIdentifier>
    /// The line in the source file where this command is defined.
    let line: Int
    /// The character offset within the line in the source file where this command is defined.
    let character: Int?
    /// This command's modifier, if any.
    let modifier: Modifier?
    /// The comment following this command's `-` delimiter, if any.
    internal let trailingComment: String?

    /// Creates a command based on the specified parameters.
    ///
    /// - parameter action:          This command's action.
    /// - parameter ruleIdentifiers: The identifiers for the rules associated with this command.
    /// - parameter line:            The line in the source file where this command is defined.
    /// - parameter character:       The character offset within the line in the source file where this command is
    ///                              defined.
    /// - parameter modifier:        This command's modifier, if any.
    /// - parameter trailingComment: The comment following this command's `-` delimiter, if any.
    init(action: Action, ruleIdentifiers: Set<RuleIdentifier> = [], line: Int = 0,
                character: Int? = nil, modifier: Modifier? = nil, trailingComment: String? = nil) {
        self.action = action
        self.ruleIdentifiers = ruleIdentifiers
        self.line = line
        self.character = character
        self.modifier = modifier
        self.trailingComment = trailingComment
    }

    /// Creates a command based on the specified parameters.
    ///
    /// - parameter actionString: The string in the command's definition describing its action.
    /// - parameter line:         The line in the source file where this command is defined.
    /// - parameter character:    The character offset within the line in the source file where this command is
    ///                           defined.
    init(actionString: String, line: Int, character: Int) {
        let scanner = Scanner(string: actionString)
        _ = scanner.scanString("swallowlint:")
        // (enable|disable)(:previous|:this|:next)
        guard let actionAndModifierString = scanner.scanUpToString(" ") else {
            self.init(action: .invalid, line: line, character: character)
            return
        }
        let actionAndModifierScanner = Scanner(string: actionAndModifierString)
        guard let actionString = actionAndModifierScanner.scanUpToString(":"),
              let action = Action(rawValue: actionString)
        else {
            self.init(action: .invalid, line: line, character: character)
            return
        }

        let rawRuleTexts = scanner.scanUpToString(Self.commentDelimiter) ?? ""
        var trailingComment: String?
        if scanner.isAtEnd {
            trailingComment = nil
        } else {
            // Store any text after the comment delimiter as the trailingComment.
            // The addition to currentIndex is to move past the delimiter
            trailingComment = String(
              scanner
                .string[scanner.currentIndex...]
                .dropFirst(Self.commentDelimiter.count)
            )
        }
        let ruleTexts = rawRuleTexts.components(separatedBy: .whitespacesAndNewlines).filter {
            let component = $0.trimmingCharacters(in: .whitespaces)
            return !component.isEmpty && component != "*/"
        }

        let ruleIdentifiers = Set(ruleTexts.map(RuleIdentifier.init(_:)))

        // Modifier
        let hasModifier = actionAndModifierScanner.scanString(":") != nil
        let modifier: Modifier?
        if hasModifier {
            let modifierString = String(actionAndModifierScanner.string[actionAndModifierScanner.currentIndex...])
            modifier = Modifier(rawValue: modifierString) ?? .invalid
        } else {
            modifier = nil
        }

        self.init(
            action: action,
            ruleIdentifiers: ruleIdentifiers,
            line: line,
            character: character,
            modifier: modifier,
            trailingComment: trailingComment
        )
    }
}
