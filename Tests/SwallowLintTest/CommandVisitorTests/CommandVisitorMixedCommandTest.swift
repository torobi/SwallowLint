//
//  CommandVisitorMixedCommandTest.swift
//  swallowlint
//
//  Created by torobi on 2024/09/21.
//

@testable import swallowlint
import Nimble
import Quick

final class CommandVisitorMixedCommandTest: QuickSpec {
    typealias Violation = CommandVisitorTestHelper.Violation
    override class func spec() {
        describe("CommandVisitor some commands") {
            context("Set enable and disable on the same line") {
                context("1 enable command, 2 disable command") {
                    it("Target rule is disable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:disable:next rule1
                        print("this is line2") // swallowlint:disable:this rule1
                        // swallowlint:enable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    }
                    it("Target rule is disable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:disable rule1
                        print("this is line2") // swallowlint:enable:this rule1
                        // swallowlint:disable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    }
                    it("Target rule is disable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable rule1
                        print("this is line2") // swallowlint:disable:this rule1
                        // swallowlint:disable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == false
                    }
                }
                context("2 enable command, 1 disable command") {
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:disable:next rule1
                        print("this is line2") // swallowlint:enable:this rule1
                        // swallowlint:enable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    }
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable:next rule1
                        print("this is line2") // swallowlint:disable:this rule1
                        // swallowlint:enable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    }
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable:next rule1
                        // swallowlint:disable:next rule1
                        print("this is line2") // swallowlint:enable:this rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 3))) == true
                    }
                }
                context("1 enable command, 1 disable command") {
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable:next rule1
                        print("this is line2") // swallowlint:disable:this rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    }
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        print("this is line2") // swallowlint:enable:this rule1
                        // swallowlint:disable:previous rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    }
                    it("Target rule is enable") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:enable:next rule1
                        print("this is line2") // swallowlint:disable:this rule1
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        
                        expect(visitor.isValidViolation(violation: Violation.make("rule1", line: 2))) == true
                    }
                }
            }
        }
    }
}
