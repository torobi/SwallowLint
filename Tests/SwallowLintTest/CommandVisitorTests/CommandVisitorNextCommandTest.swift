//
//  CommandVisitorNextCommandTest.swift
//  swallowlint
//
//  Created by torobi on 2024/09/20.
//

@testable import swallowlint
import Nimble
import Quick

final class CommandVisitorNextCommandTest: QuickSpec {
    typealias Violation = CommandVisitorTestHelper.Violation
    override class func spec() {
        describe("CommandVisitor.disableNext") {
            context("disable:next only") {
                it("3 violations are disable") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable:next rule1 rule2
                    print("this is line2") // swallowlint:disable:next rule3
                    print("this is line3")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 3))) == true
                }
            }
        }

        describe("CommandVisitor.enableNext") {
            context("enable:next in disable context") {
                it("3 violations are disable") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable rule1 rule2 rule3
                    // swallowlint:enable:next rule1
                    print("this is line3") // swallowlint:enable:next rule1 rule2
                    print("this is line4")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 4))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 4))) == true
                }
            }
        }
    }
}
