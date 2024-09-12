//
//  CommandVisitorDisableThisFileTest.swift
//
//
//  Created by torobi on 2024/07/22.
//

@testable import swallowlint
import Nimble
import Quick

final class CommandVisitorDisableThisFileTest: QuickSpec {
    override class func spec() {
        describe("CommandVisitor.thisFileDisableRuleIdentifiers") {
            context("swallowlint:disable:thisFile does not exist") {
                it("thisFileCommands is empty") {
                    let file = MockSwallowLintFile(source: """
                    print("hello, world")
                    """)
                    let visitor = CommandVisitor(locationConverter: file.locationConverter)
                    visitor.walk(file.syntaxTree)
                    expect(visitor.thisFileDisableRuleIdentifiers.isEmpty).to(beTrue())
                }
            }
            context("multiple swallowlint:disable:thisFile commands") {
                context("without swiftlint commands") {
                    it("capture all thisFileCommands") {
                        let file = MockSwallowLintFile(source: """
                        // swallowlint:disable:thisFile rule1
                        // swallowlint:disable:thisFile rule2
                        print("hello, world")
                        // swallowlint:disable:thisFile rule3 rule4
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        let expected = Set(["rule1", "rule2", "rule3", "rule4"])
                        expect(visitor.thisFileDisableRuleIdentifiers).to(equal(expected))
                    }
                }
                context("with swiftlint commands") {
                    it("capture all thisFileCommands") {
                        let file = MockSwallowLintFile(source: """
                        // swiftlint:disable:this swiftlintrule1 - swallowlint:disable:thisFile rule1
                        // swiftlint:disable:next swiftlintrule2 - swallowlint:disable:thisFile rule2
                        print("hello, world")
                        // swiftlint:disable:previous swiftlintrule3 swiftlintrule4 - swallowlint:disable:thisFile rule3 rule4
                        """)
                        let visitor = CommandVisitor(locationConverter: file.locationConverter)
                        visitor.walk(file.syntaxTree)
                        let expected = Set(["rule1", "rule2", "rule3", "rule4"])
                        expect(visitor.thisFileDisableRuleIdentifiers).to(equal(expected))
                    }
                }
            }
        }
    }
}
