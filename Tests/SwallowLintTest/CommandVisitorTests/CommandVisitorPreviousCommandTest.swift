//
//  CommandVisitorPreviousCommandTest.swift
//  swallowlint
//
//  Created by torobi on 2024/09/21.
//

@testable import swallowlint
import Nimble
import Quick

final class CommandVisitorPreviousCommandTest: QuickSpec {
    typealias Violation = CommandVisitorTestHelper.Violation
    override class func spec() {
        describe("CommandVisitor.disablePrevious") {
            context("disable:previous only") {
                it("3 violations are disable") {
                    let file = MockSwallowLintFile(source: """
                    print("this is line1")
                    // swallowlint:disable:previous rule1 rule2
                    // swallowlint:disable:previous rule3
                    print("this is line4")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 1))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 4))) == true
                }
            }
        }

        describe("CommandVisitor.enablePrevious") {
            context("enable:next in disable context") {
                it("6 violations are disable") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable rule1 rule2 rule3
                    // swallowlint:enable:previous rule1
                    print("this is line3") // swallowlint:enable:previous rule1 rule2
                    print("this is line4")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 1))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 4))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 4))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 4))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule4", line: 4))) == true
                }
            }
        }
    }
}
