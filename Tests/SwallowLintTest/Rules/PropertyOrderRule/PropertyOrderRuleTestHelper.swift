//
//  PropertyOrderRuleTestHelper.swift
//  swallowlint
//
//  Created by torobi on 2024/09/24.
//

@testable import swallowlint

struct PropertyOrderRuleTestHelper {
    struct TestableViolation {
        static func make(violationLine: Int,
                         below: PropertyOrderRuleVisitor.Modifier,
                         above: PropertyOrderRuleVisitor.Modifier,
                         aboveLine: Int) -> TestableViolation {
            .init(reason: "Properties declared with \"\(below)\" need to be defined above \"\(above)\"(line: \(aboveLine))",
                  line: violationLine)
        }
        static func make(_ violation: StyleViolation) -> TestableViolation {
            .init(reason: violation.reason, line: violation.location.line ?? 0)
        }
        let reason: String
        let line: Int
    }
}

extension PropertyOrderRuleTestHelper.TestableViolation: Equatable {}

extension PropertyOrderRuleTestHelper.TestableViolation: Comparable {
    static func < (lhs: PropertyOrderRuleTestHelper.TestableViolation, rhs: PropertyOrderRuleTestHelper.TestableViolation) -> Bool {
        lhs.line < rhs.line
    }
}
