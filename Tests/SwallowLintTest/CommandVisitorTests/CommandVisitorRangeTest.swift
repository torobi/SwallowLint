//
//  CommandVisitorRangeTest.swift
//  swallowlint
//
//  Created by torobi on 2024/09/21.
//

@testable import swallowlint
import Nimble
import Quick

final class CommandVisitorRangeTest: QuickSpec {
    typealias Violation = CommandVisitorTestHelper.Violation
    override class func spec() {
        describe("CommandVisitor.disable") {
            context("disable only") {
                it("rule1, rule2 violations are disable") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable rule1 rule2
                    print("this is line2")
                    print("this is line3")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                }
            }
            
            context("nest disable") {
                it("Same behavior as when not nested") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable rule1 rule2
                    // swallowlint:disable rule2
                    print("this is line2")
                    print("this is line3")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                }
            }
        }
        describe("CommandVisitor.enable") {
            context("enable only") {
                it("Same behavior as without command") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:enable rule1 rule2
                    print("this is line2")
                    print("this is line3")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                }
                context("Nest enable") {
                    it("Same behavior as without command") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable rule1 rule2
                        // swallowlint:enable rule2
                        print("this is line2")
                        print("this is line3")
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 1))) == true
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == true
                        expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == true
                        expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                    }
                }
            }
        }
        describe("CommandVisitor.disable/enable") {
            it("Ignored only in context of disable") {
                let file = MockSwallowLintFile(source: """
                // swallowlint:disable rule1 rule2
                print("disable rule1 rule2")
                // swallowlint:enable rule1 rule2
                print("enable rule1 rule2")
                // swallowlint:disable rule1
                print("disable rule1")
                """)
                let visitor = CommandVisitor(locationConverter: file.locationConverter)
                visitor.walk(file.syntaxTree)

                expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == false
                expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 2))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 3))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 4))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 4))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 4))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 5))) == false
                expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 5))) == true
                expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 6))) == false
                expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 6))) == true
            }
            context("Nest context") {
                it("Ignored only in context of disable") {
                    let file = MockSwallowLintFile(source: """
                    // swallowlint:disable rule1 rule2
                    // swallowlint:disable rule1
                    print("disable rule1 rule2")
                    // swallowlint:enable rule1 rule2
                    print("enable rule1 rule2")
                    // swallowlint:disable rule1
                    print("disable rule1")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)

                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 2))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 2))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 3))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 3))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 4))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 4))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 4))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 5))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 5))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule3", line: 5))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 6))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 6))) == true
                    expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 7))) == false
                    expect(visitor.isValidViolation(violation: Violation.make("rule2", line: 7))) == true
                }
            }
        }
    }
}
