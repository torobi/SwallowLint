//
//  CommandVisitorTestHelper.swift
//  swallowlint
//
//  Created by torobi on 2024/09/20.
//

@testable import swallowlint

struct CommandVisitorTestHelper {
    struct Violation {
        static func make(_ identifier: String, line: Int) -> StyleViolation {
            .init(ruleIdentifier: identifier,
                  ruleDescription: "",
                  ruleName: "",
                  severity: .warning,
                  location: .init(file: "", line: line),
                  reason: "")
        }
    }
}
